module Kramdown
  module Converter
    class GovukHtml < Html
      def convert_div(element, indent)
        format_as_block_html("div", element.attr, inner(element, indent), indent)
      end
    end
  end
end
