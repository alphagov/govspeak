require "addressable/uri"
require "kramdown/options"

module Kramdown
  module Options
    class AlwaysEqual
      def ==(_other)
        true
      end
    end

    define(:document_domains, Object, %w[www.gov.uk], <<~DESCRIPTION) do |val|
      Defines the domains which are considered local to the document

      Default: www.gov.uk
      Used by: KramdownWithAutomaticExternalLinks
    DESCRIPTION
      simple_array_validator(val, :document_domains, AlwaysEqual.new)
    end

    define(:ordered_lists_disabled, Boolean, false, <<~DESCRIPTION)
      Disables ordered lists

      Default: false
      Used by: KramdownWithAutomaticExternalLinks
    DESCRIPTION
  end

  module Parser
    class Govuk < Kramdown::Parser::Kramdown
      CUSTOM_INLINE_ELEMENTS = %w[govspeak-embed-attachment-link].freeze

      BLOCK_EXTENSIONS = {
        additional_information_block: "govuk/additional_information_block",
        address_block: "govuk/address_block",
        example_block: "govuk/example_block",
      }.freeze

      private_constant :BLOCK_EXTENSIONS

      def initialize(source, options)
        @document_domains = options[:document_domains] || %w[www.gov.uk]
        super

        BLOCK_EXTENSIONS.each do |extension_name, file_name|
          require_relative file_name
          @block_parsers.unshift(extension_name)
        end
      end

      def add_link(element, href, title, alt_text = nil, ial = nil)
        if element.type == :a
          begin
            host = Addressable::URI.parse(href).host
            unless host.nil? || @document_domains.compact.include?(host)
              element.attr["rel"] = "external"
            end
          rescue Addressable::URI::InvalidURIError
            # it's safe to ignore these very *specific* exceptions
          end

        end
        super
      end

      def parse_block_html
        return false if CUSTOM_INLINE_ELEMENTS.include?(@src[1].downcase)

        super
      end

      # We override the parse_list method with a modified version where ordered lists are
      # disabled (for use with legislative lists). The majority of the method body is copied
      # over (from https://github.com/gettalong/kramdown/blob/REL_2_3_1/lib/kramdown/parser/kramdown/list.rb#L54),
      # only the LIST_START is changed. Previously, we dynamically modified some of the
      # class-scoped variables used in this method; this provides a thread-safe alternative.
      def parse_list
        return super unless @options[:ordered_lists_disabled]

        return if @src.check(LIST_START_OL)

        start_line_number = @src.current_line_number
        type, list_start_re = (@src.check(LIST_START_UL) ? [:ul, LIST_START_UL] : [:ol, LIST_START_OL])
        list = new_block_el(type, nil, nil, location: start_line_number)

        item = nil
        content_re, lazy_re, indent_re = nil
        eob_found = false
        nested_list_found = false
        last_is_blank = false
        until @src.eos?
          start_line_number = @src.current_line_number
          if last_is_blank && @src.check(HR_START)
            break
          elsif @src.scan(EOB_MARKER)
            eob_found = true
            break
          elsif @src.scan(list_start_re)
            list.options[:first_list_marker] ||= @src[1].strip
            item = Element.new(:li, nil, nil, location: start_line_number)
            item.value, indentation, content_re, lazy_re, indent_re =
              parse_first_list_line(@src[1].length, @src[2])
            list.children << item

            item.value.sub!(self.class::LIST_ITEM_IAL) do
              parse_attribute_list(::Regexp.last_match(1), item.options[:ial] ||= {})
              ""
            end

            list_start_re = fetch_pattern(type, indentation)
            nested_list_found = (item.value =~ LIST_START_UL)
            last_is_blank = false
            item.value = [item.value]
          elsif (result = @src.scan(content_re)) || (!last_is_blank && (result = @src.scan(lazy_re)))
            result.sub!(/^(\t+)/) { " " * 4 * ::Regexp.last_match(1).length }
            indentation_found = result.sub!(indent_re, "")
            if !nested_list_found && indentation_found && result =~ LIST_START_UL
              item.value << +""
              nested_list_found = true
            elsif nested_list_found && !indentation_found && result =~ LIST_START_UL
              result = " " * (indentation + 4) << result
            end
            item.value.last << result
            last_is_blank = false
          elsif (result = @src.scan(BLANK_LINE))
            nested_list_found = true
            last_is_blank = true
            item.value.last << result
          else
            break
          end
        end

        @tree.children << list

        last = nil
        list.children.each do |it|
          temp = Element.new(:temp, nil, nil, location: it.options[:location])

          env = save_env
          location = it.options[:location]
          it.value.each do |val|
            @src = ::Kramdown::Utils::StringScanner.new(val, location)
            parse_blocks(temp)
            location = @src.current_line_number
          end
          restore_env(env)

          it.children = temp.children
          it.value = nil

          it_children = it.children
          next if it_children.empty?

          # Handle the case where an EOB marker is inserted by a block IAL for the first paragraph
          it_children.delete_at(1) if it_children.first.type == :p &&
            it_children.length >= 2 && it_children[1].type == :eob && it_children.first.options[:ial]

          if it_children.first.type == :p &&
              (it_children.length < 2 || it_children[1].type != :blank ||
                (it == list.children.last && it_children.length == 2 && !eob_found)) &&
              (list.children.last != it || list.children.size == 1 ||
                list.children[0..-2].any? { |cit| !cit.children.first || cit.children.first.type != :p || cit.children.first.options[:transparent] })
            it_children.first.children.first.value << "\n" if it_children.size > 1 && it_children[1].type != :blank
            it_children.first.options[:transparent] = true
          end

          last = (it_children.last.type == :blank ? it_children.pop : nil)
        end

        @tree.children << last if !last.nil? && !eob_found

        true
      end
    end
  end
end
