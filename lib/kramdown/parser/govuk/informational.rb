module Kramdown
  module Parser
    class Govuk
      INFORMATIONAL_PATTERN = /(?:\r|\n|^)\^\s*(.*?)\s*\^? *(\r|\n|$)/m
      INFORMATIONAL_START = /(?:\r|\n|^)\^\s*/
      INFORMATIONAL_END = /\s*\^? *(\r|\n|$)/

      PARAGRAPH_END = Regexp.union(PARAGRAPH_END, INFORMATIONAL_START)

      define_parser(:informational, INFORMATIONAL_PATTERN)

      def parse_informational
        start_line_number = @src.current_line_number
        @src.scan(INFORMATIONAL_START)

        parent_el = new_block_el(:informational, nil, nil, location: start_line_number)
        p = new_block_el(:p, nil, nil, location: start_line_number)
        parent_el.children << p
        @tree.children << parent_el

        env = save_env
        reset_env(src: @src, tree: @tree)
        parse_spans(p, INFORMATIONAL_END)
        update_tree(p)
        restore_env(env)

        @src.scan(INFORMATIONAL_END)
      end
    end
  end
end
