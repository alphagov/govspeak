require "test_helper"

class GovspeakAttachmentTest < Minitest::Test
  def render_govspeak(govspeak, attachments = [])
    Govspeak::Document.new(govspeak, attachments:).to_html
  end

  test "renders an empty string for attachment link that is not found" do
    assert_equal("\n", render_govspeak("[Attachment:file.pdf]", []))
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

  test "renders attachments with details elements with the correct GA4 index" do
    attachments = []

    (1..3).each do |index|
      attachments << {
        id: "attachment#{index}.ods",
        url: "http://example.com/attachment#{index}",
        title: "Attachment Title #{index}",
        alternative_format_contact_email: "example@gov.uk",
      }
    end

    # Insert an attachment without a details element, to ensure our code to increment the index ignores these
    attachments.insert(1, {
      id: "attachment.pdf",
      url: "http://example.com/attachment.pdf",
      title: "Attachment Title",
    })

    rendered = render_govspeak("[Attachment:attachment1.ods]\n[Attachment:attachment.pdf]\n[Attachment:attachment2.ods]\n[Attachment:attachment3.ods]", attachments)
    node = Nokogiri::HTML(rendered)
    node.css(".gem-c-details").each_with_index.map do |details, index|
      ga4_event = JSON.parse(details.attribute("data-ga4-event"))
      assert_equal ga4_event["index_section"], index + 1
      assert_equal ga4_event["index_section_count"], 3
    end
  end
end
