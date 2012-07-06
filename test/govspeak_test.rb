# encoding: UTF-8

require 'simplecov'
require 'simplecov-rcov'

SimpleCov.start
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter

require 'test_helper'
require 'govspeak_test_helper'

require 'ostruct'

class GovspeakTest < Test::Unit::TestCase
  include GovspeakTestHelper

  test "simple smoke-test" do
    rendered =  Govspeak::Document.new("*this is markdown*").to_html
    assert_equal "<p><em>this is markdown</em></p>\n", rendered
  end

  test "simple smoke-test for simplified API" do
    rendered =  Govspeak::Document.to_html("*this is markdown*")
    assert_equal "<p><em>this is markdown</em></p>\n", rendered
  end

  test "simple block extension" do
    rendered =  Govspeak::Document.new("this \n{::reverse}\n*is*\n{:/reverse}\n markdown").to_html
    assert_equal "<p>this </p>\n\n<p><em>si</em></p>\n\n<p>markdown</p>\n", rendered
  end

  test "highlight-answer block extension" do
    rendered =  Govspeak::Document.new("this \n{::highlight-answer}Lead in to *BIG TEXT*\n{:/highlight-answer}").to_html
    assert_equal %Q{<p>this </p>\n\n<div class="highlight-answer">\n<p>Lead in to <em>BIG TEXT</em></p>\n</div>\n}, rendered
  end

  test "extracts headers with text, level and generated id" do
    document =  Govspeak::Document.new %{
# Big title

### Small subtitle

## Medium title
}
    assert_equal [
      Govspeak::Header.new('Big title', 1, 'big-title'),
      Govspeak::Header.new('Small subtitle', 3, 'small-subtitle'),
      Govspeak::Header.new('Medium title', 2, 'medium-title')
    ], document.headers
  end

  test "extracts different ids for duplicate headers" do
    document =  Govspeak::Document.new("## Duplicate header\n\n## Duplicate header")
    assert_equal [
      Govspeak::Header.new('Duplicate header', 2, 'duplicate-header'),
      Govspeak::Header.new('Duplicate header', 2, 'duplicate-header-1')
    ], document.headers
  end

  test "extracts text with no HTML and normalised spacing" do
    input = "# foo\n\nbar    baz  "
    doc = Govspeak::Document.new(input)
    assert_equal "foo bar baz", doc.to_text
  end

  test "trailing space after the address should not prevent parsing" do
    input = %{$A
123 Test Street
Testcase Cliffs
Teston
0123 456 7890 $A    }
    doc = Govspeak::Document.new(input)
    assert_equal %{<div class="address"><div class="adr org fn"><p>\n123 Test Street<br />Testcase Cliffs<br />Teston<br />0123 456 7890 \n</p></div></div>\n}, doc.to_html
  end

  test_given_govspeak("^ I am very informational ^") do
    assert_html_output %{
      <div class="application-notice info-notice">
      <p>I am very informational</p>
      </div>}
    assert_text_output "I am very informational"
  end

  test "processing an extension does not modify the provided input" do
    input = "^ I am very informational"
    Govspeak::Document.new(input).to_html
    assert_equal "^ I am very informational", input
  end

  test_given_govspeak "The following is very informational\n^ I am very informational ^" do
    assert_html_output %{
      <p>The following is very informational</p>

      <div class="application-notice info-notice">
      <p>I am very informational</p>
      </div>}
    assert_text_output "The following is very informational I am very informational"
  end

  test_given_govspeak "^ I am very informational" do
    assert_html_output %{
      <div class="application-notice info-notice">
      <p>I am very informational</p>
      </div>}
    assert_text_output "I am very informational"
  end

  test_given_govspeak "@ I am very important @" do
    assert_html_output %{
      <div class="advisory"><p><strong>I am very important</strong></p>
      </div>}
    assert_text_output "I am very important"
  end

  test_given_govspeak "
    The following is very important
    @ I am very important @
    " do
    assert_html_output %{
      <p>The following is very important</p>

      <div class="advisory"><p><strong>I am very important</strong></p>
      </div>}
    assert_text_output "The following is very important I am very important"
  end

  test_given_govspeak "% I am very helpful %" do
    assert_html_output %{
      <div class="application-notice help-notice">
      <p>I am very helpful</p>
      </div>}
    assert_text_output "I am very helpful"
  end

  test_given_govspeak "The following is very helpful\n% I am very helpful %" do
    assert_html_output %{
      <p>The following is very helpful</p>

      <div class="application-notice help-notice">
      <p>I am very helpful</p>
      </div>}
    assert_text_output "The following is very helpful I am very helpful"
  end

  test_given_govspeak "## Hello ##\n\n% I am very helpful %\r\n### Young Workers ###\n\n" do
    assert_html_output %{
      <h2 id="hello">Hello</h2>

      <div class="application-notice help-notice">
      <p>I am very helpful</p>
      </div>

      <h3 id="young-workers">Young Workers</h3>}
    assert_text_output "Hello I am very helpful Young Workers"
  end

  test_given_govspeak "% I am very helpful" do
    assert_html_output %{
      <div class="application-notice help-notice">
      <p>I am very helpful</p>
      </div>}
    assert_text_output "I am very helpful"
  end

  test_given_govspeak "This is a [link](http://www.gov.uk) isn't it?" do
    assert_html_output '<p>This is a <a href="http://www.gov.uk">link</a> isn&rsquo;t it?</p>'
    assert_text_output "This is a link isn’t it?"
  end

  test_given_govspeak "This is a [link with an at sign in it](http://www.gov.uk/@dg/@this) isn't it?" do
    assert_html_output '<p>This is a <a href="http://www.gov.uk/@dg/@this">link with an at sign in it</a> isn&rsquo;t it?</p>'
    assert_text_output "This is a link with an at sign in it isn’t it?"
  end

  test_given_govspeak "
    HTML

    *[HTML]: Hyper Text Markup Language" do
    assert_html_output %{<p><abbr title="Hyper Text Markup Language">HTML</abbr></p>}
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

  test "should be able to override default 'document_domains' option" do
    html = Govspeak::Document.new("[internal link](http://www.not-external.com)", document_domains: %w(www.not-external.com)).to_html
    refute html.include?('rel="external"'), "should not consider www.not-external.com as an external url"
  end

  test "should be able to supply multiple domains for 'document_domains' option" do
    html = Govspeak::Document.new("[internal link](http://www.not-external-either.com)", document_domains: %w(www.not-external.com www.not-external-either.com)).to_html
    refute html.include?('rel="external"'), "should not consider www.not-external-either.com as an external url"
  end

  test "should be able to override default 'input' option" do
    html = Govspeak::Document.new("[external link](http://www.external.com)", input: "kramdown").to_html
    refute html.include?('rel="external"'), "should not automatically add rel external attribute"
  end

  test "should be able to override default 'entity output' option" do
    html = Govspeak::Document.new("&amp;", entity_output: :numeric).to_html
    assert html.include?("&#38;")
  end

  test "should be assume link with invalid uri is internal" do
    html = Govspeak::Document.new("[link](:invalid-uri)").to_html
    refute html.include?('rel="external"')
  end

  test "should be assume link with invalid uri component is internal" do
    html = Govspeak::Document.new("[link](mailto://www.example.com)").to_html
    refute html.include?('rel="external"')
  end

  # Regression test - the surrounded_by helper doesn't require the closing x
  # so 'xaa' was getting picked up by the external link helper above
  # TODO: review whether we should require closing symbols for these extensions
  #       need to check all existing content.
  test_given_govspeak "xaa" do
    assert_html_output '<p>xaa</p>'
    assert_text_output "xaa"
  end

  test_given_govspeak "
    $!
    rainbow
    $!" do
    assert_html_output %{
      <div class="summary">
      <p>rainbow</p>
      </div>}
    assert_text_output "rainbow"
  end

  test_given_govspeak "$C help, send cake $C" do
    assert_html_output %{
      <div class="contact">
      <p>help, send cake</p>
      </div>}
    assert_text_output "help, send cake"
  end

  test_given_govspeak "
    $A
    street
    road
    $A" do
    assert_html_output %{
      <div class="address"><div class="adr org fn"><p>
      street<br />road<br />
      </p></div></div>}
    assert_text_output "street road"
  end

  test_given_govspeak "
    $P
    $I
    help
    $I
    $P" do
    assert_html_output %{<div class="place">\n<div class="information">\n<p>help</p>\n</div>\n</div>}
    assert_text_output "help"
  end

  test_given_govspeak "
    $D
    can you tell me how to get to...
    $D" do
    assert_html_output %{
      <div class="form-download">
      <p>can you tell me how to get to…</p>
      </div>}
    assert_text_output "can you tell me how to get to…"
  end

  test_given_govspeak "
    1. rod
    2. jane
    3. freddy" do
    assert_html_output "<ol>\n  <li>rod</li>\n  <li>jane</li>\n  <li>freddy</li>\n</ol>"
    assert_text_output "rod jane freddy"
  end

  test_given_govspeak "
