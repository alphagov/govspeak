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
      @@extensions.each do |title,block|
        regexp = %r${::#{title}}(.*?){:/#{title}}$m
        source.gsub!(regexp) {|match|
          block.call($1)
        }
      end
      source
    end
    
    def self.extension(title,&block)
      @@extensions << [title,block]
    end
    
    extension('reverse') { |body|
      body.reverse
    }
    
  end
  
  
  
end

