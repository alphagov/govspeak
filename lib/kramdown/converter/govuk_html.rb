module Kramdown
  module Converter
    class GovukHtml < Html
      NO_INDENT = 0

      def convert_address_block(element, _indent)
        p = element.children.first

        "\n" + format_as_block_html(
          "div",
          { "class" => "address" },
          format_as_block_html_without_linebreak(
            "div",
            { "class" => "adr org fn" },
            format_as_block_html_without_linebreak(
              "p",
              {},
              "\n#{inner(p, NO_INDENT)}\n",
              NO_INDENT,
            ),
            NO_INDENT,
          ),
          NO_INDENT,
        )
      end

      def convert_div(element, indent)
        format_as_block_html("div", element.attr, inner(element, indent), indent)
      end

    private

      def format_as_block_html_without_linebreak(name, attr, body, indent)
        "#{' ' * indent}<#{name}#{html_attributes(attr)}>#{body}</#{name}>"
      end
    end
  end
end
