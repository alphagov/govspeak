module Govspeak
  class ContentBlockExtractor
    def initialize(document)
      @document = document
    end

    def content_references
      @content_references ||= @document.scan(ContentBlock::EMBED_REGEX).map { |match|
        ContentBlock.new(document_type: match[1], content_id: match[2], embed_code: match[0])
      }.uniq
    end

    def content_ids
      @content_ids ||= content_references.map(&:content_id)
    end
  end
end
