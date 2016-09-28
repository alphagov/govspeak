# encoding: UTF-8

require 'test_helper'

class GovspeakAttachmentsInlineTest < Minitest::Test
  def build_attachment(args = {})
    {
      content_id: "2b4d92f3-f8cd-4284-aaaa-25b3a640d26c",
      id: 456,
      url: "http://example.com/attachment.pdf",
      title: "Attachment Title",
    }.merge(args)
  end

  def render_govspeak(govspeak, attachments = [])
    Govspeak::Document.new(govspeak, attachments: attachments).to_html
  end

  test "renders an empty string for an inline attachment not found" do
    assert_match("", render_govspeak("[embed:attachments:inline:1fe8]", [build_attachment]))
  end

  test "wraps an attachment in a span with the id if the id is present" do
    rendered = render_govspeak(
      "[embed:attachments:inline:1fe8]",
      [build_attachment(id: 10, content_id: "1fe8")]
    )
    assert_match(/span id="attachment_10" class="attachment-inline">/, rendered)
  end

  test "wraps an attachment in a span without the id if the id is not present" do
    rendered = render_govspeak(
      "[embed:attachments:inline:1fe8]",
      [build_attachment(id: nil, content_id: "1fe8")]
    )
    assert_match(/span class="attachment-inline">/, rendered)
  end

  test "links to the attachment file" do
    rendered = render_govspeak(
      "[embed:attachments:inline:1fe8]",
      [build_attachment(content_id: "1fe8", url: "http://a.b/f.pdf", title: "My Pdf")]
    )
    assert_match(%r{<a href="http://a.b/f.pdf">My Pdf</a>}, rendered)
  end

  test "renders on a single line" do
    rendered = render_govspeak(
      "[embed:attachments:inline:2bc1]",
      [build_attachment(content_id: "2bc1", external?: true)]
    )
    assert_match(%r{<span id="attachment[^\n]*</span>}, rendered)
  end

  test "doesn't have spaces between the span and the link" do
    rendered = render_govspeak(
      "[embed:attachments:inline:2bc1]",
      [build_attachment(content_id: "2bc1", id: nil)]
    )
    assert_match(%r{<span class="attachment-inline"><a href=".*">.*</a></span>}, rendered)
  end

  test "will show HTML type (in brackets) if file_extension is specified as html" do
    rendered = render_govspeak(
      "[embed:attachments:inline:1fe8]",
      [build_attachment(content_id: "1fe8", file_extension: "html")]
    )
    assert_match(%r{(<span class="type">HTML</span>)}, rendered)
  end

  test "will show url (in brackets) if specified as external" do
    rendered = render_govspeak(
      "[embed:attachments:inline:1fe8]",
      [build_attachment(content_id: "1fe8", url: "http://a.b/f.pdf", external?: true)]
    )
    assert_match(%r{(<span class="url">http://a.b/f.pdf</span>)}, rendered)
  end

  test "will not show url if file_extension is specified as html" do
    rendered = render_govspeak(
      "[embed:attachments:inline:1fe8]",
      [build_attachment(content_id: "1fe8", url: "http://a.b/f.pdf", file_extension: "html", external?: true)]
    )
    refute_match(%r{(<span class="url">http://a.b/f.pdf</span>)}, rendered)
  end

  test "will show a file extension in a abbr element for non html" do
    rendered = render_govspeak(
      "[embed:attachments:inline:1fe8]",
      [build_attachment(content_id: "1fe8", file_extension: "csv")]
    )
    refute_match(%r{<span class="type"><abbr title="Comma-separated values">CSV</abbr></span>}, rendered)
  end

  test "will show file size in a span" do
    rendered = render_govspeak(
      "[embed:attachments:inline:1fe8]",
      [build_attachment(content_id: "1fe8", file_size: 1024)]
    )
    assert_match(%r{<span class="file-size">1 KB</span>}, rendered)
  end

  test "will show number of pages" do
    rendered = render_govspeak(
      "[embed:attachments:inline:1fe8]",
      [build_attachment(content_id: "1fe8", number_of_pages: 1)]
    )
    assert_match(%r{<span class="page-length">1 page</span>}, rendered)
    rendered = render_govspeak(
      "[embed:attachments:inline:1fe8]",
      [build_attachment(content_id: "1fe8", number_of_pages: 2)]
    )
    assert_match(%r{<span class="page-length">2 pages</span>}, rendered)
  end

  test "will show attributes after link" do
    rendered = render_govspeak(
      "[embed:attachments:inline:1fe8]",
      [build_attachment(
        content_id: "1fe8",
        url: "http://a.b/test.txt",
        title: "My Attached Text File",
        file_extension: "txt",
        file_size: 2048,
        number_of_pages: 2,
      )]
    )
    link = %{<a href="#{Regexp.quote('http://a.b/test.txt')}">My Attached Text File</a>}
    type = %{<span class="type">Plain text</span>}
    file_size = %{<span class="file-size">2 KB</span>}
    pages = %{<span class="page-length">2 pages</span>}
    assert_match(/#{link}\s+\(#{type}, #{file_size}, #{pages}\)/, rendered)
  end

  test "can render two inline attachments on the same line" do
    rendered = render_govspeak(
      "[embed:attachments:inline:1fe8] and [embed:attachments:inline:2abc]",
      [
        build_attachment(content_id: "1fe8", url: "http://a.b/test.txt", title: "Text File"),
        build_attachment(content_id: "2abc", url: "http://a.b/test.pdf", title: "PDF File")
      ]
    )
    assert_match(%r{<a href="http://a.b/test.txt">Text File</a>}, rendered)
    assert_match(%r{<a href="http://a.b/test.pdf">PDF File</a>}, rendered)
  end
end
