module Govspeak
  class ImagePresenter
    attr_reader :image

    def initialize(image)
      @image = image
    end

    def url
      image.respond_to?(:url) ? image.url : image[:url]
    end

    def alt_text
      image.respond_to?(:alt_text) ? image.alt_text : image[:alt_text]
    end

    def caption
      (image.respond_to?(:caption) ? image.caption : image[:caption]).to_s.strip.presence
    end

    def credit
      (image.respond_to?(:credit) ? image.credit : image[:credit]).to_s.strip.presence
    end

    def id
      nil
    end

    def figcaption?
      caption.present? || credit.present?
    end

    def figcaption_html
      lines = []
      lines << "<figcaption>"
      lines << %{<p>#{caption}</p>} if caption.present?
      lines << %{<p>#{I18n.t('govspeak.image.figure.credit', credit: credit)}</p>} if credit.present?
      lines << "</figcaption>"
      lines.join
    end
  end
end
