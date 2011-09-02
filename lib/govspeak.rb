require 'kramdown'

module Govspeak

  class Document

    @@extensions = []

    def initialize(source,options = {})
      source ||= ""
      options[:entity_output] ||= :symbolic
      @doc = Kramdown::Document.new(preprocess(source), options)
      super
    end

    def to_html
      @doc.to_html
    end

    def preprocess(source)
      @@extensions.each do |title,regexp,block|
        source.gsub!(regexp) {|match|
          block.call($1)
        }
      end
      source
    end

    def self.extension(title, regexp = nil, &block)
      regexp ||= %r${::#{title}}(.*?){:/#{title}}$m
      @@extensions << [title, regexp, block]
    end

    def self.surrounded_by(open, close=nil)
      open = Regexp::escape(open)
      if close
        close = Regexp::escape(close)
        %r+(?:\r|\n|^)#{open}(.*?)#{close}(\r|\n|$)?+m
      else
        %r+(?:\r|\n|^)#{open}(.*?)#{open}?(\r|\n|$)+m
      end
    end

    def self.wrap_with_div(class_name, character, parser=Kramdown::Document)
      extension(class_name, surrounded_by(character)) { |body|
        content = parser ? parser.new("#{body.strip}\n").to_html : body.strip
        "<div class=\"#{class_name}\">\n#{content}</div>\n"
      }
    end

    extension('reverse') { |body|
      body.reverse
    }

    extension('external', surrounded_by("x")) { |body|
      Kramdown::Document.new("#{body.strip}{:rel='external'}").to_html
    }

    extension('informational', surrounded_by("^")) { |body|
      "<div class=\"application-notice info-notice\">
#{Kramdown::Document.new(body.strip).to_html}</div>\n"
    }

    extension('important', surrounded_by("@")) { |body|
      "<h3 class=\"advisory\"><span>#{body.strip}</span></h3>\n"
    }

    extension('helpful', surrounded_by("%")) { |body|
      "<div class=\"application-notice help-notice\">\n<p>#{body.strip}</p>\n</div>\n"
    }

    extension('map_link', surrounded_by("((", "))")) { |body|
      "<div class=\"map\"><iframe width=\"200\" height=\"200\" frameborder=\"0\" scrolling=\"no\" marginheight=\"0\" marginwidth=\"0\" src=\"#{body.strip}&output=embed\"></iframe><br /><small><a href=\"#{body.strip}\">View Larger Map</a></small></div>"
    }

    wrap_with_div('summary', '$!')
    wrap_with_div('form-download', '$D')
    wrap_with_div('contact', '$C')
    wrap_with_div('place', '$P', Govspeak::Document)
    wrap_with_div('information', '$I', Govspeak::Document)
    wrap_with_div('additional-information', '$AI')
    wrap_with_div('example', '$E', Govspeak::Document)

    extension('address', surrounded_by("$A")) { |body|
      "<div class=\"address vcard\"><div class=\"adr org fn\"><p>\n#{body.sub("\n", "").gsub("\n", "<br />")}\n</p></div></div>\n"
    }

    extension("numbered list", /((s\d+\.\s.*(?:\n|$))+)/) do |body|
      steps ||= 0
      body.gsub!(/s(\d+)\.\s(.*)(?:\n|$)/) do |b|
          "<li><p>#{$2.strip}</p></li>\n"
      end
      "<ol class=\"steps\">\n#{body}</ol>"
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
     extension("devolved-#{k}",/:#{k}:(.*?):\/#{k}:/m) do |body|
"<div class=\"devolved-content #{k}\">
<p class=\"devolved-header\">This section applies to #{v}</p>
<div class=\"devolved-body\"><p>#{body.strip}</p>
</div>
</div>\n"
     end
   end
  end
end
