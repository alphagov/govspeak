module Govspeak
  class ContentBlock
    SUPPORTED_DOCUMENT_TYPES = %w[contact content_block_email_address].freeze
    UUID_REGEX = /([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})/
    EMBED_REGEX = /({{embed:(#{SUPPORTED_DOCUMENT_TYPES.join('|')}):#{UUID_REGEX}}})/

    attr_reader :document_type, :content_id, :embed_code

    def initialize(document_type:, content_id:, embed_code:)
      @document_type = document_type
      @content_id = content_id
      @embed_code = embed_code
    end
  end
end
