# encoding: UTF-8

require 'test_helper'
require 'govspeak_test_helper'

class GovspeakImagesTest < Minitest::Test
  include GovspeakTestHelper

  def build_image(attrs = {})
    attrs[:alt_text] ||= "my alt"
    attrs[:url] ||= "http://example.com/image.jpg"
    attrs[:id] ||= "image-id"
    attrs
  end

  test "Image:image-id syntax renders an image in options[:images]" do
    given_govspeak "[Image:image-id]", images: [build_image] do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div>} +
        %{</figure>}
      )
    end
  end

  test "Image:image-id syntax escapes alt text" do
    given_govspeak "[Image:image-id]", images: [build_image(alt_text: %{my alt '&"<>})] do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt '&amp;&quot;&lt;&gt;"></div>} +
        %{</figure>}
      )
    end
  end

  test "Image:image-id syntax renders nothing if not found" do
    doc = Govspeak::Document.new("[Image:another-id]")
    assert_equal %{\n}, doc.to_html
  end

  test "Image:image-id syntax adds image caption if given" do
    given_govspeak "[Image:image-id]", images: [build_image(caption: 'My Caption & so on')] do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div>\n} +
        %{<figcaption><p>My Caption &amp; so on</p></figcaption>} +
        %{</figure>}
      )
    end
  end

  test "Image:image-id syntax ignores a blank caption" do
    given_govspeak "[Image:image-id]", images: [build_image(caption: '  ')] do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div>} +
        %{</figure>}
      )
    end
  end

  test "Image:image-id syntax adds image credit if given" do
    given_govspeak "[Image:image-id]", images: [build_image(credit: 'My Credit & so on')] do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div>\n} +
        %{<figcaption><p>Image credit: My Credit &amp; so on</p></figcaption>} +
        %{</figure>}
      )
    end
  end

  test "Image:image-id syntax ignores a blank credit" do
    given_govspeak "[Image:image-id]", images: [build_image(credit: '  ')] do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div>} +
        %{</figure>}
      )
    end
  end

  test "Image:image-id syntax adds image caption and credit if given" do
    given_govspeak "[Image:image-id]", images: [build_image(caption: 'My Caption & so on', credit: 'My Credit & so on')] do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div>\n} +
        %{<figcaption>} +
            %{<p>My Caption &amp; so on</p>\n} +
            %{<p>Image credit: My Credit &amp; so on</p>} +
          %{</figcaption>} +
        %{</figure>}
      )
    end
  end
end
