module Govspeak
  module BlockquoteExtraQuoteRemover
    QUOTES = '["\u201C\u201D\u201E\u201F\u2033\u2036]+'.freeze
    WHITESPACE = '[^\S\r\n]*'.freeze

    # used to remove quotes from a markdown blockquote, as these will be inserted
    # as part of the rendering
    #
    # for example:
    # > "test"
    #
    # will be formatted to:
    # > test
    def self.remove(source)
      return if source.nil?

      source.gsub(/^>#{WHITESPACE}#{QUOTES}#{WHITESPACE}(.+?)$/, '> \1') # prefixed with a quote
            .gsub(/^>(.+?)#{WHITESPACE}#{QUOTES}#{WHITESPACE}(\r?)$/, '>\1\2') # suffixed with a quote
    end
  end
end
