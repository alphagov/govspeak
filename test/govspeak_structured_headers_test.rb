require 'test_helper'

class GovspeakStructuredHeadersTest < Minitest::Test

  def document_body
    %{
## Heading 1

## Heading 2

### Sub heading 2.1

### Sub heading 2.2

#### Sub sub heading 2.2.1

### Sub heading 2.3

## Heading 3

## Heading 4

### Sub heading 4.1

#### Sub heading 4.1.1

##### Sub heading 4.1.1.1

### Sub heading 4.2

## Heading 5

    }
  end

  def doc
    @doc ||= Govspeak::Document.new(document_body)
  end

  def structured_headers
    doc.structured_headers
  end

  test "Headings with no sub-headings have an empty headings collection" do
    assert_empty structured_headers.first.headers
  end

  test "h2s are extracted as top level headings" do
    expected_headings =  ["Heading 1", "Heading 2", "Heading 3", "Heading 4", "Heading 5"]

    assert_equal expected_headings, structured_headers.map(&:text)
  end

  test "headings can have multiple sub-headings" do
    expected_heading_texts = ["Sub heading 2.1", "Sub heading 2.2", "Sub heading 2.3"]
    assert_equal expected_heading_texts, structured_headers[1].headers.map(&:text)
  end

  test "h3 following h2s are nested within them" do
    assert_equal "Sub heading 2.1", structured_headers[1].headers[0].text
  end

  test "h4 following h3s are nested within them" do
    assert_equal "Sub sub heading 2.2.1", structured_headers[1].headers[1].headers[0].text
  end

  test "h3 can follow an h5" do
    assert_equal "Sub heading 4.2", structured_headers[3].headers[1].text
  end

  test "structured headers serialize to hashes recursively serializing sub headers" do
    serialized_headers = structured_headers[1].to_h

    expected_serialized_headers = {
      :text => "Heading 2",
      :level => 2,
      :id => "heading-2",
      :headers =>  [
        {
          :text => "Sub heading 2.1",
          :level => 3,
          :id => "sub-heading-21",
          :headers => [],
        },
        {
          :text => "Sub heading 2.2",
          :level => 3,
          :id => "sub-heading-22",
          :headers =>  [
            {
              :text => "Sub sub heading 2.2.1",
              :level => 4,
              :id => "sub-sub-heading-221",
              :headers => []
            },
          ],
        },
        {
          :text => "Sub heading 2.3",
          :level => 3, :id=>"sub-heading-23",
          :headers => []
        },
      ],
    }

    assert_equal expected_serialized_headers, serialized_headers
  end

  def invalid_document_body
    %{
### Invalid heading (h3)

## Heading 1

#### Invalid heading (h4)

### Sub heading 1.1

# Invalid heading (h1)

    }
  end

  def invalid_doc
    @invalid_doc ||= Govspeak::Document.new(invalid_document_body)
  end

  def invalid_structured_headers
    invalid_doc.structured_headers
  end

  test "semantically invalid headers are ignored" do
    assert_equal ["Heading 1"], invalid_structured_headers.map(&:text)

    assert_equal ["Sub heading 1.1"], invalid_structured_headers.first.headers.map(&:text)
  end

  test "document with single h1 produces no headers" do
    assert_equal [], Govspeak::Document.new("# Heading\n").structured_headers
  end
end
