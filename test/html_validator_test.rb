require "test_helper"

class HtmlValidatorTest < Minitest::Test
  test "allow Govspeak Markdown" do
    values = [
      "## is H2",
      "*bold text*",
      "* bullet",
      "- alternative bullet",
      "double -- dash -- ndash",
      "+ another bullet",
      "1. Numbered list",
      "s2. Step",
      "
      Table | Header
      - | -
      Build | cells
      ",
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
      "$!Answer$! - answer summary",
      "{::highlight-answer}Highlighted answer{:/highlight-answer} - creates a large pink highlight box with optional preamble text and giant text denoted with **.",
      "{::highlight-answer}",
      "The VAT rate is *20%*",
      "{:/highlight-answer}",
      "---",
      "*[GDS]: Government Digital Service",
      "
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
      ",
      ":england:content goes here:england:",
      ":scotland:content goes here:scotland:"
    ]
    values.each do |value|
      assert Govspeak::HtmlValidator.new(value).valid?
    end
  end

  test "disallow a script tag" do
    assert Govspeak::HtmlValidator.new("<script>alert('XSS')</script>").invalid?
  end

  test "disallow a javascript protocol in an attribute" do
    html = '<a href="javascript:alert(document.location);"
              title="Title">an example</a>'
    assert Govspeak::HtmlValidator.new(html).invalid?
  end

  test "disallow a javascript protocol in a Markdown link" do
    html = 'This is [an example](javascript:alert(""); "Title") inline link.'
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

  test "optionally disallow images not on a whitelisted domain" do
    html = "<img src='http://evil.com/image.jgp'>"
    assert Govspeak::HtmlValidator.new(html, allowed_image_hosts: ['allowed.com']).invalid?
  end

  test "allow <div> and <span> HTML elements" do
    html = "<div class=\"govspeak\"><h2 id=\"some-title\">\n<span class=\"number\">1. </span> Some title</h2>\n\n<p>Some text</p>\n</div>"
    assert Govspeak::HtmlValidator.new(html).valid?
  end

  test "allow govspeak button" do
    assert Govspeak::HtmlValidator.new("{button}[Start now](https://gov.uk){/button}").valid?
    assert Govspeak::HtmlValidator.new("{button start}[Start now](https://gov.uk){/button}").valid?
    assert Govspeak::HtmlValidator.new("{button start cross-domain-tracking:UA-XXXXXX-Y}[Start now](https://gov.uk){/button}").valid?
  end

  test "allow a table without a tbody" do
    # The publication https://whitehall-admin.integration.publishing.service.gov.uk/government/admin/publications/889052
    # with the HTML attachment "What Works Network membership requirements (HTML)"
    # has a table without a tbody
    assert Govspeak::HtmlValidator.new("<table><tr><td>Hello</td></tr></table>").valid?, "No <tbody> is valid"
  end

  test "allow a table with a tbody" do
    # If the above test is made to pass, there is a chance this will break
    assert Govspeak::HtmlValidator.new("<table><tbody><tr><td>Hello</td></tr></tbody></table>").valid?, "<tbody> is valid"
  end

  test "allow a table with a quotes spanning table elements" do
    # The publication https://whitehall-admin.integration.publishing.service.gov.uk/government/admin/publications/964161
    # with the HTML attachment "Upper Tribunal (Tax and Chancery) financial services hearings and register 2014 to date"
    # has quotes spanning table elements
    assert Govspeak::HtmlValidator.new("<table><tbody><tr><td>\"Hello</td><td>World\"</td></tr></tbody></table>").valid?
  end

  test "allow a govspeak table" do
    # This ensures that tables created with Markdown are still valid
    # https://whitehall-admin.integration.publishing.service.gov.uk/government/admin/detailed-guides/968711/edit
    govspeak = "
      Table | Header
      - | -
      Build | cells"
    assert Govspeak::HtmlValidator.new(govspeak).valid?, "Markdown tables are OK"
  end

  test "allow a document with 2 tables: one with a tbody and one without" do
    # The guidance https://whitehall-admin.integration.publishing.service.gov.uk/government/admin/publications/938674
    # with the HTML attachment "2018 to 2019: Student Loan deduction tables" has tables with and without tbody tags
    html = "
    <table><tr><td>Hello</td></tr></table>

    <table><tbody><tr><td>Hello</td></tr></tbody></table>
    "
    assert Govspeak::HtmlValidator.new(html).valid?, "All tables are valid"
  end
end
