require "test_helper"

class HtmlValidatorTest < Test::Unit::TestCase
  test "allow Govspeak Markdown" do
    values = [
      "## is H2",
      "*bold text*",
      "* bullet",
      "- alternative bullet",
      "+ another bullet",
      "1. Numbered list",
      "s2. Step",
      """
      Table | Header
      - | -
      Build | cells
      """,
      "This is [an example](/an-inline-link \"Title\") inline link.",
      "<http://example.com/>",
      "<address@example.com>",
      "This is [an example](http://example.com/ \"Title\"){:rel=\"external\"} inline link to an external resource.",
      "^Your text here^ - creates a callout with an info (i) icon.",
      "%Your text here% - creates a callout with a warning or alert (!) icon",
      "@Your text here@ - highlights the enclosed text in yellow",
      "$CSome contact information here$C - contact information",
      "$A Hercules House Hercules Road London SE1 7DU $A",
      "$D [An example form download link](http://example.com/ \"Example form\") Something about this form download $D",
      "$EAn example for the citizen$E - examples boxout",
      "$!...$! - answer summary",
      "{::highlight-answer}...{:/highlight-answer} - creates a large pink highlight box with optional preamble text and giant text denoted with **.",
      "{::highlight-answer}",
      "The VAT rate is *20%*",
      "{:/highlight-answer}",
      "---",
      "*[GDS]: Government Digital Service",
      """
      $P

      $I
      $A
      Hercules House
      Hercules Road
      London SE1 7DU
      $A

      $AI
      There is access to the building from the street via a ramp.
      $AI
      $I
      $P
      """,
      ":england:content goes here:england:",
      ":scotland:content goes here:scotland:",
      "thing with footnote[^1]\n\n[^1]: Some footnote content"
    ]
    values.each do |value|
      assert Govspeak::HtmlValidator.new(value).valid?
    end
  end

  test "disallow a script tag" do
    assert Govspeak::HtmlValidator.new("<script>alert('XSS')</script>").invalid?
  end

  test "disallow a javascript protocol in an attribute" do
    html = %q{<a href="javascript:alert(document.location);"
              title="Title">an example</a>}
    assert Govspeak::HtmlValidator.new(html).invalid?
  end

  test "disallow a javascript protocol in a Markdown link" do
    html = %q{This is [an example](javascript:alert(""); "Title") inline link.}
    assert Govspeak::HtmlValidator.new(html).invalid?
  end

  test "disallow on* attributes" do
    html = %q{<a href="/" onclick="alert('xss');">Link</a>}
    assert Govspeak::HtmlValidator.new(html).invalid?
  end

  test "allow non-JS HTML content" do
    assert Govspeak::HtmlValidator.new("<a href='foo'>").valid?
  end

  test "allow things that will end up as HTML entities" do
    assert Govspeak::HtmlValidator.new("Fortnum & Mason").valid?
  end
end
