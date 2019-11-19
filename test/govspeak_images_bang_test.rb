# encoding: UTF-8

require "test_helper"
require "govspeak_test_helper"

class GovspeakImagesBangTest < Minitest::Test
  include GovspeakTestHelper

  class Image
    attr_reader :alt_text, :url, :caption, :credit

    def initialize(attrs = {})
      @alt_text = attrs[:alt_text] || "my alt"
      @url = attrs[:url] || "http://example.com/image.jpg"
      @caption = attrs[:caption]
      @credit = attrs[:credit]
    end
  end

  test "!!n syntax renders an image in options[:images]" do
    given_govspeak "!!1", images: [Image.new] do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div>} +
        %{</figure>},
      )
    end
  end

  test "!!n syntax escapes alt text" do
    given_govspeak "!!1", images: [Image.new(alt_text: %{my alt '&"<>})] do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt '&amp;&quot;&lt;&gt;"></div>} +
        %{</figure>},
      )
    end
  end

  test "!!n syntax renders nothing if not found" do
    doc = Govspeak::Document.new("!!1")
    assert_equal %{\n}, doc.to_html
  end

  test "Image:image-id syntax renders nothing" do
    doc = Govspeak::Document.new("[Image:another-id]", images: [Image.new])
    assert_equal %{\n}, doc.to_html
  end

  test "!!n syntax adds image caption if given" do
    given_govspeak "!!1", images: [Image.new(caption: "My Caption & so on")] do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div>\n} +
        %{<figcaption><p>My Caption &amp; so on</p></figcaption>} +
        %{</figure>},
      )
    end
  end

  test "!!n syntax ignores a blank caption" do
    given_govspeak "!!1", images: [Image.new(caption: "  ")] do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div>} +
        %{</figure>},
      )
    end
  end

  test "¡¡n syntax adds image credit if given" do
    given_govspeak "!!1", images: [Image.new(credit: "My Credit & so on")] do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div>\n} +
        %{<figcaption><p>Image credit: My Credit &amp; so on</p></figcaption>} +
        %{</figure>},
      )
    end
  end

  test "!!n syntax ignores a blank credit" do
    given_govspeak "!!1", images: [Image.new(credit: "  ")] do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div>} +
        %{</figure>},
      )
    end
  end

  test "!!n syntax adds image caption and credit if given" do
    given_govspeak "!!1", images: [Image.new(caption: "My Caption & so on", credit: "My Credit & so on")] do
      assert_html_output(
        %{<figure class="image embedded">} +
        %{<div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div>\n} +
        %{<figcaption>} +
          %{<p>My Caption &amp; so on</p>\n} +
          %{<p>Image credit: My Credit &amp; so on</p>} +
        %{</figcaption>} +
        %{</figure>},
      )
    end
  end
end
