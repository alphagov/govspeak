require 'test_helper'

class GovspeakTest < Test::Unit::TestCase
  
  test "simple smoke-test" do
    rendered =  Govspeak::Document.new("*this is markdown*").to_html
    assert_equal "<p><em>this is markdown</em></p>\n", rendered
  end
  
end