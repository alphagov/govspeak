require "test_helper"
require "govspeak_test_helper"

require "ostruct"

class GovspeakTest < Minitest::Test
  include GovspeakTestHelper

  test_given_govspeak "{cards}[Benefits](https://www.gov.uk/browse/benefits){/cards}" do
    assert_html_selector ".gem-c-cards.gem-c-cards--auto-layout"
    assert_html_selector 'a.gem-c-cards__link[href="https://www.gov.uk/browse/benefits"]'
    assert_text_output "Benefits"
  end

  # The same as above but with line breaks
  test_given_govspeak "{cards}\n\n\n[Benefits](https://www.gov.uk/browse/benefits)\n\n\n{/cards}" do
    assert_html_selector 'a.gem-c-cards__link[href="https://www.gov.uk/browse/benefits"]'
    assert_text_output "Benefits"
  end

  test_given_govspeak "{cards}\n[Benefits](https://www.gov.uk/browse/benefits)\n[Births, deaths, marriages and care](https://www.gov.uk/browse/births-deaths-marriages)\n{/cards}" do
    assert_html_selector 'a.gem-c-cards__link[href="https://www.gov.uk/browse/benefits"]'
    assert_html_selector 'a.gem-c-cards__link[href="https://www.gov.uk/browse/births-deaths-marriages"]'
    assert_text_output "Benefits Births, deaths, marriages and care"
  end

  test_given_govspeak "{cards}[Benefits](https://www.gov.uk/browse/benefits) This is a description{/cards}" do
    assert_html_selector 'a.gem-c-cards__link[href="https://www.gov.uk/browse/benefits"]'
    assert_html_selector ".gem-c-cards__description"
    assert_text_output "Benefits This is a description"
  end

  # The same as above but with line breaks
  test_given_govspeak "{cards}\n\n[Benefits](https://www.gov.uk/browse/benefits)\n\nThis is a description\n\n{/cards}" do
    assert_html_selector 'a.gem-c-cards__link[href="https://www.gov.uk/browse/benefits"]'
    assert_text_output "Benefits This is a description"
  end

  test_given_govspeak "{cards}\n\n[Benefits](https://www.gov.uk/browse/benefits)\n\nThis is a description? With punctuation! - of course, this isn't a real example, real ones wouldn't \"quote\" like this\n\n{/cards}" do
    assert_html_selector 'a.gem-c-cards__link[href="https://www.gov.uk/browse/benefits"]'
    assert_text_output "Benefits This is a description? With punctuation! - of course, this isn't a real example, real ones wouldn't \"quote\" like this"
  end

  test_given_govspeak "{cards}\n
    [Benefits](https://www.gov.uk/browse/benefits)\n
    This is a description\n
    containing line breaks\n
    [Births, deaths, marriages and care](https://www.gov.uk/browse/births-deaths-marriages)\n
    {/cards}" do
    assert_html_selector 'a.gem-c-cards__link[href="https://www.gov.uk/browse/benefits"]'
    assert_html_selector 'a.gem-c-cards__link[href="https://www.gov.uk/browse/births-deaths-marriages"]'
    assert_text_output "Benefits This is a description containing line breaks Births, deaths, marriages and care"
  end
end
