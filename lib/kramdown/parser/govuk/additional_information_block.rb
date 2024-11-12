module Kramdown
  module Parser
    class Govuk
      ADDITIONAL_INFORMATION_BLOCK_PATTERN = /(?:\r|\n|^)\$AI(.*?)\$AI? *(\r|\n|$)/m

      define_parser(:additional_information_block, ADDITIONAL_INFORMATION_BLOCK_PATTERN)

      def parse_additional_information_block
        start_line_number = @src.current_line_number
        @src.scan(ADDITIONAL_INFORMATION_BLOCK_PATTERN)

        @src.captures.each do |capture|
          next if capture =~ /^\s$/

          value = capture.strip.gsub(/\A^\|/, "\n|").gsub(/\|$\Z/, "|\n")

          attributes = {
            "class" => "additional-information",
          }

          el = new_block_el(:div, value, attributes, location: start_line_number)
          @tree.children << el
          parse_blocks(el, capture)
        end
      end
    end
  end
end
