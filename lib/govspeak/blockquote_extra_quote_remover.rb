module Govspeak
  module BlockquoteExtraQuoteRemover
    QUOTE = '"\u201C\u201D\u201E\u201F\u2033\u2036'
    LINE_BREAK = '\r\n?|\n'

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
      source.gsub(/^>[ \t]*[#{QUOTE}]*([^ \t\n].+?)[#{QUOTE}]*[ \t]*(#{LINE_BREAK}?)$/, '> \1\2')
    end
  end
end
