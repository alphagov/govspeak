require 'nokogiri'

module Govspeak
  class PostProcessor
    attr_reader :input

    @@extensions = []

    def initialize(html)
      @input = html
    end

    def nokogiri_document
      doc = Nokogiri::HTML::Document.new
      doc.encoding = "UTF-8"
      doc.fragment(input)
    end
    private :nokogiri_document

    def self.process(html)
      new(html).output
    end

    def self.extension(title, &block)
      @@extensions << [title, block]
    end

    def output
      document = nokogiri_document
      @@extensions.each do |_, block|
        instance_exec(document, &block)
      end
      document.to_html
    end

    extension("add class to last p of blockquote") do |document|
      document.css("blockquote p:last-child").map do |el|
        el[:class] = "last-child"
      end
    end
  end
end
