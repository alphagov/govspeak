module Govspeak
  class ImagePresenter
    attr_reader :image

    def initialize(image)
      @image = image
    end

    def url
      image[:url]
    end

    def alt_text
      image[:alt_text]
    end

    def caption
      image[:caption].to_s.strip.presence
    end

    def id
      nil
    end
  end
end
