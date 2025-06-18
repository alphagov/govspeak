require "test_helper"
require "govspeak_test_helper"

class GovspeakImagesTest < Minitest::Test
  include GovspeakTestHelper
  extend Minitest::Spec::DSL

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

  test "renders okay with no space after the opening tag" do
    given_govspeak("^I am very informational") do
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

  describe "support for nested Kramdown" do
    test "supports headings" do
      given_govspeak "^ ## I am an informational heading" do
        assert_html_output %(
        <div role="note" aria-label="Information" class="application-notice info-notice">
          <h2 id="i-am-an-informational-heading">I am an informational heading</h2>
        </div>)
        assert_text_output "I am an informational heading"
      end
    end

    test "supports abbreviations" do
      given_govspeak "^ I am very informational

  Live, love, informational

  *[informational]: do with it what you will
      " do
        assert_html_output %(
          <div role="note" aria-label="Information" class="application-notice info-notice">
            <p>I am very <abbr title="do with it what you will">informational</abbr></p>
          </div>

          <p>Live, love, <abbr title="do with it what you will">informational</abbr></p>)
        assert_text_output "I am very informational Live, love, informational"
      end
    end

    test "supports links" do
      given_govspeak "^ [My informational link](https://www.gov.uk)" do
        assert_html_output %(
          <div role="note" aria-label="Information" class="application-notice info-notice">
            <p><a href="https://www.gov.uk">My informational link</a></p>
          </div>
        )
        assert_text_output "My informational link"
      end
    end

    test "supports bold emphasis" do
      given_govspeak "^ I am **very** informational" do
        assert_html_output %(
          <div role="note" aria-label="Information" class="application-notice info-notice">
            <p>I am <strong>very</strong> informational</p>
          </div>
        )
        assert_text_output "I am very informational"
      end
    end
  end
end
