require "test_helper"
require "govspeak_test_helper"

class GovspeakImagesTest < Minitest::Test
  include GovspeakTestHelper

  test "renders okay with just an opening tag" do
    given_govspeak "^ I am very informational" do
      assert_html_output %(
        <div role="note" aria-label="Information" class="application-notice info-notice">
        <p>I am very informational</p>
        </div>)
      assert_text_output "I am very informational"
    end
  end

  test "renders okay with opening and closing tags" do
    given_govspeak("^ I am very informational ^") do
      assert_html_output %(
        <div role="note" aria-label="Information" class="application-notice info-notice">
        <p>I am very informational</p>
        </div>)
      assert_text_output "I am very informational"
    end
  end

  test "avoids combining into a single block with an immediately-preceding line" do
    given_govspeak "The following is very informational\n^ I am very informational ^" do
      assert_html_output %(
        <p>The following is very informational</p>

        <div role="note" aria-label="Information" class="application-notice info-notice">
        <p>I am very informational</p>
        </div>)
      assert_text_output "The following is very informational I am very informational"
    end
  end
end
