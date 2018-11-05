module Govspeak
  module KramdownOverrides
    # This depends on two internal parts of Kramdown.
    # 1. Parser registry (kramdown/parser/kramdown.rb#define_parser)
    # 2. Kramdown list regexes (kramdown/parser/kramdown/list.rb)
    # Updating the Kramdown gem therefore also means updating this file to to
    # match Kramdown's internals.

    def self.with_kramdown_ordered_lists_disabled
      original_list_start = list_start
      redefine_kramdown_const(:LIST_START, list_start_ul)
      list_parser = kramdown_parsers.delete(:list)
      Kramdown::Parser::Kramdown.define_parser(:list, list_start_ul)

      yield
    ensure
      redefine_kramdown_const(:LIST_START, original_list_start)
      kramdown_parsers[:list] = list_parser
    end

    def self.list_start
      Kramdown::Parser::Kramdown::LIST_START
    end

    def self.list_start_ul
      Kramdown::Parser::Kramdown::LIST_START_UL
    end

    def self.kramdown_parsers
      Kramdown::Parser::Kramdown.class_variable_get("@@parsers")
    end

    def self.redefine_kramdown_const(const, value)
      Kramdown::Parser::Kramdown.send(:remove_const, const)
      Kramdown::Parser::Kramdown.send(:const_set, const, value)
    end
  end
end
