require "test_helper"

class GovspeakAttachmentsImageTest < Minitest::Test
  def build_attachment(args = {})
    {
      content_id: "2b4d92f3-f8cd-4284-aaaa-25b3a640d26c",
      id: 456,
      url: "http://example.com/attachment.jpg",
      title: "Attachment Title",
    }.merge(args)
  end

  def render_govspeak(govspeak, attachments = [])
    Govspeak::Document.new(govspeak, attachments: attachments).to_html
  end

  def compress_html(html)
    html.gsub(/[\n\r]+[\s]*/, "")
  end

  test "renders an empty string for an image attachment not found" do
    assert_equal("\n", render_govspeak("[embed:attachments:image:1fe8]", [build_attachment]))
  end

  test "wraps an attachment in a figure with the id if the id is present" do
    rendered = render_govspeak(
      "[embed:attachments:image:1fe8]",
      [build_attachment(id: 10, content_id: "1fe8")],
    )
    assert_match(/<figure id="attachment_10" class="image embedded">/, rendered)
  end

  test "wraps an attachment in a figure without the id if the id is not present" do
    rendered = render_govspeak(
      "[embed:attachments:image:1fe8]",
      [build_attachment(id: nil, content_id: "1fe8")],
    )
    assert_match(/<figure class="image embedded">/, rendered)
  end

  test "renders an attachment if there are spaces around the content_id" do
    rendered = render_govspeak(
      "[embed:attachments:image: 1fe8 ]",
      [build_attachment(id: 10, content_id: "1fe8")],
    )
    assert_match(/<figure id="attachment_10" class="image embedded">/, rendered)
  end

  test "has an image element to the file" do
    rendered = render_govspeak(
      "[embed:attachments:image:1fe8]",
      [build_attachment(id: nil, url: "http://a.b/c.jpg", content_id: "1fe8")],
    )
    assert_match(%r{<img.*src="http://a.b/c.jpg"}, rendered)
  end

  test "renders the image title as an alt tag" do
    rendered = render_govspeak(
      "[embed:attachments:image:1fe8]",
      [build_attachment(id: nil, title: "My Title", content_id: "1fe8")],
    )
    assert_match(%r{<img.*alt="My Title"}, rendered)
  end

  test "can render a nil image title" do
    rendered = render_govspeak(
      "[embed:attachments:image:1fe8]",
      [build_attachment(id: nil, title: nil, content_id: "1fe8")],
    )
    assert_match(%r{<img.*alt=""}, rendered)
  end

  test "a full image attachment rendering looks correct" do
    rendered = render_govspeak(
      "[embed:attachments:image:1fe8]",
      [build_attachment(id: 10, url: "http://a.b/c.jpg", title: "My Title", content_id: "1fe8")],
    )
    expected_html_output = %(
      <figure id="attachment_10" class="image embedded">
        <div class="img"><img src="http://a.b/c.jpg" alt="My Title"></div>
      </figure>
    )
    assert_match(compress_html(expected_html_output), compress_html(rendered))
  end

  # test inserted because divs can be stripped inside a table
  test "can be rendered inside a table" do
    rendered = render_govspeak(
      "| [embed:attachments:image:1fe8] |",
      [build_attachment(content_id: "1fe8", id: nil)],
    )

    regex = %r{<td><figure class="image embedded"><div class="img">(.*?)</div></figure></td>}
    assert_match(regex, rendered)
  end

  test "renders an empty string for no match" do
    rendered = render_govspeak("[embed:attachments:image:1fe8]")
    assert_equal("\n", rendered)
  end

  test "renders an empty string for a filename instead of a content id" do
    rendered = render_govspeak("[embed:attachments:image: path/to/file.jpg ]")
    assert_equal("\n", rendered)
  end
end
