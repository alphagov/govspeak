require "active_support/core_ext/hash"
require "active_support/core_ext/array"
require "erb"
require "govuk_publishing_components"
require "htmlentities"
require "kramdown"
require "kramdown/parser/govuk"
require "nokogiri"
require "rinku"
require "sanitize"
require "govspeak/header_extractor"
require "govspeak/structured_header_extractor"
require "govspeak/html_validator"
require "govspeak/html_sanitizer"
require "govspeak/kramdown_overrides"
require "govspeak/blockquote_extra_quote_remover"
require "govspeak/post_processor"
require "govspeak/link_extractor"
require "govspeak/template_renderer"
require "govspeak/presenters/attachment_presenter"
require "govspeak/presenters/contact_presenter"
require "govspeak/presenters/h_card_presenter"
require "govspeak/presenters/image_presenter"
require "govspeak/presenters/attachment_image_presenter"

module Govspeak
  def self.root
    File.expand_path("..", File.dirname(__FILE__))
  end

  class Document
    Parser = Kramdown::Parser::Govuk
    PARSER_CLASS_NAME = Parser.name.split("::").last
    UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.freeze
    NEW_PARAGRAPH_LOOKBEHIND = %q{(?<=\A|\n\n|\r\n\r\n)}.freeze

    @extensions = []

    attr_accessor :images
    attr_reader :attachments, :contacts, :links, :locale

    def self.to_html(source, options = {})
      new(source, options).to_html
    end

    class << self
      attr_reader :extensions
    end

    def initialize(source, options = {})
      options = options.dup.deep_symbolize_keys
      @source = source ? source.dup : ""

      @images = options.delete(:images) || []
      @allowed_elements = options.delete(:allowed_elements) || []
      @attachments = Array.wrap(options.delete(:attachments))
      @links = Array.wrap(options.delete(:links))
      @contacts = Array.wrap(options.delete(:contacts))
      @locale = options.fetch(:locale, "en")
      @options = { input: PARSER_CLASS_NAME,
                   sanitize: true,
                   syntax_highlighter: nil }.merge(options)
      @options[:entity_output] = :symbolic
      @footnote_definition_html = nil
      @acronyms = []
    end

    def to_html
      @to_html ||= begin
        html = if @options[:sanitize]
                 HtmlSanitizer.new(kramdown_doc.to_html).sanitize(allowed_elements: @allowed_elements)
               else
                 kramdown_doc.to_html
               end

        unless @footnote_definition_html.nil?
          regex = /<div class="footnotes".*[<\/div>]/m

          if html.scan(regex).empty?
            html << @footnote_definition_html
          else
            html.gsub!(regex, @footnote_definition_html)
          end
        end

        Govspeak::PostProcessor.process(html, self)
      end
    end

    def to_liquid
      to_html
    end

    def to_text
      HTMLEntities.new.decode(to_html.gsub(/(?:<[^>]+>|\s)+/, " ").strip)
    end

    def valid?(validation_options = {})
      Govspeak::HtmlValidator.new(@source, validation_options).valid?
    end

    def headers
      Govspeak::HeaderExtractor.convert(kramdown_doc).first
    end

    def structured_headers
      Govspeak::StructuredHeaderExtractor.new(self).call
    end

    def extracted_links(website_root: nil)
      Govspeak::LinkExtractor.new(self, website_root: website_root).call
    end

    def extract_contact_content_ids
      _, regex = self.class.extensions.find { |(title)| title == "Contact" }
      return [] unless regex

      @source.scan(regex).map(&:first).uniq.select { |id| id.match(UUID_REGEX) }
    end

    def preprocess(source)
      source = Govspeak::BlockquoteExtraQuoteRemover.remove(source)
      source = remove_forbidden_characters(source)

      footnote_definitions(source)

      self.class.extensions.each do |_, regexp, block|
        source.gsub!(regexp) do
          instance_exec(*Regexp.last_match.captures, &block)
        end
      end
      source
    end

    def footnote_definitions(source)
      is_legislative_list = source.scan(/\$LegislativeList.*?\[\^\d\]*.*?\$EndLegislativeList/m).size.positive?
      is_cta = source.scan(/\$CTA.*?\[\^\d\]*.*?\$CTA/m).size.positive?
      footnotes = source.scan(/\[\^(\d+)\]:(.*)/)
      @acronyms = source.scan(/(?<=\*)\[(.*)\]:(.*)/)
      if (is_legislative_list || is_cta) && footnotes.size.positive?
        list_items = footnotes.map do |footnote|
          number = footnote[0]
          text = footnote[1].strip
          footnote_definition = Govspeak::Document.new(text).to_html[/(?<=<p>).*(?=<\/p>)/]

          <<~HTML_SNIPPET
            <li id="fn:#{number}" role="doc-endnote">
              <p>
                #{footnote_definition}<a href="#fnref:#{number}" class="reversefootnote" role="doc-backlink" aria-label="go to where this is referenced">↩</a>
              </p>
            </li>
          HTML_SNIPPET
        end

        @footnote_definition_html = <<~HTML_CONTAINER
          <div class="footnotes" role="doc-endnotes">
            <ol>
              #{list_items.join.strip}
            </ol>
          </div>
        HTML_CONTAINER
      end

      unless @footnote_definition_html.nil? && @acronyms.size.positive?
        add_acronym_alt_text(@footnote_definition_html)
      end
    end

    def remove_forbidden_characters(source)
      # These are characters that are not deemed not suitable for
      # markup: https://www.w3.org/TR/unicode-xml/#Charlist
      source.gsub(Sanitize::REGEX_UNSUITABLE_CHARS, "")
    end

    def self.extension(title, regexp = nil, &block)
      regexp ||= %r${::#{title}}(.*?){:/#{title}}$m
      @extensions << [title, regexp, block]
    end

    def self.surrounded_by(open, close = nil)
      open = Regexp.escape(open)
      if close
        close = Regexp.escape(close)
        %r{(?:\r|\n|^)#{open}(.*?)#{close} *(\r|\n|$)?}m
      else
        %r{(?:\r|\n|^)#{open}(.*?)#{open}? *(\r|\n|$)}m
      end
    end

    def self.wrap_with_div(class_name, character, parser = Kramdown::Document)
      extension(class_name, surrounded_by(character)) do |body|
        content = parser ? parser.new("#{body.strip}\n").to_html : body.strip
        %(\n<div class="#{class_name}">\n#{content}</div>\n)
      end
    end

    def insert_strong_inside_p(body, parser = Govspeak::Document)
      parser.new(body.strip).to_html.sub(/^<p>(.*)<\/p>$/, "<p><strong>\\1</strong></p>")
    end

    extension("button", %r{
      (?:\r|\n|^) # non-capturing match to make sure start of line and linebreak
      {button(.*?)} # match opening bracket and capture attributes
        \s* # any whitespace between opening bracket and link
        \[ # match start of link markdown
          ([^\]]+) # capture inside of link markdown
        \] # match end of link markdown
        \( # match start of link text markdown
          ([^)]+)  # capture inside of link text markdown
        \) # match end of link text markdown
        \s*  # any whitespace between opening bracket and link
      {/button} # match ending bracket
      (?:\r|\n|$) # non-capturing match to make sure end of line and linebreak
    }x) do |attributes, text, href|
      button_classes = "govuk-button"
      /cross-domain-tracking:(?<cross_domain_tracking>.[^\s*]+)/ =~ attributes
      data_attribute = ""
      data_attribute << " data-start='true'" if attributes =~ /start/
      if cross_domain_tracking
        data_attribute << " data-module='cross-domain-tracking'"
        data_attribute << " data-tracking-code='#{cross_domain_tracking.strip}'"
        data_attribute << " data-tracking-name='govspeakButtonTracker'"
      end
      text = text.strip
      href = href.strip

      %(\n<a role="button" draggable="false" class="#{button_classes}" href="#{href}" #{data_attribute}>#{text}</a>\n)
    end

    extension("highlight-answer") do |body|
      %(\n\n<div class="highlight-answer">
#{Govspeak::Document.new(body.strip).to_html}</div>\n)
    end

    extension("stat-headline", %r${stat-headline}(.*?){/stat-headline}$m) do |body|
      %(\n\n<div class="stat-headline">
#{Govspeak::Document.new(body.strip).to_html}</div>\n)
    end

    # FIXME: these surrounded_by arguments look dodgy
    extension("external", surrounded_by("x[", ")x")) do |body|
      Kramdown::Document.new("[#{body.strip}){:rel='external'}").to_html
    end

    extension("informational", surrounded_by("^")) do |body|
      %(\n\n<div role="note" aria-label="Information" class="application-notice info-notice">
#{Govspeak::Document.new(body.strip).to_html}</div>\n)
    end

    extension("important", surrounded_by("@")) do |body|
      %(\n\n<div role="note" aria-label="Important" class="advisory">#{insert_strong_inside_p(body)}</div>\n)
    end

    extension("helpful", surrounded_by("%")) do |body|
      %(\n\n<div role="note" aria-label="Warning" class="application-notice help-notice">\n#{Govspeak::Document.new(body.strip).to_html}</div>\n)
    end

    extension("barchart", /{barchart(.*?)}/) do |captures|
      stacked = ".mc-stacked" if captures.include? "stacked"
      compact = ".compact" if captures.include? "compact"
      negative = ".mc-negative" if captures.include? "negative"

      [
        "{:",
        ".js-barchart-table",
        stacked,
        compact,
        negative,
        ".mc-auto-outdent",
        "}",
      ].join(" ")
    end

    extension("attached-image", /^!!([0-9]+)/) do |image_number|
      image = images[image_number.to_i - 1]
      next "" unless image

      render_image(ImagePresenter.new(image))
    end

    # DEPRECATED: use 'AttachmentLink:attachment-id' instead
    extension("embed attachment inline", /\[embed:attachments:inline:\s*(.*?)\s*\]/) do |content_id|
      attachment = attachments.detect { |a| a[:content_id] == content_id }
      next "" unless attachment

      attachment = AttachmentPresenter.new(attachment)

      span_id = attachment.id ? %( id="attachment_#{attachment.id}") : ""
      # new lines inside our title cause problems with govspeak rendering as this is expected to be on one line.
      title = (attachment.title || "").tr("\n", " ")
      link = attachment.link(title, attachment.url)
      attributes = attachment.attachment_attributes.empty? ? "" : " (#{attachment.attachment_attributes})"
      %(<span#{span_id} class="attachment-inline">#{link}#{attributes}</span>)
    end

    # DEPRECATED: use 'Image:image-id' instead
    extension("attachment image", /\[embed:attachments:image:\s*(.*?)\s*\]/) do |content_id|
      attachment = attachments.detect { |a| a[:content_id] == content_id }
      next "" unless attachment

      render_image(AttachmentImagePresenter.new(attachment))
    end

    # As of version 1.12.0 of Kramdown the block elements (div & figcaption)
    # inside this html block will have it's < > converted into HTML Entities
    # when ever this code is used inside block level elements.
    #
    # To resolve this we have a post-processing task that will convert this
    # back into HTML (I know - it's ugly). The way we could resolve this
    # without ugliness would be to output only inline elements which rules
    # out div and figcaption
    #
    # This issue is not considered a bug by kramdown: https://github.com/gettalong/kramdown/issues/191
    def render_image(image)
      id_attr = image.id ? %( id="attachment_#{image.id}") : ""
      lines = []
      lines << %(<figure#{id_attr} class="image embedded">)
      lines << %(<div class="img"><img src="#{encode(image.url)}" alt="#{encode(image.alt_text)}"></div>)
      lines << image.figcaption_html if image.figcaption?
      lines << "</figure>"
      lines.join
    end

    extension("call-to-action", surrounded_by("$CTA")) do |body|
      doc = Kramdown::Document.new(body.strip).to_html
      doc = %(\n<div class="call-to-action">\n#{doc}</div>\n)
      footnotes = body.scan(/\[\^(\d+)\]/).flatten

      footnotes.each do |footnote|
        html = "<sup id=\"fnref:#{footnote}\" role=\"doc-noteref\">" \
        "<a href=\"#fn:#{footnote}\" class=\"footnote\" rel=\"footnote\">" \
        "[footnote #{footnote}]</a></sup>"

        doc.sub!(/(\[\^#{footnote}\])/, html)
      end

      add_acronym_alt_text(doc) if @acronyms.size.positive?
      doc
    end

    # More specific tags must be defined first. Those defined earlier have a
    # higher precedence for being matched. For example $CTA must be defined
    # before $C otherwise the first ($C)TA fill be matched to a contact tag.
    wrap_with_div("summary", "$!")
    wrap_with_div("form-download", "$D")
    wrap_with_div("contact", "$C")
    wrap_with_div("place", "$P", Govspeak::Document)
    wrap_with_div("information", "$I", Govspeak::Document)
    wrap_with_div("additional-information", "$AI")
    wrap_with_div("example", "$E", Govspeak::Document)

    extension("address", surrounded_by("$A")) do |body|
      %(\n<div class="address"><div class="adr org fn"><p>\n#{body.sub("\n", '').gsub("\n", '<br />')}\n</p></div></div>\n)
    end

    extension("legislative list", /#{NEW_PARAGRAPH_LOOKBEHIND}\$LegislativeList\s*$(.*?)\$EndLegislativeList/m) do |body|
      Govspeak::KramdownOverrides.with_kramdown_ordered_lists_disabled do
        Kramdown::Document.new(body.strip).to_html.tap do |doc|
          doc.gsub!("<ul>", "<ol>")
          doc.gsub!("</ul>", "</ol>")
          doc.sub!("<ol>", '<ol class="legislative-list">')

          footnotes = body.scan(/\[\^(\d+)\]/).flatten

          footnotes.each do |footnote|
            html = "<sup id=\"fnref:#{footnote}\" role=\"doc-noteref\">" \
            "<a href=\"#fn:#{footnote}\" class=\"footnote\" rel=\"footnote\">" \
            "[footnote #{footnote}]</a></sup>"

            doc.sub!(/(\[\^#{footnote}\])/, html)
          end

          add_acronym_alt_text(doc) if @acronyms.size.positive?
        end
      end
    end

    extension("numbered list", /^[ \t]*((s\d+\.\s.*(?:\n|$))+)/) do |body|
      body.gsub!(/s(\d+)\.\s(.*)(?:\n|$)/) do
        "<li>#{Govspeak::Document.new(Regexp.last_match(2).strip).to_html}</li>\n"
      end
      %(<ol class="steps">\n#{body}</ol>)
    end

    def self.devolved_options
      { "scotland" => "Scotland",
        "england" => "England",
        "england-wales" => "England and Wales",
        "northern-ireland" => "Northern Ireland",
        "wales" => "Wales",
        "london" => "London" }
    end

    devolved_options.each do |k, v|
      extension("devolved-#{k}", /:#{k}:(.*?):#{k}:/m) do |body|
        <<~HTML
          <div class="devolved-content #{k}">
          <p class="devolved-header">This section applies to #{v}</p>
          <div class="devolved-body">#{Govspeak::Document.new(body.strip).to_html}</div>
          </div>
        HTML
      end
    end

    extension("Priority list", /#{NEW_PARAGRAPH_LOOKBEHIND}\$PriorityList:(\d+)\s*$(.*?)(?:^\s*$|\Z)/m) do |number_to_show, body|
      number_to_show = number_to_show.to_i
      tagged = 0
      Govspeak::Document.new(body.strip).to_html.gsub(/<li>/) do |match|
        if tagged < number_to_show
          tagged += 1
          '<li class="primary-item">'
        else
          match
        end
      end
    end

    extension("embed link", /\[embed:link:\s*(.*?)\s*\]/) do |content_id|
      link = links.detect { |l| l[:content_id] == content_id }
      next "" unless link

      if link[:url]
        "[#{link[:title]}](#{link[:url]})"
      else
        link[:title]
      end
    end

    extension("Contact", /\[Contact:\s*(.*?)\s*\]/) do |content_id|
      contact = contacts.detect { |c| c[:content_id] == content_id }
      next "" unless contact

      renderer = TemplateRenderer.new("contact.html.erb", locale)
      renderer.render(contact: ContactPresenter.new(contact))
    end

    extension("Image", /#{NEW_PARAGRAPH_LOOKBEHIND}\[Image:\s*(.*?)\s*\]/) do |image_id|
      image = images.detect { |c| c.is_a?(Hash) && c[:id] == image_id }
      next "" unless image

      render_image(ImagePresenter.new(image))
    end

    extension("Attachment", /#{NEW_PARAGRAPH_LOOKBEHIND}\[Attachment:\s*(.*?)\s*\]/) do |attachment_id|
      next "" if attachments.none? { |a| a[:id] == attachment_id }

      %(<govspeak-embed-attachment id="#{attachment_id}"></govspeak-embed-attachment>)
    end

    extension("AttachmentLink", /\[AttachmentLink:\s*(.*?)\s*\]/) do |attachment_id|
      next "" if attachments.none? { |a| a[:id] == attachment_id }

      %(<govspeak-embed-attachment-link id="#{attachment_id}"></govspeak-embed-attachment-link>)
    end

  private

    def kramdown_doc
      @kramdown_doc ||= Kramdown::Document.new(preprocess(@source), @options)
    end

    def encode(text)
      HTMLEntities.new.encode(text)
    end

    def add_acronym_alt_text(html)
      @acronyms.each do |acronym|
        html.gsub!(acronym[0], "<abbr title=\"#{acronym[1].strip}\">#{acronym[0]}</abbr>")
      end
    end
  end
end

I18n.load_path.unshift(
  *Dir.glob(File.expand_path("locales/*.yml", Govspeak.root)),
)
