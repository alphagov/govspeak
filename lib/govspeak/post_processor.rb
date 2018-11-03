require 'nokogiri'

module Govspeak
  class PostProcessor
    @extensions = []

    def self.extensions
      @extensions
    end

    def self.process(html)
      new(html).output
    end

    def self.extension(title, &block)
      @extensions << [title, block]
    end

    extension("add class to last p of blockquote") do |document|
      document.css("blockquote p:last-child").map do |el|
        el[:class] = "last-child"
      end
    end

    # This "fix" here is tied into the rendering of images as one of the
    # pre-processor tasks. As images can be created inside block level elements
    # it's possible that their block level elements can be HTML entity escaped
    # to produce "valid" HTML.
    #
    # This sucks for us as we spit the user out HTML elements.
    #
    # This fix reverses this, and of course, totally sucks because it's tightly
    # coupled to the `render_image` code and it really isn't cool to undo HTML
    # entity encoding.
    extension("fix image attachment escaping") do |document|
      document.css("figure.image").map do |el|
        xml = el.children.to_s
        next unless xml =~ /&lt;div class="img"&gt;|&lt;figcaption&gt;/

        el.children = xml
          .gsub(
            %r{&lt;(div class="img")&gt;(.*?)&lt;(/div)&gt;},
            "<\\1>\\2<\\3>"
          )
          .gsub(
            %r{&lt;(figcaption)&gt;(.*?)&lt;(/figcaption&)gt;},
            "<\\1>\\2<\\3>"
          )
      end
    end

    attr_reader :input

    def initialize(html)
      @input = html
    end

    def output
      document = nokogiri_document
      self.class.extensions.each do |_, block|
        instance_exec(document, &block)
      end
      document.to_html
    end


  private

    def nokogiri_document
      doc = Nokogiri::HTML::Document.new
      doc.encoding = "UTF-8"
      doc.fragment(input)
    end
  end
end
