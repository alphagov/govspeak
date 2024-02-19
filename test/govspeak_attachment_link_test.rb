require "test_helper"

class GovspeakAttachmentLinkTest < Minitest::Test
  def render_govspeak(govspeak, attachments = [])
    Govspeak::Document.new(govspeak, attachments:).to_html
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

  test "allows spaces and special characters in the identifier" do
    attachment = {
      id: "This is the name of my &%$@€? attachment",
      url: "http://example.com/attachment.pdf",
      title: "Attachment Title",
    }

    rendered = render_govspeak("[AttachmentLink: This is the name of my &%$@€? attachment]", [attachment])
    assert_match(/Attachment Title/, rendered)
  end

  test "renders an attachment link inside a numbered list" do
    attachment = {
      id: "attachment.pdf",
      url: "http://example.com/attachment.pdf",
      title: "Attachment Title",
    }

    rendered = render_govspeak("s1. First item with [AttachmentLink: attachment.pdf]\ns2. Second item without attachment", [attachment])

    expected_output = <<~TEXT
      <ol class="steps">
      <li>
      <p>First item with <span class="gem-c-attachment-link">
        <a class="govuk-link" href="http://example.com/attachment.pdf">Attachment Title</a>  </span></p>
      </li>
      <li>
      <p>Second item without attachment</p>
      </li>
      </ol>
    TEXT

    assert_equal(expected_output, rendered)
  end
end
