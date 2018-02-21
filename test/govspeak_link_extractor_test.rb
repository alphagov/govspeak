require "test_helper"

class GovspeakLinkExtractorTest < Minitest::Test
  def document_body
    %{
## Heading

[link](http://www.example.com)

[link_two](http://www.gov.com)

[not_a_link](#somepage)

[mailto:](mailto:someone@www.example.com)

[absolute_path](/cais-trwydded-yrru-dros-dro)

<a href="http://www.example.com/from/html">raw_html_link</a>

[empty_markdown_link]()

[a_different_empty_markdown_link]( )

<a>empty_raw_html_link</a>

<a href="">a_second_empty_raw_link</a>

<a href=" ">a_third_empty_raw_link</a>

<a href>a_fourth_empty_raw_link</a>
    }
  end

  def doc
    @doc ||= Govspeak::Document.new(document_body)
  end

  def links
    doc.extracted_links
  end

  test "Links are extracted from the body" do
    expected_links = %w{http://www.example.com http://www.gov.com /cais-trwydded-yrru-dros-dro http://www.example.com/from/html}
    assert_equal expected_links, links
  end

  test "Other content is not extracted from the body" do
    refute_includes ["Heading"], links
  end

  test "Links are not extracted if they begin with #" do
    refute_includes ["#somepage"], links
  end

  test "Links are not extracted if they begin with mailto:" do
    refute_includes ["mailto:someone@www.example.com"], links
  end

  test "Links are not extracted if they are blank" do
    refute_includes [""], links
    refute_includes [nil], links
  end

  test "Absolute links are transformed to a url when website_root passed in" do
    urls = doc.extracted_links(website_root: "http://www.example.com")
    assert urls.include?("http://www.example.com/cais-trwydded-yrru-dros-dro")
  end
end
