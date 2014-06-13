module Kramdown
  module Parser
    class Kramdown
      # This depends on two internal parts of Kramdown.
      # 1. Parser registry (kramdown/parser/kramdown.rb#define_parser)
      # 2. Kramdown list regexes (kramdown/parser/kramdown/list.rb)
      # Updating the Kramdown gem therefore also means updating this file to to
      # match Kramdown's internals.

      def self.without_parsing_ordered_lists
        redefine_const(:LIST_START, LIST_START_UL)
        list_parser = @@parsers.delete(:list)
        define_parser(:list, LIST_START)

        yield.tap do |output|
          redefine_const(:LIST_START,/#{LIST_START_UL}|#{LIST_START_OL}/)
          @@parsers[:list] = list_parser
        end
      end

    private
      def self.redefine_const(const, value)
        remove_const(const)
        const_set(const, value)
      end
    end
  end
end
