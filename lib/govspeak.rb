require 'kramdown'

module Govspeak
  
  class Document 
    
    @@extensions = []
    
    def initialize(source,options = {})
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
    
    def self.extension(title,regexp = nil, &block)
      regexp ||= %r${::#{title}}(.*?){:/#{title}}$m
      @@extensions << [title,regexp,block]
    end
    
    def self.surrounded_by(open,close=nil)
      open = Regexp::escape(open)
      if close
        close = Regexp::escape(close)
        %r+#{open}(.*?)#{close}(\n|$)?+m
      else
        %r+#{open}(.*?)#{open}?(\n|$)+m
      end
    end
    
    extension('reverse') { |body|
      body.reverse
    }
    
    extension('informational',surrounded_by("^")) { |body|
      "<div class=\"application-notice info-notice\">
<p>#{body.strip}</p>
</div>"
    }
    
    extension('important',surrounded_by("@")) { |body|
      "<h3 class=\"advisory\"><span>#{body.strip}</span></h3>"
    }
    
    extension('helpful',surrounded_by("%")) { |body|
      "<div class=\"application-notice help-notice\">\n<p>#{body.strip}</p>\n</div>"
    }
    
    extension('glossary',surrounded_by("[","]")) { |body|
      "<em class=\"glossary\" title=\"See glossary\">#{body.strip}</em>"
    }
    
  end

  
  
end

