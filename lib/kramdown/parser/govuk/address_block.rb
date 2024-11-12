module Kramdown
  module Parser
    class Govuk
      ADDRESS_BLOCK_PATTERN = /(?:\r|\n|^)\$A(.*?)\$A? *(\r|\n|$)/m
      ADDRESS_BLOCK_START = /(?:\r|\n|^)\$A/
      ADDRESS_BLOCK_END = /\$A *(\r|\n|$)/

      define_parser(:address_block, ADDRESS_BLOCK_PATTERN)

      def parse_address_block
        start_line_number = @src.current_line_number
        @src.scan(ADDRESS_BLOCK_START)

        parent_el = new_block_el(:address_block, nil, nil, location: start_line_number)
        p = new_block_el(:p, nil, nil, location: start_line_number)
        parent_el.children << p
        @tree.children << parent_el

        value = @src.scan_until(ADDRESS_BLOCK_END)&.sub(ADDRESS_BLOCK_END, "")

        if value
          text_lines = value.lstrip.sub(/[\s\\]*\z/, '').split(/[ \\]*\r?\n/)

          p.children << Element.new(:raw_text, text_lines.first)
          text_lines.drop(1).each do |text_line|
            p.children << Element.new(:br)
            p.children << Element.new(:raw_text, text_line)
          end
        end
      end
    end
  end
end
