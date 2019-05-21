require "addressable/uri"
require "kramdown/options"

module Kramdown
  module Options
    class AlwaysEqual
      def ==(_other)
        true
      end
    end

    define(:document_domains, Object, %w{www.gov.uk}, <<~DESCRIPTION) do |val|
      Defines the domains which are considered local to the document

      Default: www.gov.uk
      Used by: KramdownWithAutomaticExternalLinks
    DESCRIPTION
      simple_array_validator(val, :document_domains, AlwaysEqual.new)
    end
  end

  module Parser
    class Govuk < Kramdown::Parser::Kramdown
      def initialize(source, options)
        @document_domains = options[:document_domains] || %w(www.gov.uk)
        super
      end

      def add_link(element, href, title, alt_text = nil, ial = nil)
        if element.type == :a
          begin
            host = Addressable::URI.parse(href).host
            unless host.nil? || @document_domains.compact.include?(host)
              element.attr['rel'] = 'external'
            end
          # rubocop:disable Lint/HandleExceptions
          rescue Addressable::URI::InvalidURIError
            # it's safe to ignore these very *specific* exceptions
          end
          # rubocop:enable Lint/HandleExceptions
        end
        super
      end
    end
  end
end
