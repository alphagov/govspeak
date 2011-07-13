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
  
end