((http://maps.google.co.uk/maps?q=Winkfield+Rd,+Windsor,+Berkshire+SL4+4AY&hl=en&sll=53.800651,-4.064941&sspn=17.759517,42.055664&vpsrc=0&z=14))
" do
    assert_html_output %{<div class="map"><iframe width="200" height="200" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="http://maps.google.co.uk/maps?q=Winkfield+Rd,+Windsor,+Berkshire+SL4+4AY&amp;hl=en&amp;sll=53.800651,-4.064941&amp;sspn=17.759517,42.055664&amp;vpsrc=0&amp;z=14&amp;output=embed"></iframe><br /><small><a href="http://maps.google.co.uk/maps?q=Winkfield+Rd,+Windsor,+Berkshire+SL4+4AY&amp;hl=en&amp;sll=53.800651,-4.064941&amp;sspn=17.759517,42.055664&amp;vpsrc=0&amp;z=14">View Larger Map</a></small></div>}
    assert_text_output "View Larger Map"
  end

  test_given_govspeak "
    s1. zippy
    s2. bungle
    s3. george
    " do
    assert_html_output %{
      <ol class="steps">
      <li><p>zippy</p>
      </li>
      <li><p>bungle</p>
      </li>
      <li><p>george</p>
      </li>
      </ol>}
    assert_text_output "zippy bungle george"
  end

  test_given_govspeak ":scotland: I am very devolved\n and very scottish \n:scotland:" do
    assert_html_output '
      <div class="devolved-content scotland">
      <p class="devolved-header">This section applies to Scotland</p>
      <div class="devolved-body"><p>I am very devolved
       and very scottish</p>
      </div>
      </div>
      '
  end

  test_given_govspeak "@ Message with [a link](http://foo.bar/)@" do
    assert_html_output %{
      <div class="advisory"><p><strong>Message with <a href="http://foo.bar/">a link</a></strong></p>
      </div>
      }
  end

  test "can reference attached images using !!n" do
    images = [OpenStruct.new(alt_text: 'my alt', url: "http://example.com/image.jpg")]
    given_govspeak "!!1", images do
      assert_html_output %Q{
          <figure class="image embedded">
            <div class="img"><img alt="my alt" src="http://example.com/image.jpg" /></div>
          </figure>
        }
    end
  end

  test "alt text of referenced images is escaped" do
    images = [OpenStruct.new(alt_text: %Q{my alt '&"<>}, url: "http://example.com/image.jpg")]
    given_govspeak "!!1", images do
      assert_html_output %Q{
          <figure class="image embedded">
            <div class="img"><img alt="my alt &apos;&amp;&quot;&lt;&gt;" src="http://example.com/image.jpg" /></div>
          </figure>
        }
    end
  end

  test "silently ignores an image attachment if the referenced image is missing" do
    doc = Govspeak::Document.new("!!1")
    doc.images = []

    assert_equal %Q{\n}, doc.to_html
  end

  test "adds image caption if given" do
    images = [OpenStruct.new(alt_text: "my alt", url: "http://example.com/image.jpg", caption: 'My Caption & so on')]
    given_govspeak "!!1", images do
      assert_html_output %Q{
          <figure class="image embedded">
            <div class="img"><img alt="my alt" src="http://example.com/image.jpg" /></div>
            <figcaption>My Caption &amp; so on</figcaption>
          </figure>
        }
    end
  end

  test "ignores a blank caption" do
    images = [OpenStruct.new(alt_text: "my alt", url: "http://example.com/image.jpg", caption: '  ')]
    given_govspeak "!!1", images do
      assert_html_output %Q{
          <figure class="image embedded">
            <div class="img"><img alt="my alt" src="http://example.com/image.jpg" /></div>
          </figure>
        }
    end
  end

end
