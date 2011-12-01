module Govspeak
  Header = Struct.new(:text, :level, :id)

  class HeaderExtractor < Kramdown::Converter::Base
    def convert(doc)
      doc.root.children.map do |el|
        if el.type == :header
          Header.new(el.options[:raw_text], el.options[:level], generate_id(el.options[:raw_text]))
        end
      end.compact
    end
  end
end