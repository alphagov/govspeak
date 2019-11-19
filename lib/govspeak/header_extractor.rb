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

    def id(element)
      element.attr.fetch("id", generate_id(element.options[:raw_text]))
    end

    def build_header(element)
      Header.new(element.options[:raw_text], element.options[:level], id(element))
    end

    def find_headers(parent)
      headers = []

      if parent.type == :header
        headers << build_header(parent)
      elsif parent.type == :html_element
        parent.children.each do |child|
          if child.type == :header
            headers << build_header(child)
          elsif !child.children.empty?
            headers << find_headers(child)
          end
        end
      end

      headers
    end
  end
end
