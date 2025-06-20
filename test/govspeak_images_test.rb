require "test_helper"
require "govspeak_test_helper"

class GovspeakImagesTest < Minitest::Test
  include GovspeakTestHelper

  test "Image:image-id syntax renders an image in options[:images]" do
    given_govspeak "[Image:image-id]", images: [build_image] do
      assert_html_output(
        "<figure class=\"image embedded\"><div class=\"img\"><img src=\"http://example.com/image.jpg\" alt=\"my alt\"></div></figure>",
      )
    end
  end

  test "Image:image-id syntax escapes alt text" do
    given_govspeak "[Image:image-id]", images: [build_image(alt_text: %(my alt '&"<>))] do
      assert_html_output(
        "<figure class=\"image embedded\"><div class=\"img\"><img src=\"http://example.com/image.jpg\" alt=\"my alt '&amp;&quot;&lt;&gt;\"></div></figure>",
      )
    end
  end

  test "Image:image-id syntax renders nothing if not found" do
    doc = Govspeak::Document.new("[Image:another-id]")
    assert_equal %(\n), doc.to_html
  end

  test "Image:image-id syntax adds image caption if given" do
    given_govspeak "[Image:image-id]", images: [build_image(caption: "My Caption & so on")] do
      assert_html_output(
        "<figure class=\"image embedded\"><div class=\"img\"><img src=\"http://example.com/image.jpg\" alt=\"my alt\"></div>\n<figcaption><p>My Caption &amp; so on</p></figcaption></figure>",
      )
    end
  end

  test "Image:image-id syntax ignores a blank caption" do
    given_govspeak "[Image:image-id]", images: [build_image(caption: "  ")] do
      assert_html_output(
        "<figure class=\"image embedded\"><div class=\"img\"><img src=\"http://example.com/image.jpg\" alt=\"my alt\"></div></figure>",
      )
    end
  end

  test "Image:image-id syntax adds image credit if given" do
    given_govspeak "[Image:image-id]", images: [build_image(credit: "My Credit & so on")] do
      assert_html_output(
        "<figure class=\"image embedded\"><div class=\"img\"><img src=\"http://example.com/image.jpg\" alt=\"my alt\"></div>\n<figcaption><p>Image credit: My Credit &amp; so on</p></figcaption></figure>",
      )
    end
  end

  test "Image:image-id syntax adds image credit with localised label when locale is not English" do
    given_govspeak "[Image:image-id]", { images: [build_image(credit: "Fy Nghredyd ac ati")], locale: "cy" } do
      assert_html_output(
        "<figure class=\"image embedded\"><div class=\"img\"><img src=\"http://example.com/image.jpg\" alt=\"my alt\"></div>\n<figcaption><p>Credyd delwedd: Fy Nghredyd ac ati</p></figcaption></figure>",
      )
    end
  end

  test "Image:image-id syntax ignores a blank credit" do
    given_govspeak "[Image:image-id]", images: [build_image(credit: "  ")] do
      assert_html_output(
        "<figure class=\"image embedded\"><div class=\"img\"><img src=\"http://example.com/image.jpg\" alt=\"my alt\"></div></figure>",
      )
    end
  end

  test "Image:image-id syntax adds image caption and credit if given" do
    given_govspeak "[Image:image-id]", images: [build_image(caption: "My Caption & so on", credit: "My Credit & so on")] do
      assert_html_output(
        "<figure class=\"image embedded\"><div class=\"img\"><img src=\"http://example.com/image.jpg\" alt=\"my alt\"></div>\n<figcaption><p>My Caption &amp; so on</p>\n<p>Image credit: My Credit &amp; so on</p></figcaption></figure>",
      )
    end
  end

  test "allows spaces and special characters in the identifier" do
    image = build_image(id: "This is the name of my &%$@€? image")
    given_govspeak "[Image: This is the name of my &%$@€? image]", images: [image] do
      assert_html_output(
        "<figure class=\"image embedded\"><div class=\"img\"><img src=\"http://example.com/image.jpg\" alt=\"my alt\"></div></figure>",
      )
    end
  end

  test "Image is not inserted when it does not start on a new line" do
    given_govspeak "some text [Image:image-id]", images: [build_image] do
      assert_html_output("<p>some text [Image:image-id]</p>")
    end

    given_govspeak "[Image:image-id]", images: [build_image] do
      assert_html_output(
        "<figure class=\"image embedded\"><div class=\"img\"><img src=\"http://example.com/image.jpg\" alt=\"my alt\"></div></figure>",
      )
    end

    given_govspeak "[Image:image-id] some text", images: [build_image] do
      assert_html_output(
        "<figure class=\"image embedded\"><div class=\"img\"><img src=\"http://example.com/image.jpg\" alt=\"my alt\"></div></figure>\n<p>some text</p>",
      )
    end

    given_govspeak "some text\n[Image:image-id]\nsome more text", images: [build_image] do
      assert_html_output <<~HTML
        <p>some text</p>
        <figure class="image embedded"><div class="img"><img src="http://example.com/image.jpg" alt="my alt"></div></figure>
        <p>some more text</p>
      HTML
    end
  end
end
