require 'active_support/core_ext/hash'
require 'active_support/core_ext/array'
require 'erb'
require 'htmlentities'
require 'kramdown'
require 'kramdown/parser/kramdown_with_automatic_external_links'
require 'rinku'
require 'govspeak/header_extractor'
require 'govspeak/structured_header_extractor'
require 'govspeak/html_validator'
require 'govspeak/html_sanitizer'
require 'govspeak/kramdown_overrides'
require 'govspeak/blockquote_extra_quote_remover'
require 'govspeak/post_processor'
require 'govspeak/link_extractor'
require 'govspeak/template_renderer'
require 'govspeak/presenters/attachment_presenter'
require 'govspeak/presenters/contact_presenter'
require 'govspeak/presenters/h_card_presenter'
require 'govspeak/presenters/image_presenter'
require 'govspeak/presenters/attachment_image_presenter'


module Govspeak
  def self.root
    File.expand_path('..', File.dirname(__FILE__))
  end

  class Document
    Parser = Kramdown::Parser::KramdownWithAutomaticExternalLinks
    PARSER_CLASS_NAME = Parser.name.split("::").last
    UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.freeze
    NEW_PARAGRAPH_LOOKBEHIND = %q{(?<=\A|\n\n|\r\n\r\n)}.freeze

    @extensions = []

    attr_accessor :images
    attr_reader :attachments, :contacts, :links, :locale

    def self.to_html(source, options = {})
      new(source, options).to_html
    end

    def self.extensions
      @extensions
    end

    def initialize(source, options = {})
      options = options.dup.deep_symbolize_keys
      unsanitized_source = source ? source.dup : ""

      @source = if options[:sanitize]
                  HtmlSanitizer.new(unsanitized_source).sanitize
                else
                  unsanitized_source
                end

      @images = options.delete(:images) || []
      @attachments = Array.wrap(options.delete(:attachments))
      @links = Array.wrap(options.delete(:links))
      @contacts = Array.wrap(options.delete(:contacts))
      @locale = options.fetch(:locale, "en")
      @options = { input: PARSER_CLASS_NAME }.merge(options)
      @options[:entity_output] = :symbolic
    end

    def to_html
      @to_html ||= Govspeak::PostProcessor.process(kramdown_doc.to_html, self)
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
      self.class.extensions.each do |_, regexp, block|
        source.gsub!(regexp) {
          instance_exec(*Regexp.last_match.captures, &block)
        }
      end
      source
    end

    def self.extension(title, regexp = nil, &block)
      regexp ||= %r${::#{title}}(.*?){:/#{title}}$m
      @extensions << [title, regexp, block]
    end

    def self.surrounded_by(open, close = nil)
      open = Regexp::escape(open)
      if close
        close = Regexp::escape(close)
        %r+(?:\r|\n|^)#{open}(.*?)#{close} *(\r|\n|$)?+m
      else
        %r+(?:\r|\n|^)#{open}(.*?)#{open}? *(\r|\n|$)+m
      end
    end

    def self.wrap_with_div(class_name, character, parser = Kramdown::Document)
      extension(class_name, surrounded_by(character)) { |body|
        content = parser ? parser.new("#{body.strip}\n").to_html : body.strip
        %{\n<div class="#{class_name}">\n#{content}</div>\n}
      }
    end

    def insert_strong_inside_p(body, parser = Govspeak::Document)
      parser.new(body.strip).to_html.sub(/^<p>(.*)<\/p>$/, "<p><strong>\\1</strong></p>")
    end

    extension('button', %r{
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
      {\/button} # match ending bracket
      (?:\r|\n|$) # non-capturing match to make sure end of line and linebreak
    }x) { |attributes, text, href|
      button_classes = "button"
      button_classes << " button-start" if attributes =~ /start/
      /cross-domain-tracking:(?<cross_domain_tracking>.[^\s*]+)/ =~ attributes
      data_attribute = ""
      if cross_domain_tracking
        data_attribute << " data-module='cross-domain-tracking'"
        data_attribute << " data-tracking-code='#{cross_domain_tracking.strip}'"
        data_attribute << " data-tracking-name='govspeakButtonTracker'"
      end
      text = text.strip
      href = href.strip

      %{\n<a role="button" class="#{button_classes}" href="#{href}" #{data_attribute}>#{text}</a>\n}
    }

    extension('highlight-answer') { |body|
      %{\n\n<div class="highlight-answer">
#{Govspeak::Document.new(body.strip).to_html}</div>\n}
    }

    extension('stat-headline', %r${stat-headline}(.*?){/stat-headline}$m) { |body|
      %{\n\n<aside class="stat-headline">
#{Govspeak::Document.new(body.strip).to_html}</aside>\n}
    }

    # FIXME: these surrounded_by arguments look dodgy
    extension('external', surrounded_by("x[", ")x")) { |body|
      Kramdown::Document.new("[#{body.strip}){:rel='external'}").to_html
    }

    extension('informational', surrounded_by("^")) { |body|
      %{\n\n<div role="note" aria-label="Information" class="application-notice info-notice">
#{Govspeak::Document.new(body.strip).to_html}</div>\n}
    }

    extension('important', surrounded_by("@")) { |body|
      %{\n\n<div role="note" aria-label="Important" class="advisory">#{insert_strong_inside_p(body)}</div>\n}
    }

    extension('helpful', surrounded_by("%")) { |body|
      %{\n\n<div role="note" aria-label="Help" class="application-notice help-notice">\n#{Govspeak::Document.new(body.strip).to_html}</div>\n}
    }

    extension('barchart', /{barchart(.*?)}/) do |captures|
      stacked = '.mc-stacked' if captures.include? 'stacked'
      compact = '.compact' if captures.include? 'compact'
      negative = '.mc-negative' if captures.include? 'negative'

      [
       '{:',
       '.js-barchart-table',
       stacked,
       compact,
       negative,
       '.mc-auto-outdent',
       '}'
      ].join(' ')
    end

    extension('attached-image', /^!!([0-9]+)/) do |image_number|
      image = images[image_number.to_i - 1]
      next "" unless image

      render_image(ImagePresenter.new(image))
    end

    extension('attachment', /\[embed:attachments:(?!inline:|image:)\s*(.*?)\s*\]/) do |content_id|
      # not treating this as a self closing tag seems to avoid some oddities
      # such as an extra new line being inserted when explicitly closed or
      # swallowing subsequent elements when not closed
      %{<govspeak-embed-attachment content-id="#{content_id}"></govspeak-embed-attachment>}
    end

    extension('attachment inline', /\[embed:attachments:inline:\s*(.*?)\s*\]/) do |content_id|
      attachment = attachments.detect { |a| a[:content_id] == content_id }
      next "" unless attachment

      attachment = AttachmentPresenter.new(attachment)
      span_id = attachment.id ? %{ id="attachment_#{attachment.id}"} : ""
      # new lines inside our title cause problems with govspeak rendering as this is expected to be on one line.
      title = (attachment.title || "").tr("\n", " ")
      link = attachment.link(title, attachment.url)
      attributes = attachment.attachment_attributes.empty? ? "" : " (#{attachment.attachment_attributes})"
      %{<span#{span_id} class="attachment-inline">#{link}#{attributes}</span>}
    end

    # DEPRECATED: use 'Image:image-id' instead
    extension('attachment image', /\[embed:attachments:image:\s*(.*?)\s*\]/) do |content_id|
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
      id_attr = image.id ? %{ id="attachment_#{image.id}"} : ""
      lines = []
      lines << %{<figure#{id_attr} class="image embedded">}
      lines << %{<div class="img"><img src="#{encode(image.url)}" alt="#{encode(image.alt_text)}"></div>}
      lines << image.figcaption_html if image.figcaption?
      lines << '</figure>'
      lines.join
    end

    wrap_with_div('summary', '$!')
    wrap_with_div('form-download', '$D')
    wrap_with_div('contact', '$C')
    wrap_with_div('place', '$P', Govspeak::Document)
    wrap_with_div('information', '$I', Govspeak::Document)
    wrap_with_div('additional-information', '$AI')
    wrap_with_div('example', '$E', Govspeak::Document)
    wrap_with_div('call-to-action', '$CTA', Govspeak::Document)

    extension('address', surrounded_by("$A")) { |body|
      %{\n<div class="address"><div class="adr org fn"><p>\n#{body.sub("\n", '').gsub("\n", '<br />')}\n</p></div></div>\n}
    }

    extension("legislative list", /#{NEW_PARAGRAPH_LOOKBEHIND}\$LegislativeList\s*$(.*?)\$EndLegislativeList/m) do |body|
      Govspeak::KramdownOverrides.with_kramdown_ordered_lists_disabled do
        Kramdown::Document.new(body.strip).to_html.tap do |doc|
          doc.gsub!('<ul>', '<ol>')
          doc.gsub!('</ul>', '</ol>')
          doc.sub!('<ol>', '<ol class="legislative-list">')
        end
      end
    end

    extension("numbered list", /^[ \t]*((s\d+\.\s.*(?:\n|$))+)/) do |body|
      body.gsub!(/s(\d+)\.\s(.*)(?:\n|$)/) do
        "<li>#{Govspeak::Document.new($2.strip).to_html}</li>\n"
      end
      %{<ol class="steps">\n#{body}</ol>}
    end

    def self.devolved_options
      { 'scotland' => 'Scotland',
        'england' => 'England',
        'england-wales' => 'England and Wales',
        'northern-ireland' => 'Northern Ireland',
        'wales' => 'Wales',
        'london' => 'London' }
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

    extension('embed link', /\[embed:link:\s*(.*?)\s*\]/) do |content_id|
      link = links.detect { |l| l[:content_id] == content_id }
      next "" unless link

      if link[:url]
        "[#{link[:title]}](#{link[:url]})"
      else
        link[:title]
      end
    end

    extension('Contact', /\[Contact:\s*(.*?)\s*\]/) do |content_id|
      contact = contacts.detect { |c| c[:content_id] == content_id }
      next "" unless contact

      renderer = TemplateRenderer.new('contact.html.erb', locale)
      renderer.render(contact: ContactPresenter.new(contact))
    end

    extension('Image', /#{NEW_PARAGRAPH_LOOKBEHIND}\[Image:\s*(.*?)\s*\]/) do |image_id|
      image = images.detect { |c| c.is_a?(Hash) && c[:id] == image_id }
      next "" unless image

      render_image(ImagePresenter.new(image))
    end

  private

    def kramdown_doc
      @kramdown_doc ||= Kramdown::Document.new(preprocess(@source), @options)
    end

    def encode(text)
      HTMLEntities.new.encode(text)
    end
  end
end

I18n.load_path.unshift(
  *Dir.glob(File.expand_path('locales/*.yml', Govspeak.root))
)
