# encoding: UTF-8

require 'test_helper'
require 'govspeak_test_helper'

class GovspeakImagesBangTest < Minitest::Test
  include GovspeakTestHelper

  def build_image(attrs = {})
    attrs[:alt_text] ||= "my alt"
    attrs[:url] ||= "http://example.com/image.jpg"
    OpenStruct.new(attrs)
  end

  test "!!n syntax renders an image in options[:images]" do
    given_govspeak "!!1", images: [build_image] do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div>} +
        %{</figure>}
      )
    end
  end

  test "!!n syntax escapes alt text" do
    given_govspeak "!!1", images: [build_image(alt_text: %{my alt '&"<>})] do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt '&amp;&quot;&lt;&gt;"></div>} +
        %{</figure>}
      )
    end
  end

  test "!!n syntax renders nothing if not found" do
    doc = Govspeak::Document.new("!!1")
    assert_equal %{\n}, doc.to_html
  end

  test "!!n syntax adds image caption if given" do
    given_govspeak "!!1", images: [build_image(caption: 'My Caption & so on')] do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div>\n} +
        %{<figcaption>My Caption &amp; so on</figcaption>} +
        %{</figure>}
      )
    end
  end

  test "!!n syntax ignores a blank caption" do
    given_govspeak "!!1", images: [build_image(caption: '  ')] do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div>} +
        %{</figure>}
      )
    end
  end
end
