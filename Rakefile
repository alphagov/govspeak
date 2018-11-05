require "rake"
require "rake/testtask"
require "bundler"

Bundler::GemHelper.install_tasks

desc "Run basic tests"
Rake::TestTask.new("test") { |t|
  t.libs << "test"
  t.pattern = 'test/*_test.rb'
  t.verbose = true
  t.warning = true
}

task default: [:test]
