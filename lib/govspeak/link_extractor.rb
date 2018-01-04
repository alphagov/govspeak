module Govspeak
  class LinkExtractor
    def initialize(document)
      @document = document
    end

    def call
      @links ||= extract_links
    end

  private

    def extract_links
      document_anchors.map { |link| link['href'] }
    end

    def document_anchors
      processed_govspeak.css('a:not([href^="mailto"])').css('a:not([href^="#"])')
    end

    def processed_govspeak
      doc = Nokogiri::HTML::Document.new
      doc.encoding = "UTF-8"

      doc.fragment(@document.to_html)
    end
  end
end
