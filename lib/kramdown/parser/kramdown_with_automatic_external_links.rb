require "uri"

module Kramdown
  module Parser
    class KramdownWithAutomaticExternalLinks < Kramdown::Parser::Kramdown
      class << self
        attr_writer :document_domains
        def document_domains
          @document_domains || %w(www.gov.uk)
        end
      end

      def add_link(el, href, title, alt_text = nil)
        begin
          host = URI.parse(href).host
          unless host.nil? || (self.class.document_domains.compact.include?(host))
            el.attr['rel'] = 'external'
          end
        rescue URI::InvalidURIError, URI::InvalidComponentError
          # it's safe to ignore these very *specific* exceptions
        end
        super
      end
    end
  end
end

