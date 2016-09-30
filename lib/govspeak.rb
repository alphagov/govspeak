require 'kramdown'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/array'
require 'govspeak/header_extractor'
require 'govspeak/structured_header_extractor'
require 'govspeak/html_validator'
require 'govspeak/html_sanitizer'
require 'govspeak/kramdown_overrides'
require 'govspeak/blockquote_extra_quote_remover'
require 'govspeak/post_processor'
require 'kramdown/parser/kramdown_with_automatic_external_links'
require 'htmlentities'
require 'presenters/attachment_presenter'
require 'presenters/contact_presenter'
require 'presenters/h_card_presenter'
require 'erb'

module Govspeak

  class Document

    Parser = Kramdown::Parser::KramdownWithAutomaticExternalLinks
    PARSER_CLASS_NAME = Parser.name.split("::").last

    @@extensions = []

    attr_accessor :images
    attr_reader :attachments, :contacts, :links, :locale

    def self.to_html(source, options = {})
      new(source, options).to_html
    end

    def initialize(source, options = {})
      options.deep_symbolize_keys!
      @source = source ? source.dup : ""
      @images = options.delete(:images) || []
      @attachments = Array.wrap(options.delete(:attachments))
      @links = Array.wrap(options.delete(:links))
      @contacts = Array.wrap(options.delete(:contacts))
      @locale = options.fetch(:locale, "en")
      @options = {input: PARSER_CLASS_NAME}.merge(options)
      @options[:entity_output] = :symbolic
      i18n_load_paths
    end

    def i18n_load_paths
      Dir.glob('locales/*.yml') do |f|
        I18n.load_path << f
      end
    end
    private :i18n_load_paths

    def kramdown_doc
      @kramdown_doc ||= Kramdown::Document.new(preprocess(@source), @options)
    end
    private :kramdown_doc

    def to_html
      @html ||= Govspeak::PostProcessor.process(kramdown_doc.to_html)
    end

    def to_liquid
      to_html
    end

    def t(*args)
      options = args.last.is_a?(Hash) ? args.last.dup : {}
      key = args.shift
      I18n.t(key, options.merge(locale: locale))
    end

    def to_sanitized_html
      HtmlSanitizer.new(to_html).sanitize
    end

    def to_sanitized_html_without_images
      HtmlSanitizer.new(to_html).sanitize_without_images
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

    def preprocess(source)
      source = Govspeak::BlockquoteExtraQuoteRemover.remove(source)
      @@extensions.each do |title,regexp,block|
        source.gsub!(regexp) {
          instance_exec(*Regexp.last_match.captures, &block)
        }
      end
      source
    end

    def encode(text)
      HTMLEntities.new.encode(text)
    end
    private :encode

    def self.extension(title, regexp = nil, &block)
      regexp ||= %r${::#{title}}(.*?){:/#{title}}$m
      @@extensions << [title, regexp, block]
    end

    def self.surrounded_by(open, close=nil)
      open = Regexp::escape(open)
      if close
        close = Regexp::escape(close)
        %r+(?:\r|\n|^)#{open}(.*?)#{close} *(\r|\n|$)?+m
      else
        %r+(?:\r|\n|^)#{open}(.*?)#{open}? *(\r|\n|$)+m
      end
    end

    def self.wrap_with_div(class_name, character, parser=Kramdown::Document)
      extension(class_name, surrounded_by(character)) { |body|
        content = parser ? parser.new("#{body.strip}\n").to_html : body.strip
        %{\n<div class="#{class_name}">\n#{content}</div>\n}
      }
    end

    def insert_strong_inside_p(body, parser=Govspeak::Document)
      parser.new(body.strip).to_html.sub(/^<p>(.*)<\/p>$/,"<p><strong>\\1</strong></p>")
    end

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

    extension('barchart', /{barchart(.*?)}/) do |captures, body|
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
      if image
        caption = image.caption rescue nil
        render_image(image.url, image.alt_text, caption)
      else
        ""
      end
    end

    extension('attachment', /\[embed:attachments:(?!inline:|image:)\s*(.*?)\s*\]/) do |content_id, body|
      attachment = attachments.detect { |a| a[:content_id].match(content_id) }
      next "" unless attachment
      attachment = AttachmentPresenter.new(attachment)
      content = File.read(__dir__ + '/templates/attachment.html.erb')
      ERB.new(content).result(binding)
    end

    extension('attachment inline', /\[embed:attachments:inline:\s*(.*?)\s*\]/) do |content_id|
      attachment = attachments.detect { |a| a[:content_id].match(content_id) }
      next "" unless attachment
      attachment = AttachmentPresenter.new(attachment)
      span_id = attachment.id ? %{ id="attachment_#{attachment.id}"} : ""
      # new lines inside our title cause problems with govspeak rendering as this is expected to be on one line.
      title = (attachment.title || "").tr("\n", " ")
      link = attachment.link(title, attachment.url)
      attributes = attachment.attachment_attributes.empty? ? "" : " (#{attachment.attachment_attributes})"
      %{<span#{span_id} class="attachment-inline">#{link}#{attributes}</span>}
    end

    extension('attachment image', /\[embed:attachments:image:\s*(.*?)\s*\]/) do |content_id|
      attachment = attachments.detect { |a| a[:content_id].match(content_id) }
      next "" unless attachment
      attachment = AttachmentPresenter.new(attachment)
      title = (attachment.title || "").tr("\n", " ")
      render_image(attachment.url, title, nil, attachment.id)
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
    def render_image(url, alt_text, caption = nil, id = nil)
      id_attr = id ? %{ id="attachment_#{id}"} : ""
      lines = []
      lines << %{<figure#{id_attr} class="image embedded">}
      lines << %Q{<div class="img"><img src="#{encode(url)}" alt="#{encode(alt_text)}"></div>}
      lines << %Q{<figcaption>#{caption.strip}</figcaption>} if caption && !caption.strip.empty?
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
      %{\n<div class="address"><div class="adr org fn"><p>\n#{body.sub("\n", "").gsub("\n", "<br />")}\n</p></div></div>\n}
    }

    extension("legislative list", /(?<=\A|\n\n|\r\n\r\n)^\$LegislativeList\s*$(.*?)\$EndLegislativeList/m) do |body|
      Govspeak::KramdownOverrides.with_kramdown_ordered_lists_disabled do
        Kramdown::Document.new(body.strip).to_html.tap do |doc|
          doc.gsub!('<ul>', '<ol>')
          doc.gsub!('</ul>', '</ol>')
          doc.sub!('<ol>', '<ol class="legislative-list">')
        end
      end
    end

    extension("numbered list", /^[ \t]*((s\d+\.\s.*(?:\n|$))+)/) do |body|
      steps ||= 0
      body.gsub!(/s(\d+)\.\s(.*)(?:\n|$)/) do |b|
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

    devolved_options.each do |k,v|
      extension("devolved-#{k}",/:#{k}:(.*?):#{k}:/m) do |body|
%{<div class="devolved-content #{k}">
<p class="devolved-header">This section applies to #{v}</p>
<div class="devolved-body">#{Govspeak::Document.new(body.strip).to_html}</div>
</div>\n}
      end
    end

    extension("Priority list", /(?<=\A|\n\n|\r\n\r\n)^\$PriorityList:(\d+)\s*$(.*?)(?:^\s*$|\Z)/m) do |number_to_show, body|
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
      link = links.detect { |l| l[:content_id].match(content_id) }
      next "" unless link
      if link[:url]
        %Q{<a href="#{encode(link[:url])}">#{link[:title]}</a>}
      else
        link[:title]
      end
    end

    def render_hcard_address(contact)
      HCardPresenter.from_contact(contact).render
    end
    private :render_hcard_address

    extension('Contact', /\[Contact:\s*(.*?)\s*\]/) do |content_id|
      contact = contacts.detect { |c| c[:content_id].match(content_id) }
      next "" unless contact
      contact = ContactPresenter.new(contact)
      @renderer ||= ERB.new(File.read(__dir__ + '/templates/contact.html.erb'))
      @renderer.result(binding)
    end
  end
end
