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

  test "simple block extension" do
    rendered =  Govspeak::Document.new("this \n{::reverse}\n*is*\n{:/reverse}\n markdown").to_html
    assert_equal "<p>this </p>\n\n<p><em>si</em></p>\n\n<p>markdown</p>\n", rendered
  end

  test "govspark extensions" do
    markdown_regression_tests = [
{
  input: "^ I am very informational ^",
  output: %{<div class="application-notice info-notice">
<p>I am very informational</p>
</div>}
}, {
  input: "The following is very informational\n^ I am very informational ^",
  output: %{<p>The following is very informational</p>

<div class="application-notice info-notice">
<p>I am very informational</p>
</div>}
}, {
  input: "^ I am very informational",
  output: %{<div class="application-notice info-notice">
<p>I am very informational</p>
</div>}
}, {
  input: "@ I am very important @",
  output: %{<h3 class="advisory"><span>I am very important</span></h3>}
}, {
  input: "The following is very important
@ I am very important @",
  output: %{<p>The following is very important</p>

<h3 class="advisory"><span>I am very important</span></h3>}
}, {
  input: "% I am very helpful %",
  output:  %{<div class="application-notice help-notice">
<p>I am very helpful</p>
</div>}
}, {
  input: "The following is very helpful\n% I am very helpful %",
  output:  %{<p>The following is very helpful</p>

<div class="application-notice help-notice">
<p>I am very helpful</p>
</div>}
}, {
  input: "## Hello ##\n\n% I am very helpful %\r\n### Young Workers ###\n\n",
  output:  %{<h2 id="hello">Hello</h2>

<div class="application-notice help-notice">
<p>I am very helpful</p>
</div>

<h3 id="young-workers">Young Workers</h3>}
}, {
  input: "% I am very helpful",
  output: %{<div class="application-notice help-notice">
<p>I am very helpful</p>
</div>}
}, {
  input: "This is a [link](http://www.google.com) isn't it?",
  output: '<p>This is a <a href="http://www.google.com">link</a> isn&rsquo;t it?</p>'
}, {
  input: "This is a [link with an at sign in it](http://www.google.com/@dg/@this) isn't it?",
  output: '<p>This is a <a href="http://www.google.com/@dg/@this">link with an at sign in it</a> isn&rsquo;t it?</p>'
}, {
  input: "HTML

  *[HTML]: Hyper Text Markup Language",
  output: %{<p><abbr title="Hyper Text Markup Language">HTML</abbr></p>}
}, {
  input: "x[a link](http://rubyforge.org)x",
  output: '<p><a href="http://rubyforge.org" rel="external">a link</a></p>'
}, {
  input: "$!
rainbow
$!",
  output: %{<div class="summary">
<p>rainbow</p>
</div>}
}, {
  input: "$C help, send cake $C",
  output: %{<div class="contact">
<p>help, send cake</p>
</div>}
}, {
  input: "$A
street
road
$A",
  output: %{<div class="address vcard"><div class="adr org fn"><p>
street<br />road<br />
</p></div></div>}
}, {
  input: "$P
$I
help
$I
$P",
  output: %{<div class="place">\n<div class="information">\n<p>help</p>\n</div>\n</div>}
}, {
  input: "$D
can you tell me how to get to...
$D",
  output: %{<div class="form-download">
<p>can you tell me how to get to&hellip;</p>
</div>}
}, {
  input: "1. rod
2. jane
3. freddy",
  output: "<ol>\n  <li>rod</li>\n  <li>jane</li>\n  <li>freddy</li>\n</ol>"
}, {
  input: "
((http://maps.google.co.uk/maps?q=Winkfield+Rd,+Windsor,+Berkshire+SL4+4AY&hl=en&sll=53.800651,-4.064941&sspn=17.759517,42.055664&vpsrc=0&z=14))
",
  output: %{<div class="map"><iframe width="200" height="200" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="http://maps.google.co.uk/maps?q=Winkfield+Rd,+Windsor,+Berkshire+SL4+4AY&amp;hl=en&amp;sll=53.800651,-4.064941&amp;sspn=17.759517,42.055664&amp;vpsrc=0&amp;z=14&amp;output=embed"></iframe><br /><small><a href="http://maps.google.co.uk/maps?q=Winkfield+Rd,+Windsor,+Berkshire+SL4+4AY&amp;hl=en&amp;sll=53.800651,-4.064941&amp;sspn=17.759517,42.055664&amp;vpsrc=0&amp;z=14">View Larger Map</a></small></div>}
}, {
  input: "s1. zippy
s2. bungle
s3. george
",
  output: %{<ol class="steps">
<li><p>zippy</p>\n</li>
<li><p>bungle</p>\n</li>
<li><p>george</p>\n</li>
</ol>}
}
]

markdown_regression_tests.each do |t|
  rendered = Govspeak::Document.new(t[:input]).to_html
  assert_equal t[:output].strip, rendered.strip
end

end

test "devolved markdown sections" do
    input =  ":scotland: I am very devolved \n and very scottish \n:scotland:"
    output = '<div class="devolved-content scotland">
<p class="devolved-header">This section applies to Scotland</p>
<div class="devolved-body"><p>I am very devolved 
 and very scottish</p>
</div>
</div>
'

  assert_equal output, Govspeak::Document.new(input).to_html
end

end
