require 'kramdown'
require 'govspeak/header_extractor'
require 'htmlentities'

module Govspeak

  class Document

    @@extensions = []

    attr_accessor :images

    def self.to_html(source, options = {})
      new(source, options).to_html
    end

    def initialize(source, options = {})
      @source = source ? source.dup : ""
      @options = options.merge(entity_output: :symbolic)
      @images = []
      super()
    end

    def kramdown_doc
      @kramdown_doc ||= Kramdown::Document.new(preprocess(@source), @options)
    end
    private :kramdown_doc

    def to_html
      kramdown_doc.to_html
    end

    def to_text
      HTMLEntities.new.decode(to_html.gsub(/(?:<[^>]+>|\s)+/, " ").strip)
    end

    def headers
      Govspeak::HeaderExtractor.convert(kramdown_doc).first
    end

    def preprocess(source)
      @@extensions.each do |title,regexp,block|
        source.gsub!(regexp) {|match|
          instance_exec($1, &block)
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
        %{<div class="#{class_name}">\n#{content}</div>\n}
      }
    end

    def insert_strong_inside_p(body, parser=Kramdown::Document)
      parser.new(body.strip).to_html.sub(/^<p>(.*)<\/p>$/,"<p><strong>\\1</strong></p>")
    end

    extension('reverse') { |body|
      body.reverse
    }

    extension('highlight-answer') { |body|
      %{\n\n<div class="highlight-answer">
#{Kramdown::Document.new(body.strip).to_html}</div>\n}
    }

    # FIXME: these surrounded_by arguments look dodgy
    extension('external', surrounded_by("x[", ")x")) { |body|
      Kramdown::Document.new("[#{body.strip}){:rel='external'}").to_html
    }

    extension('informational', surrounded_by("^")) { |body|
      %{\n\n<div class="application-notice info-notice">
#{Kramdown::Document.new(body.strip).to_html}</div>\n}
    }

    extension('important', surrounded_by("@")) { |body|
      %{\n\n<div class="advisory">#{insert_strong_inside_p(body)}</div>\n}
    }

    extension('helpful', surrounded_by("%")) { |body|
      %{\n\n<div class="application-notice help-notice">\n#{Kramdown::Document.new(body.strip).to_html}</div>\n}
    }

    extension('map_link', surrounded_by("((", "))")) { |body|
      %{<div class="map"><iframe width="200" height="200" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="#{body.strip}&output=embed"></iframe><br /><small><a href="#{body.strip}">View Larger Map</a></small></div>}
    }

    extension('attached-image', /^!!([0-9]+)/) do |image_number|
      image = images[image_number.to_i - 1]
      if image
        caption = image.caption rescue nil
        render_image(image.url, image.alt_text, caption)
      else
        ""
      end
    end

    def render_image(url, alt_text, caption = nil)
      lines = []
      lines << '<figure class="image embedded">'
      lines << %Q{  <div class="img"><img alt="#{encode(alt_text)}" src="#{encode(url)}" /></div>}
      lines << %Q{  <figcaption>#{encode(caption.strip)}</figcaption>} if caption && !caption.strip.empty?
      lines << '</figure>'
      lines.join "\n"
    end

    wrap_with_div('summary', '$!')
    wrap_with_div('form-download', '$D')
    wrap_with_div('contact', '$C')
    wrap_with_div('place', '$P', Govspeak::Document)
    wrap_with_div('information', '$I', Govspeak::Document)
    wrap_with_div('additional-information', '$AI')
    wrap_with_div('example', '$E', Govspeak::Document)

    extension('address', surrounded_by("$A")) { |body|
      %{<div class="address vcard"><div class="adr org fn"><p>\n#{body.sub("\n", "").gsub("\n", "<br />")}\n</p></div></div>\n}
    }

    extension("numbered list", /((s\d+\.\s.*(?:\n|$))+)/) do |body|
      steps ||= 0
      body.gsub!(/s(\d+)\.\s(.*)(?:\n|$)/) do |b|
          "<li>#{Kramdown::Document.new($2.strip).to_html}</li>\n"
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
<div class="devolved-body">#{Kramdown::Document.new(body.strip).to_html}</div>
</div>\n}
      end
    end
  end
end
