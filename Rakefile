require "rake"
require "rake/testtask"
require "rubocop/rake_task"
require "bundler"

Bundler::GemHelper.install_tasks

RuboCop::RakeTask.new

desc "Run basic tests"
Rake::TestTask.new("test") do |t|
  t.libs << "test"
  t.pattern = "test/*_test.rb"
  t.verbose = true
  t.warning = true
end

task default: %i[test rubocop]
