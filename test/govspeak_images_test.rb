# encoding: UTF-8

require 'test_helper'
require 'govspeak_test_helper'

class GovspeakImagesTest < Minitest::Test
  include GovspeakTestHelper

  test "can reference attached images using !!n" do
    images = [OpenStruct.new(alt_text: 'my alt', url: "http://example.com/image.jpg")]
    given_govspeak "!!1", images do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div>} +
        %{</figure>}
      )
    end
  end

  test "alt text of referenced images is escaped" do
    images = [OpenStruct.new(alt_text: %{my alt '&"<>}, url: "http://example.com/image.jpg")]
    given_govspeak "!!1", images do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt '&amp;&quot;&lt;&gt;"></div>} +
        %{</figure>}
      )
    end
  end

  test "silently ignores an image attachment if the referenced image is missing" do
    doc = Govspeak::Document.new("!!1")
    doc.images = []

    assert_equal %{\n}, doc.to_html
  end

  test "adds image caption if given" do
    images = [OpenStruct.new(alt_text: "my alt", url: "http://example.com/image.jpg", caption: 'My Caption & so on')]
    given_govspeak "!!1", images do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div>\n} +
        %{<figcaption>My Caption &amp; so on</figcaption>} +
        %{</figure>}
      )
    end
  end

  test "ignores a blank caption" do
    images = [OpenStruct.new(alt_text: "my alt", url: "http://example.com/image.jpg", caption: '  ')]
    given_govspeak "!!1", images do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div>} +
        %{</figure>}
      )
    end
  end
end
