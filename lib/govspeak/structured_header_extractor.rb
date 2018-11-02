module Govspeak
  StructuredHeader = Struct.new(:text, :level, :id, :headers) do
    def top_level
      2
    end

    def top_level?
      level == top_level
    end

    def to_h
      Hash[members.zip(values)].merge(
        headers: headers.map(&:to_h),
      )
    end
  end

  class StructuredHeaderExtractor
    def initialize(document)
      @doc = document
      @structured_headers = []
      reset_stack
    end

    def call
      headers_list.each do |header|
        next if header_higher_than_top_level?(header)

        if header.top_level?
          add_top_level(header)
        elsif header_at_same_level_as_prev?(header)
          add_sibling(header)
        elsif header_one_level_lower_than_prev?(header)
          add_child(header)
        elsif header_at_higher_level_than_prev?(header)
          add_uncle_or_aunt(header)
        else
          next # ignore semantically invalid headers
        end

        stack.push(header)
      end

      structured_headers
    end

    attr_reader :doc, :stack, :structured_headers
    private :doc, :stack, :structured_headers

    def headers_list
      @headers_list ||= doc.headers.map { |h|
        StructuredHeader.new(h.text, h.level, h.id, [])
      }
    end

    def add_top_level(header)
      structured_headers.push(header)
      reset_stack
    end

    def add_sibling(header)
      stack.pop
      stack.last.headers << header
    end

    def add_child(header)
      stack.last.headers << header
    end

    def add_uncle_or_aunt(header)
      pop_stack_to_level(header)
      stack.last.headers << header
    end

    def header_higher_than_top_level?(header)
      header.level < header.top_level
    end

    def header_at_same_level_as_prev?(header)
      stack.last && stack.last.level == header.level
    end

    def header_one_level_lower_than_prev?(header)
      # lower level means level integer is higher
      stack.last && (stack.last.level - header.level == -1)
    end

    def header_at_higher_level_than_prev?(header)
      # higher level means level integer is lower
      stack.last && (stack.last.level > header.level)
    end

    def pop_stack_to_level(header)
      times_to_pop = stack.last.level - header.level + 1
      times_to_pop.times { stack.pop }
    end

    def reset_stack
      @stack = []
    end
  end
end
