# encoding: UTF-8

require 'test_helper'

class GovspeakCannedContentTest < Minitest::Test
  include GovspeakTestHelper

  def compress_html(html)
    html.gsub(/[\n\r]+[\s]*/, '')
  end

  test "canned content shows" do
    govspeak = "[CannedContent:4f3383e4-48a2-4461-a41d-f85ea8b89ba0]"
    rendered = Govspeak::Document.new(govspeak, {}).to_html

    expected_html_output = (
        %{<p>} +
        %{This is a canned content.} +
        %{</p>}
      )

    assert_equal(compress_html(expected_html_output), compress_html(rendered))
  end
end
