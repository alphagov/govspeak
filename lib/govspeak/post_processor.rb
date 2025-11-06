module Govspeak
  class PostProcessor
    @extensions = []

    class << self
      attr_reader :extensions
    end

    def self.process(html, govspeak_document)
      new(html, govspeak_document).output
    end

    def self.extension(title, &block)
      @extensions << [title, block]
    end

    extension("add class to last p of blockquote") do |document|
      document.css("blockquote p:last-child").map do |el|
        el[:class] = "last-child"
      end
    end

    extension("covert legislative list ul to ol") do |document|
      document.css(".legislative-list-wrapper").map do |el|
        el.inner_html = el.inner_html
            .sub("<ul>", "<ol class=\"legislative-list\">")
            .gsub("</ul>", "</ol>")
            .gsub("<ul>", "<ol>")
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
            "<\\1>\\2<\\3>",
          )
          .gsub(
            %r{&lt;(figcaption)&gt;(.*?)&lt;(/figcaption&)gt;},
            "<\\1>\\2<\\3>",
          )
      end
    end

    extension("embed attachment HTML") do |document|
      document.css("govspeak-embed-attachment").map do |el|
        attachment = govspeak_document.attachments.detect { |a| a[:id] == el["id"] }

        unless attachment
          el.remove
          next
        end

        attachment_html = GovukPublishingComponents.render(
          "govuk_publishing_components/components/attachment",
          attachment:,
          margin_bottom: 6,
          locale: govspeak_document.locale,
        )
        el.swap(attachment_html)
      end
    end

    extension("embed attachment link HTML") do |document|
      document.css("govspeak-embed-attachment-link").map do |el|
        attachment = govspeak_document.attachments.detect { |a| a[:id] == el["id"] }

        unless attachment
          el.remove
          next
        end

        attachment_html = GovukPublishingComponents.render(
          "govuk_publishing_components/components/attachment_link",
          attachment:,
          locale: govspeak_document.locale,
        )
        el.swap(attachment_html)
      end
    end

    extension("Add table headers and row / column scopes") do |document|
      document.css("thead th").map do |el|
        el.inner_html = el.inner_html.gsub(/^# /, "")
        el.inner_html = el.inner_html.gsub(/[[:space:]]/, "") if el.inner_html.blank? # Removes a strange whitespace in the cell if the cell is already blank.
        el.name = "td" if el.inner_html.blank? # This prevents a `th` with nothing inside it; a `td` is preferable.
        el[:scope] = "col" if el.inner_html.present? # `scope` shouldn't be used if there's nothing in the table heading.
      end

      document.css(":not(thead) tr td:first-child").map do |el|
        next unless el.inner_html.match?(/^#($|\s.*$)/)

        # Replace '# ' and '#', but not '#Word'.
        # This runs on the first child of the element to preserve any links
        el.children.first.content = el.children.first.content.gsub(/^#($|\s)/, "")
        el.name = "th" if el.inner_html.present? # This also prevents a `th` with nothing inside it; a `td` is preferable.
        el[:scope] = "row" if el.inner_html.present? # `scope` shouldn't be used if there's nothing in the table heading.
      end
    end

    extension("convert table cell inline styles to classes") do |document|
      document.css("th[style], td[style]").each do |el|
        style = el.remove_attribute("style")
        matches = style.value.scan(/text-align:\s*(left|center|right)/).flatten

        next unless matches.any?

        class_name = "cell-text-#{matches.last}"

        if el[:class]
          el[:class] += " #{class_name}"
        else
          el[:class] = class_name
        end
      end
    end

    extension("use gem component for buttons") do |document|
      document.css(".govuk-button").map do |el|
        button_html = GovukPublishingComponents.render(
          "govuk_publishing_components/components/button",
          text: el.inner_html.html_safe,
          href: el["href"],
          start: el["data-start"],
          data_attributes: {
            module: el["data-module"],
            "tracking-code": el["data-tracking-code"],
            "tracking-name": el["data-tracking-name"],
          },
        ).squish.gsub("> <", "><").gsub!(/\s+/, " ")

        el.swap(button_html)
      end
    end

    extension("use custom footnotes") do |document|
      document.css("a.footnote").map do |el|
        footnote_number = el[:href].gsub(/\D/, "")
        label = Govspeak::TranslationHelper.t_with_fallback("govspeak.footnote.label", locale: govspeak_document.locale)
        el.inner_html = "[#{label} #{footnote_number}]"
      end
      document.css("[role='doc-backlink']").map do |el|
        backlink_number = " #{el.css('sup')[0].content}" if el.css("sup")[0].present?
        aria_label = Govspeak::TranslationHelper.t_with_fallback("govspeak.footnote.backlink_aria_label", locale: govspeak_document.locale)
        el["aria-label"] = "#{aria_label}#{backlink_number}"
      end
    end

    extension("use auto-numbered headers") do |document|
      if govspeak_document.auto_numbered_headers
        h2, h3, h4, h5, h6 = 0, 0, 0, 0, 0, 0

        document.css("h2,h3,h4,h5,h6").map do |el|
          case el.name
          when "h2"
            h2 += 1
            h3 = 0
            h4 = 0
            h5 = 0
            h6 = 0
            el.inner_html = "#{h2}. #{el.inner_html}"
          when "h3"
            h3 += 1
            h4 = 0
            h5 = 0
            h6 = 0
            el.inner_html = "#{h2}.#{h3} #{el.inner_html}"
          when "h4"
            h4 += 1
            h5 = 0
            h6 = 0
            el.inner_html = "#{h2}.#{h3}.#{h4} #{el.inner_html}"
          when "h5"
            h5 += 1
            h6 = 0
            el.inner_html = "#{h2}.#{h3}.#{h4}.#{h5} #{el.inner_html}"
          when "h6"
            h6 += 1
            el.inner_html = "#{h2}.#{h3}.#{h4}.#{h5}.#{h6} #{el.inner_html}"
          end
        end
      end
    end

    attr_reader :input, :govspeak_document

    def initialize(html, govspeak_document)
      @input = html
      @govspeak_document = govspeak_document
    end

    def output
      document = nokogiri_document
      self.class.extensions.each do |(_, block)|
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
