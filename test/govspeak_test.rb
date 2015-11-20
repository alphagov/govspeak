# encoding: UTF-8

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

  test "stat-headline block extension" do
    rendered =  Govspeak::Document.new("this \n{stat-headline}*13.8bn* Age of the universe in years{/stat-headline}").to_html
    assert_equal %Q{<p>this </p>\n\n<aside class="stat-headline">\n<p><em>13.8bn</em> Age of the universe in years</p>\n</aside>\n}, rendered
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
    assert_equal %{\n<div class="address"><div class="adr org fn"><p>\n123 Test Street<br />Testcase Cliffs<br />Teston<br />0123 456 7890 \n</p></div></div>\n}, doc.to_html
  end

  test "address div is separated from paragraph text by a couple of line-breaks" do
    # else kramdown processes address div as part of paragraph text and escapes HTML
    input = %{Paragraph1

$A
123 Test Street
Testcase Cliffs
Teston
0123 456 7890 $A}
    doc = Govspeak::Document.new(input)
    assert_equal %{<p>Paragraph1</p>\n\n<div class="address"><div class="adr org fn"><p>\n123 Test Street<br />Testcase Cliffs<br />Teston<br />0123 456 7890 \n</p></div></div>\n}, doc.to_html
  end

  test_given_govspeak("^ I am very informational ^") do
    assert_html_output %{
      <div role="note" aria-label="Information" class="application-notice info-notice">
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

      <div role="note" aria-label="Information" class="application-notice info-notice">
      <p>I am very informational</p>
      </div>}
    assert_text_output "The following is very informational I am very informational"
  end

  test_given_govspeak "^ I am very informational" do
    assert_html_output %{
      <div role="note" aria-label="Information" class="application-notice info-notice">
      <p>I am very informational</p>
      </div>}
    assert_text_output "I am very informational"
  end

  test_given_govspeak "@ I am very important @" do
    assert_html_output %{
      <div role="note" aria-label="Important" class="advisory"><p><strong>I am very important</strong></p>
      </div>}
    assert_text_output "I am very important"
  end

  test_given_govspeak "
    The following is very important
    @ I am very important @
    " do
    assert_html_output %{
      <p>The following is very important</p>

      <div role="note" aria-label="Important" class="advisory"><p><strong>I am very important</strong></p>
      </div>}
    assert_text_output "The following is very important I am very important"
  end

  test_given_govspeak "% I am very helpful %" do
    assert_html_output %{
      <div role="note" aria-label="Help" class="application-notice help-notice">
      <p>I am very helpful</p>
      </div>}
    assert_text_output "I am very helpful"
  end

  test_given_govspeak "The following is very helpful\n% I am very helpful %" do
    assert_html_output %{
      <p>The following is very helpful</p>

      <div role="note" aria-label="Help" class="application-notice help-notice">
      <p>I am very helpful</p>
      </div>}
    assert_text_output "The following is very helpful I am very helpful"
  end

  test_given_govspeak "## Hello ##\n\n% I am very helpful %\r\n### Young Workers ###\n\n" do
    assert_html_output %{
      <h2 id="hello">Hello</h2>

      <div role="note" aria-label="Help" class="application-notice help-notice">
      <p>I am very helpful</p>
      </div>

      <h3 id="young-workers">Young Workers</h3>}
    assert_text_output "Hello I am very helpful Young Workers"
  end

  test_given_govspeak "% I am very helpful" do
    assert_html_output %{
      <div role="note" aria-label="Help" class="application-notice help-notice">
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

  test_given_govspeak "![image with external url](http://www.example.com/image.jpg)" do
    assert_html_output '<p><img src="http://www.example.com/image.jpg" alt="image with external url" /></p>'
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
    html = Govspeak::Document.new("&yen;", entity_output: :numeric).to_html
    assert html.include?("&#165;")
  end

  test "should assume a link with an invalid uri is internal" do
    html = Govspeak::Document.new("[link](:invalid-uri)").to_html
    refute html.include?('rel="external"')
  end

  test "should treat a mailto as internal" do
    html = Govspeak::Document.new("[link](mailto:a@b.com)").to_html
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
    assert_html_output %{<div class="place">\n\n<div class="information">\n<p>help</p>\n</div>\n</div>}
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
    $CTA
    Click here to start the tool
    $CTA" do
    assert_html_output %{
      <div class="call-to-action">
      <p>Click here to start the tool</p>
      </div>}
    assert_text_output "Click here to start the tool"
  end

  test_given_govspeak "Here is some text

$CTA
Click here to start the tool
$CTA
    " do
    assert_html_output %{
      <p>Here is some text</p>

      <div class="call-to-action">
      <p>Click here to start the tool</p>
      </div>}
  end

  test_given_govspeak "
    [internal link](http://www.not-external.com)

    $CTA
    Click here to start the tool
    $CTA", [], document_domains: %w(www.not-external.com) do
    assert_html_output %{
      <p><a href="http://www.not-external.com">internal link</a></p>

      <div class="call-to-action">
      <p>Click here to start the tool</p>
      </div>}
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

  test_given_govspeak "
    - unordered
    - list

    s1. step
    s2. list
    " do
    assert_html_output %{
      <ul>
        <li>unordered</li>
        <li>list</li>
      </ul>

      <ol class="steps">
      <li><p>step</p>
      </li>
      <li><p>list</p>
      </li>
      </ol>}
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
      </ol>}
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
    }
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
    assert_html_output %{
      <p>The quick brown fox</p>

      <ol class="legislative-list">
        <li>1. jumps over the lazy dog</li>
      </ol>
    }
  end

  test_given_govspeak "This bit of text\r\n\r\n$LegislativeList\r\n* 1. should be turned into a list\r\n$EndLegislativeList" do
    assert_html_output %{
      <p>This bit of text</p>

      <ol class="legislative-list">
        <li>1. should be turned into a list</li>
      </ol>
    }
  end

  test_given_govspeak "
    Zippy, Bungle and George did not qualify for the tax exemption in s428. They filled in their tax return accordingly.
    " do
    assert_html_output %{
      <p>Zippy, Bungle and George did not qualify for the tax exemption in s428. They filled in their tax return accordingly.</p>
    }
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
      <div role="note" aria-label="Important" class="advisory"><p><strong>Message with <a rel="external" href="http://foo.bar/">a link</a></strong></p>
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

  test "can sanitize a document" do
    document = Govspeak::Document.new("<script>doBadThings();</script>")
    assert_equal "doBadThings();", document.to_sanitized_html.strip
  end

  test "can sanitize a document without image" do
    document = Govspeak::Document.new("<script>doBadThings();</script><img src='https://example.com/image.jpg'>")
    assert_equal "doBadThings();<p></p>", document.to_sanitized_html_without_images.gsub(/\s/, "")
  end

  test "identifies a Govspeak document containing malicious HTML as invalid" do
    document = Govspeak::Document.new("<script>doBadThings();</script>")
    refute document.valid?
  end

  test "identifies a Govspeak document containing acceptable HTML as valid" do
    document = Govspeak::Document.new("<div>some content</div>")
    assert document.valid?
  end

  expected_priority_list_output = %|
    <ul>
      <li class="primary-item">List item 1</li>
      <li class="primary-item">List item 2</li>
      <li class="primary-item">List item 3</li>
      <li>List item 4</li>
      <li>List item 5</li>
    </ul>
  |

  test "Single priority list ending with EOF" do
    govspeak = "$PriorityList:3
 * List item 1
 * List item 2
 * List item 3
 * List item 4
 * List item 5"

    given_govspeak(govspeak) do
      assert_html_output(expected_priority_list_output)
    end
  end

  test "Single priority list ending with newlines" do
    govspeak = "$PriorityList:3
