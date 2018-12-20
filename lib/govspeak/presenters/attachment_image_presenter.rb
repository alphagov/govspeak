module Govspeak
  class AttachmentImagePresenter
    attr_reader :attachment

    def initialize(attachment)
      @attachment = AttachmentPresenter.new(attachment)
    end

    def url
      attachment.url
    end

    def alt_text
      (attachment.title || "").tr("\n", " ")
    end

    def caption
      nil
    end

    def credit
      nil
    end

    def id
      attachment.id
    end
  end
end
