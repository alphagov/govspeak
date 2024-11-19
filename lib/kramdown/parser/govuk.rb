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

      def initialize(source, options)
        @document_domains = options[:document_domains] || %w[www.gov.uk]
        super
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

      # Override Kramdown's native `parse_list` to avoid parsing OLs (including
      # nested ones) when the `ordered_lists_disabled` flag is set on a block.
      def parse_list
        return super unless @options[:ordered_lists_disabled]

        return if @src.check(LIST_START_OL)

        original_list_start = LIST_START
        Kramdown::Parser::Kramdown.send(:remove_const, :LIST_START)
        Kramdown::Parser::Kramdown.send(:const_set, :LIST_START, LIST_START_UL)

        super
      ensure
        Kramdown::Parser::Kramdown.send(:remove_const, :LIST_START)
        Kramdown::Parser::Kramdown.send(:const_set, :LIST_START, original_list_start)
      end
    end
  end
end
