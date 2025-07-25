require "active_support"
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
require "govspeak/blockquote_extra_quote_remover"
require "govspeak/post_processor"
require "govspeak/link_extractor"
require "govspeak/template_renderer"
require "govspeak/translation_helper"
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
    UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
    NEW_PARAGRAPH_LOOKBEHIND = %q{(?<=\A|\n\n|\r\n\r\n)}.freeze

    @extensions = []

    attr_accessor :images
    attr_reader :attachments, :contacts, :links, :locale, :log_snapshots

    def self.to_html(source, options = {})
      new(source, options).to_html
    end

    class << self
      attr_reader :extensions
    end

    def initialize(source, options = {})
      options = options.dup.deep_symbolize_keys
      @source = source ? source.dup : ""

      @log_snapshots = options.fetch(:log_snapshots, false)
      log_snapshot("options", options)
      log_snapshot("source", @source)

      @images = options.delete(:images) || []
      @allowed_elements = options.delete(:allowed_elements) || []
      @allowed_image_hosts = options.delete(:allowed_image_hosts) || []
      @attachments = Array.wrap(options.delete(:attachments))
      @links = Array.wrap(options.delete(:links))
      @contacts = Array.wrap(options.delete(:contacts))
      @locale = options.fetch(:locale, "en")
      @options = { input: PARSER_CLASS_NAME,
                   sanitize: true,
                   syntax_highlighter: nil }.merge(options)
      @options[:entity_output] = :symbolic
    end

    def to_html
      @to_html ||= begin
        html = if @options[:sanitize]
                 HtmlSanitizer.new(kramdown_doc.to_html, allowed_image_hosts: @allowed_image_hosts)
                              .sanitize(allowed_elements: @allowed_elements)
               else
                 kramdown_doc.to_html
               end

        log_snapshot("after Kramdown process", html)

        Govspeak::PostProcessor.process(html, self).tap do
          log_snapshot("after postprocess", _1)
        end
      end
    end

    def to_liquid
      to_html
    end

    def to_text
      HTMLEntities.new.decode(to_html.gsub(/(?:<[^>]+>|\s)+/, " ").strip)
    end

    def valid?(validation_options = {})
      Govspeak::HtmlValidator.new(
        @source,
        validation_options.merge({ locale: @locale }),
      ).valid?
    end

    def headers
      Govspeak::HeaderExtractor.convert(kramdown_doc).first
    end

    def structured_headers
      Govspeak::StructuredHeaderExtractor.new(self).call
    end

    def extracted_links(website_root: nil)
      Govspeak::LinkExtractor.new(self, website_root:).call
    end

    def extract_contact_content_ids
      _, regex = self.class.extensions.find { |(title)| title == "Contact" }
      return [] unless regex

      @source.scan(regex).map(&:first).uniq.select { |id| id.match(UUID_REGEX) }
    end

    def preprocess(source)
      source = Govspeak::BlockquoteExtraQuoteRemover.remove(source)
      source = remove_forbidden_characters(source)

      self.class.extensions.each do |_, regexp, block|
        source.gsub!(regexp) do
          instance_exec(*Regexp.last_match.captures, &block)
        end
      end

      source.tap { log_snapshot("after preprocess", _1) }
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
        content = if parser
                    parser.new("#{body.strip}\n", locale: @locale).to_html
                  else
                    body.strip
                  end
        %(\n<div class="#{class_name}">\n#{content}</div>\n)
      end
    end

    def insert_strong_inside_p(body, parser = Govspeak::Document)
      parser
        .new(body.strip, locale: @locale)
        .to_html
        .sub(/^<p>(.*)<\/p>$/, "<p><strong>\\1</strong></p>")
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
#{Govspeak::Document.new(body.strip, locale: @locale).to_html}</div>\n)
    end

    extension("stat-headline", %r${stat-headline}(.*?){/stat-headline}$m) do |body|
      %(\n\n<div class="stat-headline">
#{Govspeak::Document.new(body.strip, locale: @locale).to_html}</div>\n)
    end

    extension("external", surrounded_by("x[", ")x")) do |body|
      Kramdown::Document.new("[#{body.strip}){:rel='external'}").to_html
    end

    extension("informational", surrounded_by("^")) do |body|
      <<~BODY
        \n\n<div role="note" aria-label="Information" class="application-notice info-notice" markdown="1">
        #{body.strip}
        </div>
      BODY
    end

    extension("helpful", surrounded_by("%")) do |body|
      %(\n\n<div role="note" aria-label="Warning" class="application-notice help-notice">\n#{Govspeak::Document.new(body.strip, locale: @locale).to_html}</div>\n)
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

      render_image(ImagePresenter.new(image, locale:))
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
      <<~BODY
        <div class="call-to-action" markdown="1">
        #{body.strip.gsub(/\A^\|/, "\n|").gsub(/\|$\Z/, "|\n")}
        </div>
      BODY
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

    extension("example", surrounded_by("$E")) do |body|
      <<~BODY
        <div class="example" markdown="1">
        #{body.strip.gsub(/\A^\|/, "\n|").gsub(/\|$\Z/, "|\n")}
        </div>
      BODY
    end

    extension("address", surrounded_by("$A")) do |body|
      <<~BODY

        <div class="address"><div class="adr org fn"><p markdown="1">
        #{body.lstrip.sub(/[\s\\]*\z/, '').gsub(/[ \\]*\r?\n/, '<br />')}
        </p></div></div>
      BODY
    end

    extension("legislative list", /#{NEW_PARAGRAPH_LOOKBEHIND}\$LegislativeList\s*$(.*?)\$EndLegislativeList/m) do |body|
      # The surrounding div is neccessary to accurately identify legislative lists
      # in post-processing.
      <<~BODY
        {::options ordered_lists_disabled=\"true\" /}
        <div class="legislative-list-wrapper" markdown="1">#{body}</div>
        {::options ordered_lists_disabled=\"false\" /}
      BODY
    end

    extension("numbered list", /^[ \t]*((s\d+\.\s.*(?:\n|$))+)/) do |body|
      li_elements = body.gsub!(/s(\d+)\.\s(.*)(?:\n|$)/).map do
        element = <<~BODY
          <li markdown="1">
            #{Regexp.last_match(2).strip}
          </li>
        BODY
        element.strip
      end
      <<~BODY
        <ol class="steps">
          #{li_elements.join("\n  ")}
        </ol>
      BODY
    end

    %w[scotland
       england
       england-wales
       northern-ireland
       wales
       london].each do |devolved_option|
      extension(
        "devolved-#{devolved_option}",
        /:#{devolved_option}:(.*?):#{devolved_option}:/m,
      ) do |body|
        header_content = Govspeak::TranslationHelper.t_with_fallback(
          "govspeak.devolved.#{devolved_option}",
          locale:,
        )
        body_content = Govspeak::Document
          .new(body.strip, locale: @locale)
          .to_html

        <<~HTML
          <div class="devolved-content #{devolved_option}">
          <p class="devolved-header">#{header_content}</p>
          <div class="devolved-body">#{body_content}</div>
          </div>
        HTML
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

    extension("Image", /^\[Image:\s*(.*?)\s*\]/) do |image_id|
      image = images.detect { |c| c.is_a?(Hash) && c[:id] == image_id }
      next "" unless image

      render_image(ImagePresenter.new(image, locale:))
    end

    extension("Attachment", /^\[Attachment:\s*(.*?)\s*\]/) do |attachment_id|
      next "" if attachments.none? { |a| a[:id] == attachment_id }

      %(<govspeak-embed-attachment id="#{attachment_id}"></govspeak-embed-attachment>)
    end

    extension("AttachmentLink", /\[AttachmentLink:\s*(.*?)\s*\]/) do |attachment_id|
      next "" if attachments.none? { |a| a[:id] == attachment_id }

      %(<govspeak-embed-attachment-link id="#{attachment_id}"></govspeak-embed-attachment-link>)
    end

  private

    def log_snapshot(description, *objects)
      return unless log_snapshots

      puts "===== #{description} ====="
      !objects.empty? && objects.each { puts _1 }
    end

    def kramdown_doc
      @kramdown_doc ||= Kramdown::Document.new(preprocess(@source), @options)
    end

    def encode(text)
      HTMLEntities.new.encode(text)
    end
  end
end

locale_paths = *Dir.glob(File.expand_path("locales/*.yml", Govspeak.root))

I18n.load_path.unshift(locale_paths)
I18n.available_locales = locale_paths.map do |path|
  path.match(/([^\/]+).yml/)[1].to_sym
end
I18n.default_locale = :en
