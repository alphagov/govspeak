require "test_helper"

class GovspeakTablesTest < Minitest::Test
  def expected_outcome_for_headers
    %(
<table>
  <thead>
    <tr>
      <td></td>
      <th scope="col">Second Column</th>
      <th scope="col">Third Column</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">First row</th>
      <td>Cell</td>
      <td>Cell</td>
    </tr>
    <tr>
      <th scope="row">Second row</th>
      <td>Cell</td>
      <td>Cell</td>
    </tr>
  </tbody>
</table>
)
  end

  def expected_outcome_with_hashes_in_cell_contents
    %(
<table>
  <thead>
    <tr>
      <td></td>
      <th scope="col">Second Column</th>
      <th scope="col">Third Column</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">First row</th>
      <td># Cell</td>
      <td># Cell</td>
    </tr>
    <tr>
      <th scope="row">Second row</th>
      <td>Cell</td>
      <td>Cell</td>
    </tr>
  </tbody>
</table>
)
  end

  def expected_outcome_for_table_with_alignments
    %(
<table>
  <thead>
    <tr>
      <td class="cell-text-left"></td>
      <th scope="col" class="cell-text-center">Second Column</th>
      <th scope="col" class="cell-text-right">Third Column</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row" class="cell-text-left">First row</th>
      <td class="cell-text-center">Cell</td>
      <td class="cell-text-right">Cell</td>
    </tr>
    <tr>
      <th scope="row" class="cell-text-left">Second row</th>
      <td class="cell-text-center">Cell</td>
      <td class="cell-text-right">Cell</td>
    </tr>
  </tbody>
</table>
)
  end

  def expected_outcome_for_table_headers_in_the_wrong_place
    %(
<table>
  <thead>
    <tr>
      <td></td>
      <th scope="col">Second Column</th>
      <th scope="col">Third Column</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">First row</th>
      <td># Cell</td>
      <td>Cell</td>
    </tr>
    <tr>
      <th scope="row">Second row</th>
      <td>Cell</td>
      <td># Cell</td>
    </tr>
  </tbody>
</table>
)
  end

  def expected_outcome_for_table_with_blank_table_headers
    %(
<table>
  <thead>
    <tr>
      <td></td>
      <th scope="col">Second Column</th>
      <th scope="col">Third Column</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td></td>
      <td>Cell</td>
      <td>Cell</td>
    </tr>
    <tr>
      <th scope="row">Second row</th>
      <td>Cell</td>
      <td>Cell</td>
    </tr>
  </tbody>
</table>
)
  end

  def expected_outcome_for_table_with_table_headers_containing_superscript
    %(
<table>
  <thead>
    <tr>
      <th scope="col">Foo<sup>bar</sup>
</th>
      <th scope="col">Third Column</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Cell</td>
      <td>Cell</td>
    </tr>
  </tbody>
</table>
)
  end

  def document_body_with_table_headers_containing_superscript
    @document_body_with_table_headers_containing_superscript ||= Govspeak::Document.new(%(
| Foo<sup>bar</sup>     | Third Column        |
| ---------------       | ------------------- |
| Cell                  | Cell                |
))
  end

  def expected_outcome_for_table_headers_containing_links
    %(
<table>
  <thead>
    <tr>
      <td></td>
      <th scope="col">Second Column</th>
      <th scope="col">Third Column</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">Link contained in header <a rel="external" href="http://google.com">link1</a>
</th>
      <td>Cell</td>
      <td>Cell</td>
    </tr>
    <tr>
      <th scope="row">No link</th>
      <td>Cell</td>
      <td>Cell</td>
    </tr>
    <tr>
      <th scope="row"><a rel="external" href="http://www.bbc.co.uk">Whole header is link</a>
</th>
      <td>Cell</td>
      <td>Cell</td>
    </tr>
  </tbody>
</table>
)
  end

  def document_body_with_hashes_for_all_headers
    @document_body_with_hashes_for_all_headers ||= Govspeak::Document.new(%(
|                 |# Second Column  |# Third Column       |
| --------------- | --------------- | ------------------- |
|# First row      | Cell            | Cell                |
|# Second row     | Cell            | Cell                |
))
  end

  def document_body_with_hashes_for_row_headers
    @document_body_with_hashes_for_row_headers ||= Govspeak::Document.new(%(
|                 | Second Column   | Third Column        |
| --------------- | --------------- | ------------------- |
|# First row      | Cell            | Cell                |
|# Second row     | Cell            | Cell                |
))
  end

  def document_body_with_alignments
    @document_body_with_alignments ||= Govspeak::Document.new(%(
|                 | Second Column   | Third Column        |
| :-------------- | :-------------: | ------------------: |
|# First row      | Cell            | Cell                |
|# Second row     | Cell            | Cell                |
))
  end

  def document_body_with_table_headers_in_the_wrong_place
    @document_body_with_table_headers_in_the_wrong_place ||= Govspeak::Document.new(%(
|                 | Second Column   | Third Column        |
| --------------- | --------------- | ------------------- |
|# First row      |# Cell           | Cell                |
|# Second row     | Cell            |# Cell               |
))
  end

  def document_body_with_blank_table_headers
    @document_body_with_blank_table_headers ||= Govspeak::Document.new(%(
|                 | Second Column   | Third Column        |
| --------------- | --------------- | ------------------- |
|#                | Cell            | Cell                |
|# Second row     | Cell            | Cell                |
))
  end

  def document_body_with_table_headers_containing_links
    @document_body_with_table_headers_containing_links ||= Govspeak::Document.new(%(
|                                                      | Second Column   | Third Column        |
| ---------------------------------------------------- | --------------- | ------------------- |
|# Link contained in header [link1](http://google.com) | Cell            | Cell                |
|# No link                                             | Cell            | Cell                |
|# [Whole header is link](http://www.bbc.co.uk)        | Cell            | Cell                |
))
  end

  test "Cells with |# are headers" do
    assert_equal expected_outcome_for_headers, document_body_with_hashes_for_all_headers.to_html
  end

  test "Cells outside of thead with |# are th; thead still only contains th" do
    assert_equal expected_outcome_for_headers, document_body_with_hashes_for_row_headers.to_html
  end

  test "Cells are given classes to indicate alignment" do
    assert_equal expected_outcome_for_table_with_alignments, document_body_with_alignments.to_html
  end

  test "Invalid alignment properties are dropped from cells" do
    html = %(<table><tbody><tr><td style="text-align: middle">middle</td></tr></tbody></table>)
    expected = "<table><tbody><tr><td>middle</td></tr></tbody></table>\n"

    assert_equal expected, Govspeak::Document.new(html).to_html
  end

  test "Styles other than text-align are ignored on a table cell" do
    html = %(<table><tbody><tr><td style="text-align: center; width: 100px;">middle</td></tr></tbody></table>)
    expected = %(<table><tbody><tr><td class="cell-text-center">middle</td></tr></tbody></table>\n)

    assert_equal expected, Govspeak::Document.new(html).to_html
  end

  test "Table headers with a scope of row are only in the first column of the table" do
    assert_equal expected_outcome_for_table_headers_in_the_wrong_place, document_body_with_table_headers_in_the_wrong_place.to_html
  end

  test "Table headers with a scope of row can have embedded links" do
    assert_equal expected_outcome_for_table_headers_containing_links, document_body_with_table_headers_containing_links.to_html
  end

  test "Table headers are not blank" do
    assert_equal expected_outcome_for_table_with_blank_table_headers, document_body_with_blank_table_headers.to_html
  end

  test "Table header superscript should parse" do
    assert_equal expected_outcome_for_table_with_table_headers_containing_superscript, document_body_with_table_headers_containing_superscript.to_html, expected_outcome_for_table_with_table_headers_containing_superscript
  end
end
