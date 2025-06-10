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

      def convert_call_to_action(element, _indent)
        format_as_block_html(
          "div",
          { "class" => "call-to-action" },
          "\n#{inner(element, NO_INDENT)}",
          NO_INDENT,
        )
      end

      def convert_div(element, indent)
        format_as_block_html("div", element.attr, inner(element, indent), indent)
      end

      def convert_informational(element, _indent)
        p = element.children.first

        "\n" + format_as_indented_block_html(
          "div",
          {
            "role" => "note",
            "aria-label" => "Information",
            "class" => "application-notice info-notice",
          },
          format_as_block_html_without_linebreak(
            "p",
            {},
            inner(p, NO_INDENT),
            NO_INDENT,
          ),
          NO_INDENT,
        )
      end

    private

      def format_as_block_html_without_linebreak(name, attr, body, indent)
        "#{' ' * indent}<#{name}#{html_attributes(attr)}>#{body}</#{name}>"
      end
    end
  end
end
