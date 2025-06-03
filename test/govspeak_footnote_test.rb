require "test_helper"
require "govspeak_test_helper"

class GovspeakFootnoteTest < Minitest::Test
  include GovspeakTestHelper

  test_given_govspeak "
    Footnotes can be added[^1].

    [^1]: And then later defined.

    Footnotes can be added too[^2].

    [^2]: And then later defined too.

    This footnote has a reference number[^3].

    And this footnote has the same reference number[^3].

    [^3]: And then they both point here." do
    assert_html_output(
      %(
      <p>Footnotes can be added<sup id="fnref:1"><a href="#fn:1" class="footnote" rel="footnote" role="doc-noteref">[footnote 1]</a></sup>.</p>

      <p>Footnotes can be added too<sup id="fnref:2"><a href="#fn:2" class="footnote" rel="footnote" role="doc-noteref">[footnote 2]</a></sup>.</p>

      <p>This footnote has a reference number<sup id="fnref:3"><a href="#fn:3" class="footnote" rel="footnote" role="doc-noteref">[footnote 3]</a></sup>.</p>

      <p>And this footnote has the same reference number<sup id="fnref:3:1"><a href="#fn:3" class="footnote" rel="footnote" role="doc-noteref">[footnote 3]</a></sup>.</p>

      <div class="footnotes" role="doc-endnotes">
        <ol>
          <li id="fn:1">
            <p>And then later defined. <a href="#fnref:1" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
          <li id="fn:2">
            <p>And then later defined too. <a href="#fnref:2" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a></p>
          </li>
          <li id="fn:3">
            <p>And then they both point here. <a href="#fnref:3" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a> <a href="#fnref:3:1" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced 2">↩<sup>2</sup></a></p>
          </li>
        </ol>
      </div>),
    )
  end

  test "uses localised labels when locale is not English" do
    given_govspeak "
    Gellir ychwanegu troednodiadau[^1].

    [^1]: Ac yna wedi'i ddiffinio'n ddiweddarach.", locale: "cy" do
      assert_html_output(
        %(
        <p>Gellir ychwanegu troednodiadau<sup id="fnref:1"><a href="#fn:1" class="footnote" rel="footnote" role="doc-noteref">[troednodyn 1]</a></sup>.</p>

        <div class="footnotes" role="doc-endnotes">
          <ol>
            <li id="fn:1">
              <p>Ac yna wedi’i ddiffinio’n ddiweddarach. <a href="#fnref:1" class="reversefootnote" role="doc-backlink" aria-label="ewch i ble mae hyn wedi'i gyfeirio">↩</a></p>
            </li>
          </ol>
        </div>),
      )
    end
  end
end
