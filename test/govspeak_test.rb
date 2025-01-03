require "test_helper"
require "govspeak_test_helper"

require "ostruct"

class GovspeakTest < Minitest::Test
  include GovspeakTestHelper

  test "simple smoke-test" do
    rendered = Govspeak::Document.new("*this is markdown*").to_html
    assert_equal "<p><em>this is markdown</em></p>\n", rendered
  end

  test "simple smoke-test for simplified API" do
    rendered = Govspeak::Document.to_html("*this is markdown*")
    assert_equal "<p><em>this is markdown</em></p>\n", rendered
  end

  test "strips forbidden unicode characters" do
    rendered = Govspeak::Document.new(
      "this is text with forbidden characters \u0008\u000b\ufffe\u{2ffff}\u{5fffe}",
    ).to_html
    assert_equal "<p>this is text with forbidden characters</p>\n", rendered
  end

  test "highlight-answer block extension" do
    rendered = Govspeak::Document.new("this \n{::highlight-answer}Lead in to *BIG TEXT*\n{:/highlight-answer}").to_html
    assert_equal %(<p>this</p>\n\n<div class="highlight-answer">\n<p>Lead in to <em>BIG TEXT</em></p>\n</div>\n), rendered
  end

  test "stat-headline block extension" do
    rendered = Govspeak::Document.new("this \n{stat-headline}*13.8bn* Age of the universe in years{/stat-headline}").to_html
    assert_equal %(<p>this</p>\n\n<div class="stat-headline">\n<p><em>13.8bn</em> Age of the universe in years</p>\n</div>\n), rendered
  end

  test "extracts headers with text, level and generated id" do
    document = Govspeak::Document.new %(
# Big title

### Small subtitle

## Medium title
)
    assert_equal [
      Govspeak::Header.new("Big title", 1, "big-title"),
      Govspeak::Header.new("Small subtitle", 3, "small-subtitle"),
      Govspeak::Header.new("Medium title", 2, "medium-title"),
    ], document.headers
  end

  test "extracts different ids for duplicate headers" do
    document = Govspeak::Document.new("## Duplicate header\n\n## Duplicate header")
    assert_equal [
      Govspeak::Header.new("Duplicate header", 2, "duplicate-header"),
      Govspeak::Header.new("Duplicate header", 2, "duplicate-header-1"),
    ], document.headers
  end

  test "extracts headers when nested inside blocks" do
    document = Govspeak::Document.new %(
# First title

<div markdown="1">
## Nested subtitle
</div>

<div>
<div markdown="1">
### Double nested subtitle
</div>
<div markdown="1">
### Second double subtitle
</div>
</div>
)
    assert_equal [
      Govspeak::Header.new("First title", 1, "first-title"),
      Govspeak::Header.new("Nested subtitle", 2, "nested-subtitle"),
      Govspeak::Header.new("Double nested subtitle", 3, "double-nested-subtitle"),
      Govspeak::Header.new("Second double subtitle", 3, "second-double-subtitle"),
    ], document.headers
  end

  test "extracts headers with explicitly specified ids" do
    document = Govspeak::Document.new %(
# First title

## Second title {#special}
)
    assert_equal [
      Govspeak::Header.new("First title", 1, "first-title"),
      Govspeak::Header.new("Second title", 2, "special"),
    ], document.headers
  end

  test "extracts text with no HTML and normalised spacing" do
    input = "# foo\n\nbar    baz  "
    doc = Govspeak::Document.new(input)
    assert_equal "foo bar baz", doc.to_text
  end

  test "trailing space after the address should not prevent parsing" do
    input = %($A
123 Test Street
Testcase Cliffs
Teston
0123 456 7890 $A    )
    doc = Govspeak::Document.new(input)
    assert_equal %(\n<div class="address"><div class="adr org fn"><p>\n123 Test Street<br>Testcase Cliffs<br>Teston<br>0123 456 7890\n</p></div></div>\n), doc.to_html
  end

  test "newlines in address block content are replaced with <br>s" do
    input = %($A\n123 Test Street\nTestcase Cliffs\nTeston\n0123 456 7890\n$A)
    doc = Govspeak::Document.new(input)
    assert_equal %(\n<div class="address"><div class="adr org fn"><p>\n123 Test Street<br>Testcase Cliffs<br>Teston<br>0123 456 7890\n</p></div></div>\n), doc.to_html
  end

  test "combined return-and-newlines in address block content are replaced with <br>s" do
    input = %($A\r\n123 Test Street\r\nTestcase Cliffs\r\nTeston\r\n0123 456 7890\r\n$A)
    doc = Govspeak::Document.new(input)
    assert_equal %(\n<div class="address"><div class="adr org fn"><p>\n123 Test Street<br>Testcase Cliffs<br>Teston<br>0123 456 7890\n</p></div></div>\n), doc.to_html
  end

  test "trailing backslashes are stripped from address block content" do
    # two trailing backslashes would normally be converted into a line break by Kramdown
    input = %($A\r\n123 Test Street\\\r\nTestcase Cliffs\\\nTeston\\\\\r\n0123 456 7890\\\\\n$A)
    doc = Govspeak::Document.new(input)
    assert_equal %(\n<div class="address"><div class="adr org fn"><p>\n123 Test Street<br>Testcase Cliffs<br>Teston<br>0123 456 7890\n</p></div></div>\n), doc.to_html
  end

  test "trailing spaces are stripped from address block content" do
    # two trailing spaces would normally be converted into a line break by Kramdown
    input = %($A\r\n123 Test Street \r\nTestcase Cliffs  \nTeston   \r\n0123 456 7890    \n$A)
    doc = Govspeak::Document.new(input)
    assert_equal %(\n<div class="address"><div class="adr org fn"><p>\n123 Test Street<br>Testcase Cliffs<br>Teston<br>0123 456 7890\n</p></div></div>\n), doc.to_html
  end

  test "trailing backslashes and spaces are stripped from address block content" do
    # two trailing backslashes or two trailing spaces would normally be converted into a line break by Kramdown
    input = %($A\r\n123 Test Street  \\\r\nTestcase Cliffs\\  \nTeston\\\\  \r\n0123 456 7890  \\\\\n$A)
    doc = Govspeak::Document.new(input)
    assert_equal %(\n<div class="address"><div class="adr org fn"><p>\n123 Test Street<br>Testcase Cliffs<br>Teston<br>0123 456 7890\n</p></div></div>\n), doc.to_html
  end

  test "should convert barchart" do
    input = <<~GOVSPEAK
      |col|
      |---|
      |val|
      {barchart}
    GOVSPEAK
    html = Govspeak::Document.new(input).to_html
    assert_equal %(<table class=\"js-barchart-table mc-auto-outdent\">\n  <thead>\n    <tr>\n      <th scope="col">col</th>\n    </tr>\n  </thead>\n  <tbody>\n    <tr>\n      <td>val</td>\n    </tr>\n  </tbody>\n</table>\n), html
  end

  test "should convert barchart with stacked compact and negative" do
    input = <<~GOVSPEAK
      |col|
      |---|
      |val|
      {barchart stacked compact negative}
    GOVSPEAK
    html = Govspeak::Document.new(input).to_html
    assert_equal %(<table class=\"js-barchart-table mc-stacked compact mc-negative mc-auto-outdent\">\n  <thead>\n    <tr>\n      <th scope="col">col</th>\n    </tr>\n  </thead>\n  <tbody>\n    <tr>\n      <td>val</td>\n    </tr>\n  </tbody>\n</table>\n), html
  end

  test "address div is separated from paragraph text by a couple of line-breaks" do
    # else kramdown processes address div as part of paragraph text and escapes HTML
    input = %(Paragraph1

$A
123 Test Street
Testcase Cliffs
Teston
0123 456 7890 $A)
    doc = Govspeak::Document.new(input)
    assert_equal %(<p>Paragraph1</p>\n\n<div class="address"><div class="adr org fn"><p>\n123 Test Street<br>Testcase Cliffs<br>Teston<br>0123 456 7890\n</p></div></div>\n), doc.to_html
  end

  test_given_govspeak("^ I am very informational ^") do
    assert_html_output %(
      <div role="note" aria-label="Information" class="application-notice info-notice">
      <p>I am very informational</p>
      </div>)
    assert_text_output "I am very informational"
  end

  test "processing an extension does not modify the provided input" do
    input = "^ I am very informational"
    Govspeak::Document.new(input).to_html
    assert_equal "^ I am very informational", input
  end

  test_given_govspeak "The following is very informational\n^ I am very informational ^" do
    assert_html_output %(
      <p>The following is very informational</p>

      <div role="note" aria-label="Information" class="application-notice info-notice">
      <p>I am very informational</p>
      </div>)
    assert_text_output "The following is very informational I am very informational"
  end

  test_given_govspeak "^ I am very informational" do
    assert_html_output %(
      <div role="note" aria-label="Information" class="application-notice info-notice">
      <p>I am very informational</p>
      </div>)
    assert_text_output "I am very informational"
  end

  test_given_govspeak "% I am very helpful %" do
    assert_html_output %(
      <div role="note" aria-label="Warning" class="application-notice help-notice">
      <p>I am very helpful</p>
      </div>)
    assert_text_output "I am very helpful"
  end

  test_given_govspeak "The following is very helpful\n% I am very helpful %" do
    assert_html_output %(
      <p>The following is very helpful</p>

      <div role="note" aria-label="Warning" class="application-notice help-notice">
      <p>I am very helpful</p>
      </div>)
    assert_text_output "The following is very helpful I am very helpful"
  end

  test_given_govspeak "## Hello ##\n\n% I am very helpful %\r\n### Young Workers ###\n\n" do
    assert_html_output %(
      <h2 id="hello">Hello</h2>

      <div role="note" aria-label="Warning" class="application-notice help-notice">
      <p>I am very helpful</p>
      </div>

      <h3 id="young-workers">Young Workers</h3>)
    assert_text_output "Hello I am very helpful Young Workers"
  end

  test_given_govspeak "% I am very helpful" do
    assert_html_output %(
      <div role="note" aria-label="Warning" class="application-notice help-notice">
      <p>I am very helpful</p>
      </div>)
    assert_text_output "I am very helpful"
  end

  test_given_govspeak "This is a [link](http://www.gov.uk) isn't it?" do
    assert_html_output '<p>This is a <a href="http://www.gov.uk">link</a> isn’t it?</p>'
    assert_text_output "This is a link isn’t it?"
  end

  test_given_govspeak "This is a [link with an at sign in it](http://www.gov.uk/@dg/@this) isn't it?" do
    assert_html_output '<p>This is a <a href="http://www.gov.uk/@dg/@this">link with an at sign in it</a> isn’t it?</p>'
    assert_text_output "This is a link with an at sign in it isn’t it?"
  end

  test_given_govspeak "
    HTML

    *[HTML]: Hyper Text Markup Language" do
    assert_html_output %(<p><abbr title="Hyper Text Markup Language">HTML</abbr></p>)
    assert_text_output "HTML"
  end

  test_given_govspeak "x[a link](http://rubyforge.org)x" do
    assert_html_output '<p><a href="http://rubyforge.org" rel="external">a link</a></p>'
    assert_text_output "a link"
  end

  test_given_govspeak "x[an xx link](http://x.com)x" do
    assert_html_output '<p><a href="http://x.com" rel="external">an xx link</a></p>'
  end

  test_given_govspeak "[internal link](http://www.gov.uk)" do
    assert_html_output '<p><a href="http://www.gov.uk">internal link</a></p>'
  end

  test_given_govspeak "[link with no host is assumed to be internal](/)" do
    assert_html_output '<p><a href="/">link with no host is assumed to be internal</a></p>'
  end

  test_given_govspeak "[internal link with rel attribute keeps it](http://www.gov.uk){:rel='next'}" do
    assert_html_output '<p><a href="http://www.gov.uk" rel="next">internal link with rel attribute keeps it</a></p>'
  end

  test_given_govspeak "[external link without x markers](http://www.google.com)" do
    assert_html_output '<p><a rel="external" href="http://www.google.com">external link without x markers</a></p>'
  end

  # Based on Kramdown inline attribute list (IAL) test:
  # https://github.com/gettalong/kramdown/blob/627978525cf5ee5b290d8a1b8675aae9cc9e2934/test/testcases/span/01_link/link_defs_with_ial.text
  test_given_govspeak "External link definitions with [attr] and [attr 2] and [attr 3] and [attr before]\n\n[attr]: http://example.com 'title'\n{: hreflang=\"en\" .test}\n\n[attr 2]: http://example.com 'title'\n{: hreflang=\"en\"}\n{: .test}\n\n[attr 3]: http://example.com\n{: .test}\ntest\n\n{: hreflang=\"en\"}\n{: .test}\n[attr before]: http://example.com" do
    assert_html_output "<p>External link definitions with <a rel=\"external\" hreflang=\"en\" class=\"test\" href=\"http://example.com\" title=\"title\">attr</a> and <a rel=\"external\" hreflang=\"en\" class=\"test\" href=\"http://example.com\" title=\"title\">attr 2</a> and <a rel=\"external\" class=\"test\" href=\"http://example.com\">attr 3</a> and <a rel=\"external\" hreflang=\"en\" class=\"test\" href=\"http://example.com\">attr before</a></p>\n\n<p>test</p>"
  end

  test_given_govspeak "External link with [inline attribute list] (IAL)\n\n[inline attribute list]: http://example.com 'title'\n{: hreflang=\"en\" .test}" do
    assert_html_output '<p>External link with <a rel="external" hreflang="en" class="test" href="http://example.com" title="title">inline attribute list</a> (IAL)</p>'
  end

  test_given_govspeak "[external link with rel attribute](http://www.google.com){:rel='next'}" do
    assert_html_output '<p><a rel="next" href="http://www.google.com">external link with rel attribute</a></p>'
  end

  test_given_govspeak "Text before [an external link](http://www.google.com)" do
    assert_html_output '<p>Text before <a rel="external" href="http://www.google.com">an external link</a></p>'
  end

  test_given_govspeak "[An external link](http://www.google.com) with text afterwards" do
    assert_html_output '<p><a rel="external" href="http://www.google.com">An external link</a> with text afterwards</p>'
  end

  test_given_govspeak "Text before [an external link](http://www.google.com) and text afterwards" do
    assert_html_output '<p>Text before <a rel="external" href="http://www.google.com">an external link</a> and text afterwards</p>'
  end

  test_given_govspeak "![image with external url](http://www.example.com/image.jpg)" do
    assert_html_output '<p><img src="http://www.example.com/image.jpg" alt="image with external url"></p>'
  end

  test "should be able to override default 'document_domains' option" do
    html = Govspeak::Document.new("[internal link](http://www.not-external.com)", document_domains: %w[www.not-external.com]).to_html
    refute html.include?('rel="external"'), "should not consider www.not-external.com as an external url"
  end

  test "should be able to supply multiple domains for 'document_domains' option" do
    html = Govspeak::Document.new("[internal link](http://www.not-external-either.com)", document_domains: %w[www.not-external.com www.not-external-either.com]).to_html
    refute html.include?('rel="external"'), "should not consider www.not-external-either.com as an external url"
  end

  test "should be able to override default 'input' option" do
    html = Govspeak::Document.new("[external link](http://www.external.com)", input: "kramdown").to_html
    refute html.include?('rel="external"'), "should not automatically add rel external attribute"
  end

  test "should not be able to override default 'entity output' option" do
    html = Govspeak::Document.new("&gt;", entity_output: :numeric).to_html
    assert html.include?("&gt;")
  end

  test "should assume a link with an invalid uri is internal" do
    html = Govspeak::Document.new("[link](:invalid-uri)").to_html
    refute html.include?('rel="external"')
  end

  test "should treat a mailto as internal" do
    html = Govspeak::Document.new("[link](mailto:a@b.com)").to_html
    refute html.include?('rel="external"')
    assert_equal %(<p><a href="mailto:a@b.com">link</a></p>\n), deobfuscate_mailto(html)
  end

  test "permits mailto:// URI" do
    html = Govspeak::Document.new("[link](mailto://a@b.com)").to_html
    assert_equal %(<p><a rel="external" href="mailto://a@b.com">link</a></p>\n), deobfuscate_mailto(html)
  end

  test "permits dud mailto: URI" do
    html = Govspeak::Document.new("[link](mailto:)").to_html
    assert_equal %(<p><a href="mailto:">link</a></p>\n), deobfuscate_mailto(html)
  end

  test "permits trailing whitespace in an URI" do
    Govspeak::Document.new("[link](http://example.com/%20)").to_html
  end

  # Regression test - the surrounded_by helper doesn't require the closing x
  # so 'xaa' was getting picked up by the external link helper above
  # TODO: review whether we should require closing symbols for these extensions
  #       need to check all existing content.
  test_given_govspeak "xaa" do
    assert_html_output "<p>xaa</p>"
    assert_text_output "xaa"
  end

  test_given_govspeak "
    $!
    rainbow
    $!" do
    assert_html_output %(
      <div class="summary">
      <p>rainbow</p>
      </div>)
    assert_text_output "rainbow"
  end

  test_given_govspeak "$C help, send cake $C" do
    assert_html_output %(
      <div class="contact">
      <p>help, send cake</p>
      </div>)
    assert_text_output "help, send cake"
  end

  test_given_govspeak "
    $A
    street
    road
    $A" do
    assert_html_output %(
      <div class="address"><div class="adr org fn"><p>
      street<br>road
      </p></div></div>)
    assert_text_output "street road"
  end

  test_given_govspeak "
    $A
    street with ACRONYM
    road
    $A

    *[ACRONYM]: This is the acronym explanation" do
    assert_html_output %(
      <div class="address"><div class="adr org fn"><p>
      street with <abbr title="This is the acronym explanation">ACRONYM</abbr><br>road
      </p></div></div>)
  end

  test_given_govspeak "
    $P
    $I
    help
    $I
    $P" do
    assert_html_output %(<div class="place">\n\n<div class="information">\n<p>help</p>\n</div>\n</div>)
    assert_text_output "help"
  end

  test_given_govspeak "
    $D
    can you tell me how to get to...
    $D" do
    assert_html_output %(
      <div class="form-download">
      <p>can you tell me how to get to…</p>
      </div>)
    assert_text_output "can you tell me how to get to…"
  end

  test_given_govspeak "
    $CTA
    Click here to start the tool
    $CTA" do
    assert_html_output %(
      <div class="call-to-action">
        <p>Click here to start the tool</p>
      </div>)
    assert_text_output "Click here to start the tool"
  end

  test_given_govspeak "
    $CTA Click here to start the program $CTA

    Here is some text" do
    assert_html_output %(
      <div class="call-to-action">
        <p>Click here to start the program</p>
      </div>

      <p>Here is some text</p>)
  end

  test_given_govspeak "
    Some text

    $CTA     Click there to start the program     $CTA

    Here is some text" do
    assert_html_output %(
      <p>Some text</p>
      <div class="call-to-action">
        <p>Click there to start the program</p>
      </div>

      <p>Here is some text</p>)
  end

  test_given_govspeak "
    Some text

    $CTAClick anywhere to start the program$CTA

    Here is some text" do
    assert_html_output %(
      <p>Some text</p>
      <div class="call-to-action">
        <p>Click anywhere to start the program</p>
      </div>

      <p>Here is some text</p>)
  end

  test_given_govspeak "
      $CTA
      |Heading 1|Heading 2|
      |-|-|
      |information|more information|
      $CTA" do
    assert_html_output %(
        <div class="call-to-action">

        <table>
          <thead>
            <tr>
              <th scope="col">Heading 1</th>
              <th scope="col">Heading 2</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>information</td>
              <td>more information</td>
            </tr>
          </tbody>
        </table>

      </div>)
  end

  test_given_govspeak "
      $CTA

      ### A heading within the CTA

      |Heading 1|Heading 2|
      |-|-|
      |information|more information|

      $CTA" do
    assert_html_output %(
      <div class="call-to-action">
      <h3 id="a-heading-within-the-cta">A heading within the CTA</h3>

      <table>
        <thead>
          <tr>
            <th scope="col">Heading 1</th>
            <th scope="col">Heading 2</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>information</td>
            <td>more information</td>
          </tr>
        </tbody>
      </table>

    </div>)
  end

  test_given_govspeak "
    Here is some text\n

    $CTA
    Click here to start the tool
    $CTA
    " do
    assert_html_output %(
      <p>Here is some text</p>

      <div class="call-to-action">
        <p>Click here to start the tool</p>
      </div>)
  end

  test_given_govspeak "
    $CTA

    This is a test:

    s1. This is number 1.
    s2. This is number 2.
    s3. This is number 3.
    s4. This is number 4.

    $CTA" do
    assert_html_output %(
        <div class="call-to-action">
          <p>This is a test:</p>

          <ol class="steps">
        <li>
        <p>This is number 1.</p>
        </li>
        <li>
        <p>This is number 2.</p>
        </li>
        <li>
        <p>This is number 3.</p>
        </li>
        <li>
        <p>This is number 4.</p>
        </li>
        </ol>
        </div>
        )
  end

  test_given_govspeak "
    $CTA
    [external link](http://www.external.com) some text
    $CTA
    " do
    assert_html_output %(
      <div class="call-to-action">
        <p><a rel="external" href="http://www.external.com">external link</a> some text</p>
      </div>)
  end

  test_given_govspeak "
    $CTA
    [internal link](http://www.not-external.com) some text
    $CTA", document_domains: %w[www.not-external.com] do
    assert_html_output %(
      <div class="call-to-action">
        <p><a href="http://www.not-external.com">internal link</a> some text</p>
      </div>)
  end

  test_given_govspeak "
    $CTA
    Click here to start the tool
    $CTA

    $C
    Here is some text
    $C
    " do
    assert_html_output %(
      <div class="call-to-action">
        <p>Click here to start the tool</p>
      </div>

      <div class="contact">
      <p>Here is some text</p>
      </div>)
  end

  test_given_govspeak "
    [internal link](http://www.not-external.com)\n

    $CTA
    Click here to start the tool
    $CTA", document_domains: %w[www.not-external.com] do
    assert_html_output %(
      <p><a href="http://www.not-external.com">internal link</a></p>

      <div class="call-to-action">
        <p>Click here to start the tool</p>
      </div>)
  end

  test_given_govspeak "
    $CTA
    Click here to start the tool[^1]
    $CTA
    [^1]: Footnote definition one
    " do
    assert_html_output %(
      <div class="call-to-action">
        <p>Click here to start the tool<sup id="fnref:1"><a href="#fn:1" class="footnote" rel="footnote" role="doc-noteref">[footnote 1]</a></sup></p>
      </div>
      <div class="footnotes" role="doc-endnotes">
        <ol>
          <li id="fn:1">
            <p>Footnote definition one <a href="#fnref:1" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
        </ol>
      </div>
    )
  end

  test_given_govspeak "
    $CTA
    Lorem ipsum dolor sit amet, consectetur adipiscing elit.
    Fusce felis ante[^1], lobortis non quam sit amet, tempus interdum justo.
    $CTA
    $CTA
    Pellentesque quam enim, egestas sit amet congue sit amet[^2], ultrices vitae arcu.
    Fringilla, metus dui scelerisque est.
    $CTA
    [^1]: Footnote definition one
    [^2]: Footnote definition two
    " do
    assert_html_output %(
      <div class="call-to-action">
        <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.
      Fusce felis ante<sup id="fnref:1"><a href="#fn:1" class="footnote" rel="footnote" role="doc-noteref">[footnote 1]</a></sup>, lobortis non quam sit amet, tempus interdum justo.</p>
      </div>
      <div class="call-to-action">
        <p>Pellentesque quam enim, egestas sit amet congue sit amet<sup id="fnref:2"><a href="#fn:2" class="footnote" rel="footnote" role="doc-noteref">[footnote 2]</a></sup>, ultrices vitae arcu.
      Fringilla, metus dui scelerisque est.</p>
      </div>
      <div class="footnotes" role="doc-endnotes">
        <ol>
          <li id="fn:1">
            <p>Footnote definition one <a href="#fnref:1" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
          <li id="fn:2">
            <p>Footnote definition two <a href="#fnref:2" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
        </ol>
      </div>
    )
  end

  test_given_govspeak "
    $CTA
    Click here to start the tool[^1]
    $CTA

    Lorem ipsum dolor sit amet[^2]

    [^1]: Footnote definition 1
    [^2]: Footnote definition 2
    " do
    assert_html_output %(
      <div class="call-to-action">
        <p>Click here to start the tool<sup id="fnref:1"><a href="#fn:1" class="footnote" rel="footnote" role="doc-noteref">[footnote 1]</a></sup></p>
      </div>

      <p>Lorem ipsum dolor sit amet<sup id="fnref:2"><a href="#fn:2" class="footnote" rel="footnote" role="doc-noteref">[footnote 2]</a></sup></p>

      <div class="footnotes" role="doc-endnotes">
        <ol>
          <li id="fn:1">
            <p>Footnote definition 1 <a href="#fnref:1" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
          <li id="fn:2">
            <p>Footnote definition 2 <a href="#fnref:2" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
        </ol>
      </div>
    )
  end

  test_given_govspeak "
    $CTA
    Contact the SGD on 0800 000 0000 or contact the class on 0800 001 0001
    $CTA

    *[class]: Other Government Department
    *[SGD]: Some Government Department
    " do
    assert_html_output %(
      <div class="call-to-action">
        <p>Contact the <abbr title="Some Government Department">SGD</abbr> on 0800 000 0000 or contact the <abbr title="Other Government Department">class</abbr> on 0800 001 0001</p>
      </div>
    )
  end

  test_given_govspeak "
    $CTA
    Welcome to the GOV.UK website
    $CTA

    *[GOV.UK]: The official UK government website
    *[website]: A collection of web pages, such as GOV.UK
    " do
    assert_html_output %(
      <div class="call-to-action">
        <p>Welcome to the <abbr title="The official UK government website">GOV.UK</abbr> <abbr title="A collection of web pages, such as GOV.UK">website</abbr></p>
      </div>
    )
  end

  test_given_govspeak "
    $CTA
    Please email <developer@digital.cabinet-office.GOV.UK>
    $CTA

    *[GOV.UK]: The official UK government website
    " do
    assert_html_output %(
      <div class="call-to-action">
        <p>Please email <a href="mailto:developer@digital.cabinet-office.GOV.UK">developer@digital.cabinet-office.<abbr title="The official UK government website">GOV.UK</abbr></a></p>
      </div>
    )
  end

  test_given_govspeak "
    $CTA
    Welcome to the GOV.UK[^1]
    $CTA

    [^1]: GOV.UK is the official UK government website

    *[GOV.UK]: The official UK government website
    *[website]: A collection of web pages, such as GOV.UK

    *[GOV.UK]: The official UK government website
    " do
    assert_html_output %(
      <div class="call-to-action">
        <p>Welcome to the <abbr title="The official UK government website">GOV.UK</abbr><sup id="fnref:1"><a href="#fn:1" class="footnote" rel="footnote" role="doc-noteref">[footnote 1]</a></sup></p>
      </div>

      <div class="footnotes" role="doc-endnotes">
        <ol>
          <li id="fn:1">
            <p><abbr title="The official UK government website">GOV.UK</abbr> is the official UK government <abbr title="A collection of web pages, such as GOV.UK">website</abbr> <a href="#fnref:1" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
        </ol>
      </div>
    )
  end

  test "CTA with image" do
    given_govspeak "
    $CTA
    [Image:image-id]
    $CTA

    Some text
    ", images: [build_image] do
      assert_html_output %(
      <div class="call-to-action">
        <figure class="image embedded"><div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div></figure>
      </div>

      <p>Some text</p>
    )
    end
  end

  test_given_govspeak "
    1. rod
    2. jane
    3. freddy" do
    assert_html_output "<ol>\n  <li>rod</li>\n  <li>jane</li>\n  <li>freddy</li>\n</ol>"
    assert_text_output "rod jane freddy"
  end

  test_given_govspeak "
    s1. zippy
    s2. bungle
    s3. george
    " do
    assert_html_output %(
      <ol class="steps">
      <li>
      <p>zippy</p>
      </li>
      <li>
      <p>bungle</p>
      </li>
      <li>
      <p>george</p>
      </li>
      </ol>)
    assert_text_output "zippy bungle george"
  end

  test_given_govspeak "
    - unordered
    - list

    s1. step
    s2. list
    " do
    assert_html_output %(
      <ul>
        <li>unordered</li>
        <li>list</li>
      </ul>

      <ol class="steps">
      <li>
      <p>step</p>
      </li>
      <li>
      <p>list</p>
      </li>
      </ol>)
    assert_text_output "unordered list step list"
  end

  test_given_govspeak "
    $LegislativeList
    * 1.0 Lorem ipsum dolor sit amet, consectetur adipiscing elit.
      Fusce felis ante, lobortis non quam sit amet, tempus interdum justo.

      Pellentesque quam enim, egestas sit amet congue sit amet, ultrices vitae arcu.
      fringilla, metus dui scelerisque est.

      * a) A list item

      * b) Another list item

    * 1.1 Second entry
      Curabitur pretium pharetra sapien, a feugiat arcu euismod eget.
      Nunc luctus ornare varius. Nulla scelerisque, justo dictum dapibus
    $EndLegislativeList
  " do
    assert_html_output %{
    <div class="legislative-list-wrapper">
      <ol class="legislative-list">
        <li>
          <p>1.0 Lorem ipsum dolor sit amet, consectetur adipiscing elit.
    Fusce felis ante, lobortis non quam sit amet, tempus interdum justo.</p>

          <p>Pellentesque quam enim, egestas sit amet congue sit amet, ultrices vitae arcu.
    fringilla, metus dui scelerisque est.</p>

          <ol>
            <li>
              <p>a) A list item</p>
            </li>
            <li>
              <p>b) Another list item</p>
            </li>
          </ol>
        </li>
        <li>
          <p>1.1 Second entry
    Curabitur pretium pharetra sapien, a feugiat arcu euismod eget.
    Nunc luctus ornare varius. Nulla scelerisque, justo dictum dapibus</p>
        </li>
      </ol>
    </div>}
  end

  test_given_govspeak "
    $LegislativeList
    * 1. The quick
    * 2. Brown fox
      * a) Jumps over
      * b) The lazy
    * 3. Dog
    $EndLegislativeList
  " do
    assert_html_output %{
    <div class="legislative-list-wrapper">
      <ol class="legislative-list">
        <li>1. The quick</li>
        <li>2. Brown fox
          <ol>
            <li>a) Jumps over</li>
            <li>b) The lazy</li>
          </ol>
        </li>
        <li>3. Dog</li>
      </ol>
    </div>
    }
  end

  test_given_govspeak "
    $LegislativeList
    * 1. Item 1[^1]
    * 2. Item 2[^2]
    * 3. Item 3
    $EndLegislativeList

    [^1]: Footnote definition one
    [^2]: Footnote definition two
  " do
    assert_html_output %(
    <div class="legislative-list-wrapper">
      <ol class="legislative-list">
        <li>1. Item 1<sup id="fnref:1"><a href="#fn:1" class="footnote" rel="footnote" role="doc-noteref">[footnote 1]</a></sup>
    </li>
        <li>2. Item 2<sup id="fnref:2"><a href="#fn:2" class="footnote" rel="footnote" role="doc-noteref">[footnote 2]</a></sup>
    </li>
        <li>3. Item 3</li>
      </ol>
    </div>

    <div class="footnotes" role="doc-endnotes">
      <ol>
        <li id="fn:1">
          <p>Footnote definition one <a href="#fnref:1" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
        </li>
        <li id="fn:2">
          <p>Footnote definition two <a href="#fnref:2" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
        </li>
      </ol>
    </div>
    )
  end

  test_given_govspeak "
    $LegislativeList
    * 1. Item 1[^1]
    * 2. Item 2
    * 3. Item 3
    $EndLegislativeList

    This is a paragraph with a footnote[^2].

    $LegislativeList
    * 1. Item 1
    * 2. Item 2[^3]
    * 3. Item 3
    $EndLegislativeList

    [^1]: Footnote definition one
    [^2]: Footnote definition two
    [^3]: Footnote definition two
  " do
    assert_html_output %(
    <div class="legislative-list-wrapper">
      <ol class="legislative-list">
        <li>1. Item 1<sup id="fnref:1"><a href="#fn:1" class="footnote" rel="footnote" role="doc-noteref">[footnote 1]</a></sup>
    </li>
        <li>2. Item 2</li>
        <li>3. Item 3</li>
      </ol>
    </div>

    <p>This is a paragraph with a footnote<sup id="fnref:2"><a href="#fn:2" class="footnote" rel="footnote" role="doc-noteref">[footnote 2]</a></sup>.</p>

    <div class="legislative-list-wrapper">
      <ol class="legislative-list">
        <li>1. Item 1</li>
        <li>2. Item 2<sup id="fnref:3"><a href="#fn:3" class="footnote" rel="footnote" role="doc-noteref">[footnote 3]</a></sup>
    </li>
        <li>3. Item 3</li>
      </ol>
    </div>

    <div class="footnotes" role="doc-endnotes">
      <ol>
        <li id="fn:1">
          <p>Footnote definition one <a href="#fnref:1" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
        </li>
        <li id="fn:2">
          <p>Footnote definition two <a href="#fnref:2" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
        </li>
        <li id="fn:3">
          <p>Footnote definition two <a href="#fnref:3" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
        </li>
      </ol>
    </div>
    )
  end

  test_given_govspeak "
    $LegislativeList
    * 1. Item 1[^1]
    * 2. Item 2[^2]
    * 3. Item 3[^3]
    $EndLegislativeList

    This is a paragraph with a footnote[^4].

    $LegislativeList
    * 1. Item 1[^5]
    * 2. Item 2[^6]
    * 3. Item 3[^7]
    $EndLegislativeList

    This is a paragraph with a footnote[^8].

    $LegislativeList
    * 1. Item 1[^9]
    * 2. Item 2[^10]
    * 3. Item 3[^11]
    $EndLegislativeList

    This is a paragraph with a footnote[^12].

    [^1]: Footnote definition 1
    [^2]: Footnote definition 2
    [^3]: Footnote definition 3
    [^4]: Footnote definition 4
    [^5]: Footnote definition 5
    [^6]: Footnote definition 6
    [^7]: Footnote definition 7
    [^8]: Footnote definition 8
    [^9]: Footnote definition 9
    [^10]: Footnote definition 10
    [^11]: Footnote definition 11
    [^12]: Footnote definition 12
  " do
    assert_html_output %(
      <div class="legislative-list-wrapper">
        <ol class="legislative-list">
          <li>1. Item 1<sup id="fnref:1"><a href="#fn:1" class="footnote" rel="footnote" role="doc-noteref">[footnote 1]</a></sup>
      </li>
          <li>2. Item 2<sup id="fnref:2"><a href="#fn:2" class="footnote" rel="footnote" role="doc-noteref">[footnote 2]</a></sup>
      </li>
          <li>3. Item 3<sup id="fnref:3"><a href="#fn:3" class="footnote" rel="footnote" role="doc-noteref">[footnote 3]</a></sup>
      </li>
        </ol>
      </div>

      <p>This is a paragraph with a footnote<sup id="fnref:4"><a href="#fn:4" class="footnote" rel="footnote" role="doc-noteref">[footnote 4]</a></sup>.</p>

      <div class="legislative-list-wrapper">
        <ol class="legislative-list">
          <li>1. Item 1<sup id="fnref:5"><a href="#fn:5" class="footnote" rel="footnote" role="doc-noteref">[footnote 5]</a></sup>
      </li>
          <li>2. Item 2<sup id="fnref:6"><a href="#fn:6" class="footnote" rel="footnote" role="doc-noteref">[footnote 6]</a></sup>
      </li>
          <li>3. Item 3<sup id="fnref:7"><a href="#fn:7" class="footnote" rel="footnote" role="doc-noteref">[footnote 7]</a></sup>
      </li>
        </ol>
      </div>

      <p>This is a paragraph with a footnote<sup id="fnref:8"><a href="#fn:8" class="footnote" rel="footnote" role="doc-noteref">[footnote 8]</a></sup>.</p>

      <div class="legislative-list-wrapper">
        <ol class="legislative-list">
          <li>1. Item 1<sup id="fnref:9"><a href="#fn:9" class="footnote" rel="footnote" role="doc-noteref">[footnote 9]</a></sup>
      </li>
          <li>2. Item 2<sup id="fnref:10"><a href="#fn:10" class="footnote" rel="footnote" role="doc-noteref">[footnote 10]</a></sup>
      </li>
          <li>3. Item 3<sup id="fnref:11"><a href="#fn:11" class="footnote" rel="footnote" role="doc-noteref">[footnote 11]</a></sup>
      </li>
        </ol>
      </div>

      <p>This is a paragraph with a footnote<sup id="fnref:12"><a href="#fn:12" class="footnote" rel="footnote" role="doc-noteref">[footnote 12]</a></sup>.</p>

      <div class="footnotes" role="doc-endnotes">
        <ol>
          <li id="fn:1">
            <p>Footnote definition 1 <a href="#fnref:1" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
          <li id="fn:2">
            <p>Footnote definition 2 <a href="#fnref:2" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
          <li id="fn:3">
            <p>Footnote definition 3 <a href="#fnref:3" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
          <li id="fn:4">
            <p>Footnote definition 4 <a href="#fnref:4" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
          <li id="fn:5">
            <p>Footnote definition 5 <a href="#fnref:5" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
          <li id="fn:6">
            <p>Footnote definition 6 <a href="#fnref:6" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
          <li id="fn:7">
            <p>Footnote definition 7 <a href="#fnref:7" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
          <li id="fn:8">
            <p>Footnote definition 8 <a href="#fnref:8" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
          <li id="fn:9">
            <p>Footnote definition 9 <a href="#fnref:9" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
          <li id="fn:10">
            <p>Footnote definition 10 <a href="#fnref:10" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
          <li id="fn:11">
            <p>Footnote definition 11 <a href="#fnref:11" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
          <li id="fn:12">
            <p>Footnote definition 12 <a href="#fnref:12" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
        </ol>
      </div>
    )
  end

  test_given_govspeak "
    $LegislativeList
    * 1. Item 1[^1] with a [link](http://www.gov.uk)
    * 2. Item 2
    * 3. Item 3
    $EndLegislativeList

    This is a paragraph with a footnote[^2]

    [^1]: Footnote definition one
    [^2]: Footnote definition two
  " do
    assert_html_output %(
    <div class="legislative-list-wrapper">
      <ol class="legislative-list">
        <li>1. Item 1<sup id="fnref:1"><a href="#fn:1" class="footnote" rel="footnote" role="doc-noteref">[footnote 1]</a></sup> with a <a href="http://www.gov.uk">link</a>
    </li>
        <li>2. Item 2</li>
        <li>3. Item 3</li>
      </ol>
    </div>

    <p>This is a paragraph with a footnote<sup id="fnref:2"><a href="#fn:2" class="footnote" rel="footnote" role="doc-noteref">[footnote 2]</a></sup></p>

    <div class="footnotes" role="doc-endnotes">
      <ol>
        <li id="fn:1">
          <p>Footnote definition one <a href="#fnref:1" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
        </li>
        <li id="fn:2">
          <p>Footnote definition two <a href="#fnref:2" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
        </li>
      </ol>
    </div>
    )
  end

  test_given_govspeak "
    $LegislativeList
    * 1. Item 1[^1] with a [link](http://www.gov.uk)
    * 2. Item 2
    * 3. Item 3[^2]
    $EndLegislativeList

    [^1]: Footnote definition one with a [link](http://www.gov.uk) included
    [^2]: Footnote definition two with an external [link](http://www.google.com)
  " do
    assert_html_output %(
    <div class="legislative-list-wrapper">
      <ol class="legislative-list">
        <li>1. Item 1<sup id="fnref:1"><a href="#fn:1" class="footnote" rel="footnote" role="doc-noteref">[footnote 1]</a></sup> with a <a href="http://www.gov.uk">link</a>
    </li>
        <li>2. Item 2</li>
        <li>3. Item 3<sup id="fnref:2"><a href="#fn:2" class="footnote" rel="footnote" role="doc-noteref">[footnote 2]</a></sup>
    </li>
      </ol>
    </div>

    <div class="footnotes" role="doc-endnotes">
      <ol>
        <li id="fn:1">
          <p>Footnote definition one with a <a href="http://www.gov.uk">link</a> included <a href="#fnref:1" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
        </li>
        <li id="fn:2">
          <p>Footnote definition two with an external <a rel="external" href="http://www.google.com">link</a> <a href="#fnref:2" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
        </li>
      </ol>
    </div>
    )
  end

  test_given_govspeak "
    $LegislativeList
    1.  some text[^1]:
    $EndLegislativeList
    [^1]: footnote text
  " do
    assert_html_output %(
     <div class="legislative-list-wrapper">
       <p>1.  some text<sup id="fnref:1"><a href="#fn:1" class="footnote" rel="footnote" role="doc-noteref">[footnote 1]</a></sup>:</p>
     </div>

     <div class="footnotes" role="doc-endnotes">
       <ol>
         <li id="fn:1">
           <p>footnote text <a href="#fnref:1" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
         </li>
       </ol>
     </div>
    )
  end

  test_given_govspeak "
    $LegislativeList
    1.  some text[^1]: extra
    $EndLegislativeList
    [^1]: footnote text
    " do
      assert_html_output %(
      <div class="legislative-list-wrapper">
        <p>1.  some text<sup id="fnref:1"><a href="#fn:1" class="footnote" rel="footnote" role="doc-noteref">[footnote 1]</a></sup>: extra</p>
      </div>

      <div class="footnotes" role="doc-endnotes">
        <ol>
          <li id="fn:1">
            <p>footnote text <a href="#fnref:1" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
        </ol>
      </div>
    )
    end

  test_given_govspeak "
    $E
    This is an ACRONYM.
    $E

    *[ACRONYM]: This is the acronym explanation
  " do
    assert_html_output %(
      <div class="example">
        <p>This is an <abbr title="This is the acronym explanation">ACRONYM</abbr>.</p>
      </div>
    )
  end

  test_given_govspeak "
    $E
    |Heading 1|Heading 2|
    |-|-|
    |information|more information|
    $E" do
    assert_html_output %(
    <div class="example">

    <table>
      <thead>
        <tr>
          <th scope="col">Heading 1</th>
          <th scope="col">Heading 2</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>information</td>
          <td>more information</td>
        </tr>
      </tbody>
    </table>

  </div>)
  end

  test_given_govspeak "
    $E

    ### A heading within an example

    Some example content

    $E" do
    assert_html_output %(
    <div class="example">
    <h3 id="a-heading-within-an-example">A heading within an example</h3>

    <p>Some example content</p>
  </div>)
  end

  test_given_govspeak "
    $LegislativeList
    * 1. Item 1[^1] with an ACRONYM
    * 2. Item 2[^2]
    * 3. Item 3[^3]
    $EndLegislativeList

    [^1]: Footnote definition one
    [^2]: Footnote definition two with an ACRONYM
    [^3]: Footnote definition three with an acronym that matches an HTML tag class

    *[ACRONYM]: This is the acronym explanation
    *[class]: Testing HTML matching
  " do
    assert_html_output %(
      <div class="legislative-list-wrapper">
        <ol class="legislative-list">
          <li>1. Item 1<sup id="fnref:1"><a href="#fn:1" class="footnote" rel="footnote" role="doc-noteref">[footnote 1]</a></sup> with an <abbr title="This is the acronym explanation">ACRONYM</abbr>
      </li>
          <li>2. Item 2<sup id="fnref:2"><a href="#fn:2" class="footnote" rel="footnote" role="doc-noteref">[footnote 2]</a></sup>
      </li>
          <li>3. Item 3<sup id="fnref:3"><a href="#fn:3" class="footnote" rel="footnote" role="doc-noteref">[footnote 3]</a></sup>
      </li>
        </ol>
      </div>

      <div class="footnotes" role="doc-endnotes">
        <ol>
          <li id="fn:1">
            <p>Footnote definition one <a href="#fnref:1" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
          <li id="fn:2">
            <p>Footnote definition two with an <abbr title="This is the acronym explanation">ACRONYM</abbr> <a href="#fnref:2" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
          <li id="fn:3">
            <p>Footnote definition three with an acronym that matches an HTML tag <abbr title="Testing HTML matching">class</abbr> <a href="#fnref:3" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
        </ol>
      </div>
    )
  end

  test_given_govspeak "
    The quick brown
    $LegislativeList
    * 1. fox jumps over
  " do
    assert_html_output "
    <p>The quick brown
    $LegislativeList
    * 1. fox jumps over</p>"
  end

  test_given_govspeak "
    The quick brown fox

    $LegislativeList
    * 1. jumps over the lazy dog
    $EndLegislativeList
  " do
    assert_html_output %(
      <p>The quick brown fox</p>

      <div class="legislative-list-wrapper">
        <ol class="legislative-list">
          <li>1. jumps over the lazy dog</li>
        </ol>
      </div>
    )
  end

  test_given_govspeak "This bit of text\r\n\r\n$LegislativeList\r\n* 1. should be turned into a list\r\n$EndLegislativeList" do
    assert_html_output %(
      <p>This bit of text</p>

      <div class="legislative-list-wrapper">
        <ol class="legislative-list">
          <li>1. should be turned into a list</li>
        </ol>
      </div>
    )
  end

  test_given_govspeak "
    $LegislativeList
    Welcome to the GOV.UK website
    $EndLegislativeList

    *[GOV.UK]: The official UK government website
    *[website]: A collection of web pages, such as GOV.UK
    " do
    assert_html_output %(
      <div class="legislative-list-wrapper">
        <p>Welcome to the <abbr title="The official UK government website">GOV.UK</abbr> <abbr title="A collection of web pages, such as GOV.UK">website</abbr></p>
      </div>
    )
  end

  test_given_govspeak "
    $LegislativeList
    Please email <developer@digital.cabinet-office.GOV.UK>
    $EndLegislativeList

    *[GOV.UK]: The official UK government website
  " do
    assert_html_output %(
      <div class="legislative-list-wrapper">
        <p>Please email <a href="mailto:developer@digital.cabinet-office.GOV.UK">developer@digital.cabinet-office.<abbr title="The official UK government website">GOV.UK</abbr></a></p>
      </div>
    )
  end

  test_given_govspeak "
    $LegislativeList
    Welcome to the GOV.UK[^1]
    $EndLegislativeList

    [^1]: GOV.UK is the official UK government website

    *[GOV.UK]: The official UK government website
    *[website]: A collection of web pages, such as GOV.UK

    *[GOV.UK]: The official UK government website
    " do
    assert_html_output %(
      <div class="legislative-list-wrapper">
        <p>Welcome to the <abbr title="The official UK government website">GOV.UK</abbr><sup id="fnref:1"><a href="#fn:1" class="footnote" rel="footnote" role="doc-noteref">[footnote 1]</a></sup></p>
      </div>

      <div class="footnotes" role="doc-endnotes">
        <ol>
          <li id="fn:1">
            <p><abbr title="The official UK government website">GOV.UK</abbr> is the official UK government <abbr title="A collection of web pages, such as GOV.UK">website</abbr> <a href="#fnref:1" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
        </ol>
      </div>
    )
  end

  test "LegislativeList with image" do
    given_govspeak "
    $LegislativeList
    [Image:image-id]
    $EndLegislativeList

    Some text
    ", images: [build_image] do
      assert_html_output %(
      <div class="legislative-list-wrapper">
        <figure class="image embedded"><div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div></figure>
      </div>

      <p>Some text</p>
    )
    end
  end

  test_given_govspeak "
    Zippy, Bungle and George did not qualify for the tax exemption in s428. They filled in their tax return accordingly.
    " do
    assert_html_output %(
      <p>Zippy, Bungle and George did not qualify for the tax exemption in s428. They filled in their tax return accordingly.</p>
    )
  end

  test_given_govspeak ":scotland: I am very devolved\n and very scottish \n:scotland:" do
    assert_html_output '
      <div class="devolved-content scotland">
      <p class="devolved-header">This section applies to Scotland</p>
      <div class="devolved-body">
      <p>I am very devolved
       and very scottish</p>
      </div>
      </div>
      '
  end

  test "sanitize source input by default" do
    document = Govspeak::Document.new("<script>doBadThings();</script>")
    assert_equal "", document.to_html.strip
  end

  test "it can have sanitizing disabled" do
    document = Govspeak::Document.new("<script>doGoodThings();</script>", sanitize: false)
    assert_equal "<script>doGoodThings();</script>", document.to_html.strip
  end

  test "it can exclude stipulated elements from sanitization" do
    document = Govspeak::Document.new("<uncommon-element>some content</uncommon-element>", allowed_elements: %w[uncommon-element])
    assert_equal "<uncommon-element>some content</uncommon-element>", document.to_html.strip
  end

  test "identifies a Govspeak document containing malicious HTML as invalid" do
    document = Govspeak::Document.new("<script>doBadThings();</script>")
    refute document.valid?
  end

  test "identifies a Govspeak document containing acceptable HTML as valid" do
    document = Govspeak::Document.new("<div>some content</div>")
    assert document.valid?
  end

  test "should remove quotes surrounding a blockquote" do
    govspeak = %(
He said:

> "I'm not sure what you mean!"

Or so we thought.)

    given_govspeak(govspeak) do
      assert_html_output %(
        <p>He said:</p>

        <blockquote>
          <p class="last-child">I’m not sure what you mean!</p>
        </blockquote>

        <p>Or so we thought.</p>
      )
    end
  end

  test "should add class to last paragraph of blockquote" do
    govspeak = "
    > first line
    >
    > last line"

    given_govspeak(govspeak) do
      assert_html_output %(
        <blockquote>
          <p>first line</p>

          <p class="last-child">last line</p>
        </blockquote>
      )
    end
  end
end
