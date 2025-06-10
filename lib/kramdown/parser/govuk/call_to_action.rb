module Kramdown
  module Parser
    class Govuk
      CALL_TO_ACTION_PATTERN = /(?:\r|\n|^)\$CTA(.*?)\$CTA? *(\r|\n|$)/m
      CALL_TO_ACTION_START = /(?:\r|\n|^)\$CTA/
      CALL_TO_ACTION_END = /\$CTA *(\r|\n|$)/

      define_parser(:call_to_action, CALL_TO_ACTION_PATTERN)

      def parse_call_to_action
        start_line_number = @src.current_line_number
        @src.scan(CALL_TO_ACTION_START)

        parent_el = new_block_el(:call_to_action, nil, nil, location: start_line_number)
        @tree.children << parent_el

        value = @src.scan_until(CALL_TO_ACTION_END)
          &.sub(CALL_TO_ACTION_END, "")
          &.strip

        if value && !value.empty?
          env = save_env
          reset_env(src: @src, tree: @tree)

          parse_blocks(parent_el, "#{value}\n")
          restore_env(env)
        end
      end
    end
  end
end
