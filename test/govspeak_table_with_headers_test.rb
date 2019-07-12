require 'test_helper'

class GovspeakTableWithHeadersTest < Minitest::Test
  def expected_outcome
%{
<table>
  <thead>
    <tr>
      <th></th>
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
}
  end

  def expected_outcome_with_hashes_in_cell_contents
%{
<table>
  <thead>
    <tr>
      <th></th>
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
}
  end

  def expected_outcome_for_table_with_alignments
    %{
<table>
  <thead>
    <tr>
      <th style="text-align: left"></th>
      <th style="text-align: center" scope="col">Second Column</th>
      <th style="text-align: right" scope="col">Third Column</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th style="text-align: left" scope="row">First row</th>
      <td style="text-align: center">Cell</td>
      <td style="text-align: right">Cell</td>
    </tr>
    <tr>
      <th style="text-align: left" scope="row">Second row</th>
      <td style="text-align: center">Cell</td>
      <td style="text-align: right">Cell</td>
    </tr>
  </tbody>
</table>
}

  end

  def document_body_with_hashes_for_all_headers
    @document_body_with_hashes_for_all_headers ||= Govspeak::Document.new(%{
|                 |# Second Column  |# Third Column       |
| --------------- | --------------- | ------------------- |
|# First row      | Cell            | Cell                |
|# Second row     | Cell            | Cell                |
})
end

  def document_body_with_hashes_for_row_headers
    @document_body_with_hashes_for_row_headers ||= Govspeak::Document.new(%{
|                 | Second Column   | Third Column        |
| --------------- | --------------- | ------------------- |
|# First row      | Cell            | Cell                |
|# Second row     | Cell            | Cell                |
})
  end

  def document_body_with_alignments
    @document_body_with_alignments ||= Govspeak::Document.new(%{
|                 | Second Column   | Third Column        |
| :-------------- | :-------------: | ------------------: |
|# First row      | Cell            | Cell                |
|# Second row     | Cell            | Cell                |
})
  end

  test "Cells with |# are headers" do
    assert_equal document_body_with_hashes_for_all_headers.to_html, expected_outcome
  end


  test "Cells outside of thead with |# are th; thead still only contains th" do
    assert_equal document_body_with_hashes_for_row_headers.to_html, expected_outcome
  end

  test "Cells are aligned correctly" do
    assert_equal document_body_with_alignments.to_html, expected_outcome_for_table_with_alignments
  end
end
