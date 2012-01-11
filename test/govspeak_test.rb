# encoding: UTF-8

require 'simplecov'
require 'simplecov-rcov'

SimpleCov.start
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter

require 'test_helper'

class GovspeakTest < Test::Unit::TestCase

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

  test "govspark extensions" do
    markdown_regression_tests = [
{
  input: "^ I am very informational ^",
  output: %{<div class="application-notice info-notice">
<p>I am very informational</p>
</div>},
  text: "I am very informational"
}, {
  input: "The following is very informational\n^ I am very informational ^",
  output: %{<p>The following is very informational</p>

<div class="application-notice info-notice">
<p>I am very informational</p>
</div>},
  text: "The following is very informational I am very informational"
}, {
  input: "^ I am very informational",
  output: %{<div class="application-notice info-notice">
<p>I am very informational</p>
</div>},
  text: "I am very informational"
}, {
  input: "@ I am very important @",
  output: %{<div class="advisory"><p><strong>I am very important</strong></p>
</div>},
  text: "I am very important"
}, {
  input: "The following is very important
@ I am very important @",
  output: %{<p>The following is very important</p>

<div class="advisory"><p><strong>I am very important</strong></p>
</div>},
  text: "The following is very important I am very important"
}, {
  input: "% I am very helpful %",
  output:  %{<div class="application-notice help-notice">
<p>I am very helpful</p>
</div>},
  text: "I am very helpful"
}, {
  input: "The following is very helpful\n% I am very helpful %",
  output:  %{<p>The following is very helpful</p>

<div class="application-notice help-notice">
<p>I am very helpful</p>
</div>},
  text: "The following is very helpful I am very helpful"
}, {
  input: "## Hello ##\n\n% I am very helpful %\r\n### Young Workers ###\n\n",
  output:  %{<h2 id="hello">Hello</h2>

<div class="application-notice help-notice">
<p>I am very helpful</p>
</div>

<h3 id="young-workers">Young Workers</h3>},
  text: "Hello I am very helpful Young Workers"
}, {
  input: "% I am very helpful",
  output: %{<div class="application-notice help-notice">
<p>I am very helpful</p>
</div>},
  text: "I am very helpful"
}, {
  input: "This is a [link](http://www.google.com) isn't it?",
  output: '<p>This is a <a href="http://www.google.com">link</a> isn&rsquo;t it?</p>',
  text: "This is a link isn’t it?"
}, {
  input: "This is a [link with an at sign in it](http://www.google.com/@dg/@this) isn't it?",
  output: '<p>This is a <a href="http://www.google.com/@dg/@this">link with an at sign in it</a> isn&rsquo;t it?</p>',
  text: "This is a link with an at sign in it isn’t it?"
}, {
  input: "HTML

  *[HTML]: Hyper Text Markup Language",
  output: %{<p><abbr title="Hyper Text Markup Language">HTML</abbr></p>},
  text: "HTML"
}, {
  input: "x[a link](http://rubyforge.org)x",
  output: '<p><a href="http://rubyforge.org" rel="external">a link</a></p>',
  text: "a link"
}, {
  input: "$!
rainbow
$!",
  output: %{<div class="summary">
<p>rainbow</p>
</div>},
  text: "rainbow"
}, {
  input: "$C help, send cake $C",
  output: %{<div class="contact">
<p>help, send cake</p>
</div>},
  text: "help, send cake"
}, {
  input: "$A
street
road
$A",
  output: %{<div class="address vcard"><div class="adr org fn"><p>
street<br />road<br />
</p></div></div>},
  text: "street road"
}, {
  input: "$P
$I
help
$I
$P",
  output: %{<div class="place">\n<div class="information">\n<p>help</p>\n</div>\n</div>},
  text: "help"
}, {
  input: "$D
can you tell me how to get to...
$D",
  output: %{<div class="form-download">
<p>can you tell me how to get to…</p>
</div>},
  text: "can you tell me how to get to…"
}, {
  input: "1. rod
2. jane
3. freddy",
  output: "<ol>\n  <li>rod</li>\n  <li>jane</li>\n  <li>freddy</li>\n</ol>",
  text: "rod jane freddy"
}, {
  input: "
((http://maps.google.co.uk/maps?q=Winkfield+Rd,+Windsor,+Berkshire+SL4+4AY&hl=en&sll=53.800651,-4.064941&sspn=17.759517,42.055664&vpsrc=0&z=14))
",
  output: %{<div class="map"><iframe width="200" height="200" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="http://maps.google.co.uk/maps?q=Winkfield+Rd,+Windsor,+Berkshire+SL4+4AY&amp;hl=en&amp;sll=53.800651,-4.064941&amp;sspn=17.759517,42.055664&amp;vpsrc=0&amp;z=14&amp;output=embed"></iframe><br /><small><a href="http://maps.google.co.uk/maps?q=Winkfield+Rd,+Windsor,+Berkshire+SL4+4AY&amp;hl=en&amp;sll=53.800651,-4.064941&amp;sspn=17.759517,42.055664&amp;vpsrc=0&amp;z=14">View Larger Map</a></small></div>},
  text: "View Larger Map"
}, {
  input: "s1. zippy
s2. bungle
s3. george
",
  output: %{<ol class="steps">
<li><p>zippy</p>\n</li>
<li><p>bungle</p>\n</li>
<li><p>george</p>\n</li>
</ol>},
  text: "zippy bungle george"
}
]

  markdown_regression_tests.each do |t|
    doc = Govspeak::Document.new(t[:input])
    assert_equal t[:output].strip, doc.to_html.strip
    assert_equal t[:text], doc.to_text
  end

end

test "devolved markdown sections" do
    input =  ":scotland: I am very devolved\n and very scottish \n:scotland:"
    output = '<div class="devolved-content scotland">
<p class="devolved-header">This section applies to Scotland</p>
<div class="devolved-body"><p>I am very devolved
 and very scottish</p>
</div>
</div>
'

  assert_equal output, Govspeak::Document.new(input).to_html
end         

test "links inside markdown boxes" do
  input = "@ Message with [a link](http://foo.bar/)@"
  output = %{
<div class="advisory"><p><strong>Message with <a href="http://foo.bar/">a link</a></strong></p>
</div>
}  
  
  assert_equal output, Govspeak::Document.new(input).to_html
end

end
