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
output: "<div class=\"application-notice info-notice\">
<p>I am very informational</p>
</div>"
},
{
input: "^ I am very informational",
output: "<div class=\"application-notice info-notice\">
<p>I am very informational</p>
</div>"
},
{
input: "@ I am very important @",
output: "<h3 class=\"advisory\"><span>I am very important</span></h3>"
}, {
input: "% I am very helpful %",
output:  "<div class=\"application-notice help-notice\">
<p>I am very helpful</p>
</div>"
}, {
input: "## Hello ##\n\n% I am very helpful %\r\n### Young Workers ###\n\n",
output:  "<h2 id=\"hello\">Hello</h2>

<div class=\"application-notice help-notice\">
<p>I am very helpful</p>
</div>

<h3 id=\"young-workers\">Young Workers</h3>"
},
{
input: "% I am very helpful",
output: "<div class=\"application-notice help-notice\">
<p>I am very helpful</p>
</div>"
},
input: "I am very [helpful] yes I am.",
output: '<p>I am very <em class="glossary" title="See glossary">helpful</em> yes I am.</p>'

]
  
  markdown_regression_tests.each do |t|
    rendered = Govspeak::Document.new(t[:input]).to_html
    assert_equal t[:output].strip, rendered.strip
  end
  
  end
  
  test "numbered list extension" do
    input = "1. Blah
2. Blah blah
3. Blah blah blah"
    output = "<div class=\"answer-step\">
<p class=\"step-label\"><span class=\"step-number\">1</span><span class=\"step-total\">of 3</span></p>
<p>Blah</p>
<p class=\"step-label\"><span class=\"step-number\">2</span><span class=\"step-total\">of 3</span></p>
<p>Blah blah</p>
<p class=\"step-label\"><span class=\"step-number\">3</span><span class=\"step-total\">of 3</span></p>
<p>Blah blah blah</p>
</div>
"
    assert_equal output, Govspeak::Document.new(input).to_html
  end
  
  test "devolved markdown sections" do
    input =  ":scotland: I am very devolved \n and very scottish \n:/scotland:"
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