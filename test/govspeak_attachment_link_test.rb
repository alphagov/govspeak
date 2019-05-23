# encoding: UTF-8

require "test_helper"

class GovspeakAttachmentLinkTest < Minitest::Test
  def render_govspeak(govspeak, attachments = [])
    Govspeak::Document.new(govspeak, attachments: attachments).to_html
  end

  test "renders an empty string for attachment link that is not found" do
    assert_equal("\n", render_govspeak("[AttachmentLink:file.pdf]", []))
  end

  test "renders an attachment link component for a found attachment link" do
    attachment = {
      id: "attachment.pdf",
      url: "http://example.com/attachment.pdf",
      title: "Attachment Title",
    }

    rendered = render_govspeak("[AttachmentLink:attachment.pdf]", [attachment])
    assert_match(/<span class="gem-c-attachment-link">/, rendered)
    assert_match(%r{href="http://example.com/attachment.pdf"}, rendered)
  end

  test "renders an attachment link inside a paragraph" do
    attachment = {
      id: "attachment.pdf",
      url: "http://example.com/attachment.pdf",
      title: "Attachment Title",
    }

    rendered = render_govspeak("[AttachmentLink:attachment.pdf] test", [attachment])
    root = Nokogiri::HTML.fragment(rendered).css(":root").first

    assert(root.name, "p")
    assert(root.css("p").size, 0)
    assert_match(/Attachment Title\s*test/, root.text)
  end
end
