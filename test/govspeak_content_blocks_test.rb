require "test_helper"

class GovspeakContentBlocksTest < Minitest::Test
  extend Minitest::Spec::DSL

  def compress_html(html)
    html.gsub(/[\n\r]+\s*/, "")
  end

  let(:content_id) { SecureRandom.uuid }

  it "renders an email address when present in options[:embeds]" do
    content_block = {
      content_id:,
      document_type: "content_block_email_address",
      title: "foo",
      details: {
        email_address: "foo@example.com",
      },
    }
    govspeak = "{{embed:content_block_email_address:#{content_id}}}"

    rendered = Govspeak::Document.new(govspeak, content_blocks: [content_block]).to_html

    expected = "<p><span class=\"embed embed-content_block_email_address\" id=\"embed_#{content_id}\">#{content_block[:details][:email_address]}</span></p>"

    assert_equal compress_html(expected), compress_html(rendered)
  end

  it "renders the title when the document type is a contact" do
    content_block = {
      content_id:,
      document_type: "contact",
      title: "foo",
    }
    govspeak = "{{embed:contact:#{content_id}}}"

    rendered = Govspeak::Document.new(govspeak, content_blocks: [content_block]).to_html

    expected = "<p><span class=\"embed embed-contact\" id=\"embed_#{content_id}\">#{content_block[:title]}</span></p>"

    assert_equal compress_html(expected), compress_html(rendered)
  end

  it "ignores missing embeds" do
    govspeak = "{{embed:contact:#{content_id}}}"

    rendered = Govspeak::Document.new(govspeak, content_blocks: []).to_html

    assert_equal compress_html(""), compress_html(rendered)
  end

  it "supports multiple embeds" do
    content_blocks = [
      {
        content_id: SecureRandom.uuid,
        document_type: "contact",
        title: "foo",
      },
      {
        content_id: SecureRandom.uuid,
        document_type: "content_block_email_address",
        title: "foo",
        details: {
          email_address: "foo@example.com",
        },
      },
    ]

    govspeak = %(Here is a contact: {{embed:contact:#{content_blocks[0][:content_id]}}}

Here is an email address: {{embed:content_block_email_address:#{content_blocks[1][:content_id]}}}
    )

    rendered = Govspeak::Document.new(govspeak, content_blocks:).to_html

    expected = """
      <p>Here is a contact: <span class=\"embed embed-contact\" id=\"embed_#{content_blocks[0][:content_id]}\">#{content_blocks[0][:title]}</span></p>
      <p>Here is an email address: <span class=\"embed embed-content_block_email_address\" id=\"embed_#{content_blocks[1][:content_id]}\">#{content_blocks[1][:details][:email_address]}</span></p>
    """

    assert_equal compress_html(expected), compress_html(rendered)
  end
end
