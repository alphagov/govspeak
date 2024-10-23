require "test_helper"

class ContentBlockExtractorTest < Minitest::Test
  extend Minitest::Spec::DSL

  describe "ContentBlockExtractor" do
    subject { Govspeak::ContentBlockExtractor.new(document) }

    describe "when there is no embedded content" do
      let(:document) { "foo" }

      describe "#content_references" do
        it "returns an empty array" do
          assert_equal [], subject.content_references
        end
      end

      describe "#content_ids" do
        it "returns an empty array" do
          assert_equal [], subject.content_ids
        end
      end
    end

    describe "when there is embedded content" do
      let(:contact_uuid) { SecureRandom.uuid }
      let(:content_block_email_address_uuid) { SecureRandom.uuid }

      let(:document) do
        """
        {{embed:contact:#{contact_uuid}}}
        {{embed:content_block_email_address:#{content_block_email_address_uuid}}}
      """
      end

      describe "#content_references" do
        it "returns all references" do
          result = subject.content_references

          assert_equal 2, result.count

          assert_equal "contact", result[0].document_type
          assert_equal contact_uuid, result[0].content_id
          assert_equal "{{embed:contact:#{contact_uuid}}}", result[0].embed_code

          assert_equal "content_block_email_address", result[1].document_type
          assert_equal content_block_email_address_uuid, result[1].content_id
          assert_equal "{{embed:content_block_email_address:#{content_block_email_address_uuid}}}", result[1].embed_code
        end
      end

      describe "#content_ids" do
        it "returns all uuids as an array" do
          assert_equal [contact_uuid, content_block_email_address_uuid], subject.content_ids
        end
      end
    end
  end
end
