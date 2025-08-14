require "test_helper"
require "govspeak_test_helper"

class GovspeakAttachmentTest < Minitest::Test
  include GovspeakTestHelper

  def render_govspeak(govspeak, attachments = [])
    Govspeak::Document.new(govspeak, attachments:).to_html
  end

  test "renders an empty string for attachment link that is not found" do
    assert_equal("\n", render_govspeak("[Attachment:file.pdf]", []))
  end

  test_given_govspeak(
    "[Attachment:attachment.pdf]",
    { attachments: [
      {
        id: "attachment.pdf",
        url: "http://example.com/attachment.pdf",
        title: "Attachment Title",
      },
    ] },
  ) do
    # assert_html_output %(
    #   first
    #   second
    # )
    assert_text_output "Attachment Title"
    assert_ast_output_pattern do |actual|
      actual => {
        type: :root,
        children: [
          {
            type: :embed_attachment,
            id: "attachment.pdf",
            url: "http://example.com/attachment.pdf",
            title: "Attachment Title",
          }
        ]
      }
    end
  end

  test "renders an attachment component for a found attachment" do
    attachment = {
      id: "attachment.pdf",
      url: "http://example.com/attachment.pdf",
      title: "Attachment Title",
    }

    rendered = render_govspeak("[Attachment:attachment.pdf]", [attachment])
    assert html_has_selector?(rendered, "section.gem-c-attachment")
    assert_match(/Attachment Title/, rendered)
  end

  test "allows spaces and special characters in the identifier" do
    attachment = {
      id: "This is the name of my &%$@€? attachment",
      url: "http://example.com/attachment.pdf",
      title: "Attachment Title",
    }

    rendered = render_govspeak("[Attachment: This is the name of my &%$@€? attachment]", [attachment])
    assert html_has_selector?(rendered, "section.gem-c-attachment")
    assert_match(/Attachment Title/, rendered)
  end

  test "only renders attachment when markdown extension starts on a new line" do
    attachment = {
      id: "attachment.pdf",
      url: "http://example.com/attachment.pdf",
      title: "Attachment Title",
    }

    rendered = render_govspeak("some text [Attachment:attachment.pdf]", [attachment])
    assert_equal("<p>some text [Attachment:attachment.pdf]</p>\n", rendered)

    rendered = render_govspeak("[Attachment:attachment.pdf] some text", [attachment])
    assert html_has_selector?(rendered, "section.gem-c-attachment")
    assert_match(/<p>some text<\/p>/, rendered)

    rendered = render_govspeak("some text\n[Attachment:attachment.pdf]\nsome more text", [attachment])
    assert_match(/<p>some text<\/p>/, rendered)
    assert html_has_selector?(rendered, "section.gem-c-attachment")
    assert_match(/<p>some more text<\/p>/, rendered)
  end
end
