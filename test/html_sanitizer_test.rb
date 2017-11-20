require "test_helper"

class HtmlSanitizerTest < Minitest::Test

  test "disallow a script tag" do
    html = "<script>alert('XSS')</script>"
    assert_equal "alert('XSS')", Govspeak::HtmlSanitizer.new(html).sanitize
  end

  test "disallow a javascript protocol in an attribute" do
    html = %q{<a href="javascript:alert(document.location);"
              title="Title">an example</a>}
    assert_equal "<a title=\"Title\">an example</a>", Govspeak::HtmlSanitizer.new(html).sanitize
  end

  test "disallow on* attributes" do
    html = %q{<a href="/" onclick="alert('xss');">Link</a>}
    assert_equal "<a href=\"/\">Link</a>", Govspeak::HtmlSanitizer.new(html).sanitize
  end

  test "allow non-JS HTML content" do
    html = "<a href='foo'>"
    assert_equal "<a href=\"foo\"></a>", Govspeak::HtmlSanitizer.new(html).sanitize
  end

  test "keep things that should be HTML entities" do
    html = "Fortnum & Mason"
    assert_equal "Fortnum &amp; Mason", Govspeak::HtmlSanitizer.new(html).sanitize
  end

  test "allow govspeak button markup" do
    html = "<a href='#' data-module='cross-domain-tracking' data-tracking-code='UA-XXXXXX-Y' data-tracking-name='govspeakButtonTracker'></a>"
    assert_equal(
      "<a href=\"#\" data-module=\"cross-domain-tracking\" data-tracking-code=\"UA-XXXXXX-Y\" data-tracking-name=\"govspeakButtonTracker\"></a>",
      Govspeak::HtmlSanitizer.new(html).sanitize
    )
  end

  test "allows images on whitelisted domains" do
    html = "<img src='http://allowed.com/image.jgp'>"
    sanitized_html = Govspeak::HtmlSanitizer.new(html, allowed_image_hosts: ['allowed.com']).sanitize
    assert_equal "<img src=\"http://allowed.com/image.jgp\">", sanitized_html
  end

  test "removes images not on whitelisted domains" do
    html = "<img src='http://evil.com/image.jgp'>"
    assert_equal "", Govspeak::HtmlSanitizer.new(html, allowed_image_hosts: ['allowed.com']).sanitize
  end

  test "can strip images" do
    html = "<img src='http://example.com/image.jgp'>"
    assert_equal "", Govspeak::HtmlSanitizer.new(html).sanitize_without_images
  end

  test "allows table cells and table headings without a style attribute" do
    html = "<th>thing</th><td>thing</td>"
    assert_equal html, Govspeak::HtmlSanitizer.new(html).sanitize
  end

  test "allows valid text-align properties on the style attribute for table cells and table headings" do
    ["left", "right", "center"].each do |alignment|
      html = "<th style=\"text-align: #{alignment}\">thing</th><td style=\"text-align: #{alignment}\">thing</td>"
      assert_equal html, Govspeak::HtmlSanitizer.new(html).sanitize
    end

    [
      "width: 10000px",
      "text-align: middle",
      "text-align: left; width: 10px",
      "background-image: url(javascript:alert('XSS'))",
      "expression(alert('XSS'));"
    ].each do |style|
      html = "<th style=\"#{style}\">thing</th><td style=\"#{style}\">thing</td>"
      assert_equal '<th>thing</th><td>thing</td>', Govspeak::HtmlSanitizer.new(html).sanitize
    end
  end
end
