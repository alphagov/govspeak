module Govspeak
  Header = Struct.new(:text, :level, :id)

  class HeaderExtractor < Kramdown::Converter::Base
    def convert(doc)
      headers = []

      doc.root.children.each do |el|
        if el.type == :header
          headers << build_header(el)
          next
        end

        headers << find_headers(el) if el.type == :html_element
      end

      headers.flatten.compact
    end

  private
    def id(el)
      el.attr.fetch('id', generate_id(el.options[:raw_text]))
    end

    def build_header(el)
      Header.new(el.options[:raw_text], el.options[:level], id(el))
    end

    def find_headers(parent)
      headers = []

      if parent.type == :header
        headers << build_header(parent)
      elsif parent.type == :html_element
        parent.children.each do |child|
          if child.type == :header
            headers << build_header(child)
          elsif child.children.size > 0
            headers << find_headers(child)
          end
        end
      end

      headers
    end
  end
end
