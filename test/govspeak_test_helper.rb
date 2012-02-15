module GovspeakTestHelper

  def self.included(base)
    base.extend(ClassMethods)
  end
    
  class GovspeakAsserter
    def initialize(testcase, govspeak)
      @testcase = testcase
      @govspeak = remove_indentation(govspeak)
    end
    
    def document
      Govspeak::Document.new(@govspeak)
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
        indentation = nonblanks.map do |line|
          line.match(/^ */)[0].size
        end.min
        unindented = lines.map do |line|
          line[indentation..-1]
        end
        unindented.join "\n"
      else
        raw
      end
    end
    
    def describe_error(govspeak, expected, actual)
      "Expected:\n#{govspeak}\n\nto produce:\n#{expected}\n\nbut got:\n#{actual}\n"
    end
  end

  def given_govspeak(govspeak, &block)
    asserter = GovspeakAsserter.new(self, govspeak)
    asserter.instance_eval(&block)
  end
  
  module ClassMethods
    def test_given_govspeak(govspeak, &block)
      test "Given #{govspeak}" do
        given_govspeak(govspeak, &block)
      end
    end
  end
end