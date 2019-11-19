require "simplecov"
require "simplecov-rcov"

SimpleCov.start
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter

$:.unshift(File.expand_path("../lib")) unless $:.include?(File.expand_path("../lib"))

require "bundler"
Bundler.setup :default, :development, :test

require "minitest/autorun"

class Minitest::Test
  class << self
    def test(name, &block)
      clean_name = name.gsub(/\s+/, "_")
      method = "test_#{clean_name.gsub(/\s+/, '_')}".to_sym
      already_defined = instance_method(method) rescue false
      raise "#{method} exists" if already_defined

      define_method(method, &block)
    end
  end
end

require "govspeak"
