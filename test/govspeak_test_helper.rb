module GovspeakTestHelper
  def self.included(base)
    base.extend(ClassMethods)
  end

  class GovspeakAsserter
    def initialize(testcase, govspeak, options = {})
      @testcase = testcase
      @govspeak = remove_indentation(govspeak)
      @options = options
    end

    def document
      Govspeak::Document.new(@govspeak, @options)
    end

    def assert_text_output(raw_expected)
      expected = remove_indentation(raw_expected)
      actual = document.to_text
      @testcase.assert expected == actual, describe_error(@govspeak, expected, actual)
    end

    def assert_html_output(raw_expected)
      expected = remove_indentation(raw_expected)
      actual = document.to_html.strip
      @testcase.assert expected.strip == actual, describe_error(@govspeak, expected.strip, actual)
    end

    def remove_indentation(raw)
      lines = raw.split("\n")
      if lines.first.empty?
        lines.delete_at(0)
        nonblanks = lines.reject { |l| l.match(/^ *$/) }
        indentation = nonblanks.map { |line| line.match(/^ */)[0].size }.min
        unindented = lines.map do |line|
          line[indentation..-1]
        end
        unindented.join "\n"
      else
        raw
      end
    end

    def describe_error(govspeak, expected, actual)
      "Expected:\n#{govspeak}\n\nto produce:\n#{show_linenumbers(expected)}\n\nbut got:\n#{show_linenumbers(actual)}\n"
    end

    def show_linenumbers(text)
      lines = text.split "\n"
      digits = Math.log10(lines.size + 2).ceil
      lines.map
        .with_index { |line, i| "%<number>#{digits}d: %<line>s" % { number: i + 1, line: line } }
        .join("\n")
    end
  end

  def given_govspeak(govspeak, options = {}, &block)
    asserter = GovspeakAsserter.new(self, govspeak, options)
    asserter.instance_eval(&block)
  end

  def deobfuscate_mailto(html)
    # Kramdown obfuscates mailto addresses as an anti-spam measure. It
    # obfuscates by encoding them as HTML entities.
    # https://github.com/gettalong/kramdown/blob/7a7bd675b9d2593ad40c26fc4c77bf8407b70b42/lib/kramdown/converter/html.rb#L237-L246
    coder = HTMLEntities.new
    coder.decode(html)
  end

  module ClassMethods
    def test_given_govspeak(govspeak, options = {}, &block)
      test "Given #{govspeak}" do
        given_govspeak(govspeak, options, &block)
      end
    end
  end
end
