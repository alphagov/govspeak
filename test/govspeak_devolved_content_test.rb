require "test_helper"
require "govspeak_test_helper"

class GovspeakDevolvedTest < Minitest::Test
  include GovspeakTestHelper

  test "uses localised heading when locale is not English" do
    given_govspeak ":scotland: Rwy'n ddatganoledig iawn\n ac yn Albanaidd iawn \n:scotland:", locale: "cy" do
      assert_html_output(
        %(
        <div class="devolved-content scotland">
        <p class="devolved-header">Mae'r adran hon yn berthnasol i'r Alban</p>
        <div class="devolved-body">
        <p>Rwy’n ddatganoledig iawn
         ac yn Albanaidd iawn</p>
        </div>
        </div>),
      )
    end
  end
end
