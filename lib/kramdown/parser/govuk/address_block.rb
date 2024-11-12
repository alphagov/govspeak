module Kramdown
  module Parser
    class Govuk
      ADDRESS_BLOCK_PATTERN = /(?:\r|\n|^)\$A(.*?)\$A? *(\r|\n|$)/m

      define_parser(:address_block, ADDRESS_BLOCK_PATTERN)

      def parse_address_block
        start_line_number = @src.current_line_number
        @src.scan(ADDRESS_BLOCK_PATTERN)

        @src.captures.each do |capture|
          next if capture =~ /^\s$/

          value = "\n#{capture.sub("\n", '').gsub("\n", '<br />')}\n"

          parent_div = new_block_el(:div, nil, { "class" => "address" }, location: start_line_number)
          child_div = new_block_el(:div, nil, { "class" => "adr org fn" }, location: start_line_number)
          p = new_block_el(:p)
          add_text(value, p)

          child_div.children << p
          parent_div.children << child_div

          @tree.children << parent_div
          # This is disabled because it spat out a duplicate version of the
          # capture. Is it a problem not to parse this? Would this skip parsing
          # Govspeak nested within an address block? Is that a thing? Will it be
          # a thing in other blocks that don't work when we run `parse_blocks`?
          # parse_blocks(parent_div, capture)
        end
      end
    end
  end
end
