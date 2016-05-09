require "addressable/uri"
require "kramdown/options"

module Kramdown
  module Options
    class AlwaysEqual
      def ==(other)
        true
      end
    end

    define(:document_domains, Object, %w{www.gov.uk}, <<EOF) do |val|
Defines the domains which are considered local to the document

Default: www.gov.uk
Used by: KramdownWithAutomaticExternalLinks
EOF
      simple_array_validator(val, :document_domains, AlwaysEqual.new)
    end
  end

  module Parser
    class KramdownWithAutomaticExternalLinks < Kramdown::Parser::Kramdown
      def initialize(source, options)
        @document_domains = options[:document_domains] || %w(www.gov.uk)
        super
      end

      def add_link(el, href, title, alt_text = nil, ial = nil)
        if el.type == :a
          begin
            host = Addressable::URI.parse(href).host
            unless host.nil? || (@document_domains.compact.include?(host))
              el.attr['rel'] = 'external'
            end
          rescue Addressable::URI::InvalidURIError
            # it's safe to ignore these very *specific* exceptions
          end
        end
        super
      end
    end
  end
end
