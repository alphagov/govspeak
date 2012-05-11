require 'rake'
require 'rake/testtask'
require 'bundler'

Bundler::GemHelper.install_tasks

task :default => [:test_units]
task :test => [:test_units]

desc "Run basic tests"
Rake::TestTask.new("test_units") { |t|
  t.libs << "test"
  t.pattern = 'test/*_test.rb'
  t.verbose = true
  t.warning = true
}

require "gem_publisher"
task :publish_gem do |t|
  gem = GemPublisher.publish_if_updated("govspeak.gemspec", :rubygems)
  puts "Published #{gem}" if gem
end
