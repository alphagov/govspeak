require "test_helper"

class GovspeakExtractContactContentIdsTest < Minitest::Test
  test "contact content ids can be extracted from govspeak" do
    content_id1 = SecureRandom.uuid
    content_id2 = SecureRandom.uuid
    govspeak = "Some text with a contact\n [Contact:#{content_id1}]\n\n[Contact:#{content_id2}]"

    assert_equal(Govspeak::Document.new(govspeak).extract_contact_content_ids, [content_id1, content_id2])
  end

  test "only extracts contact content ids that are UUIDs" do
    govspeak = "[Contact:12345]"

    refute_equal(
      Govspeak::Document.new(govspeak).extract_contact_content_ids,
      %w[12345],
    )
  end

  test "same contact repeated multiple times only yields a single result" do
    content_id = SecureRandom.uuid
    govspeak = "[Contact:#{content_id}]\n[Contact:#{content_id}][Contact:#{content_id}]"

    assert_equal(Govspeak::Document.new(govspeak).extract_contact_content_ids, [content_id])
  end
end