* List item 1
* List item 2
* List item 3
* List item 4
* List item 5

"

    given_govspeak(govspeak) do
      assert_html_output(expected_priority_list_output)
    end
  end

  test 'Single priority list with \n newlines' do
    govspeak = "$PriorityList:3\n * List item 1\n * List item 2\n * List item 3\n * List item 4\n * List item 5"

    given_govspeak(govspeak) do
      assert_html_output(expected_priority_list_output)
    end
  end

  test 'Single priority list with \r\n newlines' do
    govspeak = "$PriorityList:3\r\n * List item 1\r\n * List item 2\r\n * List item 3\r\n * List item 4\r\n * List item 5"

    given_govspeak(govspeak) do
      assert_html_output(expected_priority_list_output)
    end
  end


  test "Multiple priority lists" do
    govspeak = "
$PriorityList:3
* List item 1
* List item 2
* List item 3
* List item 4
* List item 5

$PriorityList:1
* List item 1
* List item 2"

    given_govspeak(govspeak) do
      assert_html_output %|
        <ul>
          <li class="primary-item">List item 1</li>
          <li class="primary-item">List item 2</li>
          <li class="primary-item">List item 3</li>
          <li>List item 4</li>
          <li>List item 5</li>
        </ul>

        <ul>
          <li class="primary-item">List item 1</li>
          <li>List item 2</li>
        </ul>
      |
    end
  end

  test "Priority list placed incorrectly" do
    govspeak = "
    This is a paragraph
    $PriorityList:3
    * List item 1
    * List item 2
    * List item 3
    * List item 4
    * List item 5"

    given_govspeak(govspeak) do
      assert_html_output("
      <p>This is a paragraph
      $PriorityList:3
      * List item 1
      * List item 2
      * List item 3
      * List item 4
      * List item 5</p>")
    end
  end

  test "Priority list placed correctly" do
    govspeak = "
    This is a paragraph

    $PriorityList:3
    * List item 1
    * List item 2
    * List item 3
    * List item 4
    * List item 5"

    given_govspeak(govspeak) do
      assert_html_output %|
        <p>This is a paragraph</p>

        <ul>
          <li class="primary-item">List item 1</li>
          <li class="primary-item">List item 2</li>
          <li class="primary-item">List item 3</li>
          <li>List item 4</li>
          <li>List item 5</li>
        </ul>
      |
    end
  end
end
