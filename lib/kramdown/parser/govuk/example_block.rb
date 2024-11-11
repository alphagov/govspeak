module Kramdown
  module Parser
    class Govuk
      EXAMPLE_BLOCK_PATTERN = /(?:\r|\n|^)\$E(.*?)\$E? *(\r|\n|$)/m

      define_parser(:example_block, EXAMPLE_BLOCK_PATTERN)

      def parse_example_block
        start_line_number = @src.current_line_number
        @src.scan(EXAMPLE_BLOCK_PATTERN)

        @src.captures.each do |capture|
          next if capture =~ /\A\s*\Z/

          value = capture.strip.gsub(/\A^\|/, "\n|").gsub(/\|$\Z/, "|\n")

          attributes = {
            "class" => "example",
          }

          el = new_block_el(:div, value, attributes, location: start_line_number)
          @tree.children << el
          parse_blocks(el, capture)
        end
      end
    end
  end
end
