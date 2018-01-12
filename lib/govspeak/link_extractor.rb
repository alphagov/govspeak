module Govspeak
  class LinkExtractor
    def initialize(document, website_root: nil)
      @document = document
      @website_root = website_root
    end

    def call
      @links ||= extract_links
    end

  private

    attr_reader :document, :website_root

    def extract_links
      document_anchors.map do |link|
        if website_root && link['href'].start_with?('/')
          "#{website_root}#{link['href']}"
        else
          link['href']
        end
      end
    end

    def document_anchors
      processed_govspeak.css('a:not([href^="mailto"])').css('a:not([href^="#"])')
    end

    def processed_govspeak
      doc = Nokogiri::HTML::Document.new
      doc.encoding = "UTF-8"

      doc.fragment(document.to_html)
    end
  end
end
