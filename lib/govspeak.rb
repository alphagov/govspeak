require 'kramdown'

module Govspeak

  class Document

    @@extensions = []

    def initialize(source,options = {})
      source ||= ""
      options[:entity_output] ||= :symbolic
      @doc = Kramdown::Document.new(preprocess(source),options)
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

    extension('reverse') { |body|
      body.reverse
    }

    extension('external', surrounded_by("x")) { |body|
      Kramdown::Document.new("#{body.strip}{:rel='external'}").to_html
    }

    extension('informational', surrounded_by("^")) { |body|
      "<div class=\"application-notice info-notice\">
<p>#{body.strip}</p>
</div>\n"
    }

    extension('important', surrounded_by("@")) { |body|
      "<h3 class=\"advisory\"><span>#{body.strip}</span></h3>\n"
    }

    extension('helpful', surrounded_by("%")) { |body|
      "<div class=\"application-notice help-notice\">\n<p>#{body.strip}</p>\n</div>\n"
    }

    extension('summary', surrounded_by("$!")) { |body|
      "<div class=\"summary\">\n#{Kramdown::Document.new("#{body.strip}\n").to_html}</div>\n"
    }

    extension('form download', surrounded_by("\o/")) { |body|
      "<div class=\"form_download\">\n#{Kramdown::Document.new("#{body.strip}\n").to_html}</div>\n"
    }

    extension("numbered list", /((s\d+\.\s.*(?:\n|$))+)/) do |body|
      steps ||= 0
      body.gsub!(/s(\d+)\.\s(.*)(?:\n|$)/) do |b|
          steps = steps + 1
          "<p class=\"step-label\"><span class=\"step-number\">#{steps}</span><span class=\"step-total\">of [[TOTAL_STEPS]]</span></p>
<p>#{$2.strip}</p>\n"
      end
      body.gsub!("[[TOTAL_STEPS]]", steps.to_s)
      "<div class=\"answer-step\">\n#{body}</div>"
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
