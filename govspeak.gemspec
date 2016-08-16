# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require 'govspeak/version'

Gem::Specification.new do |s|
  s.name          = "govspeak"
  s.version       = Govspeak::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Ben Griffiths", "James Stewart"]
  s.email         = ["ben@alphagov.co.uk", "james.stewart@digital.cabinet-office.gov.uk"]
  s.homepage      = "http://github.com/alphagov/govspeak"
  s.summary       = %q{Markup language for single domain}
  s.description   = %q{A set of extensions to markdown layered on top of the kramdown
library for use in the UK Government Single Domain project}

  s.files         = Dir[
    'lib/**/*',
    'README.md',
    'CHANGELOG.md',
    'Gemfile',
    'Rakefile'
  ]
  s.test_files    = Dir['test/**/*']
  s.require_paths = ["lib"]

  s.add_dependency 'kramdown', '~> 1.10.0'
  s.add_dependency 'htmlentities', '~> 4'
  s.add_dependency "sanitize", "~> 2.1.0"
  s.add_dependency 'nokogiri', '~> 1.5'
  s.add_dependency 'addressable', '>= 2.3.8', '< 3'
  s.add_dependency 'actionview', '~> 4.1'
  s.add_dependency 'i18n', '~> 0.7'
  s.add_dependency 'money', '~> 6.7'

  s.add_development_dependency 'rake', '~> 0.9.0'
  s.add_development_dependency 'gem_publisher', '~> 1.1.1'
  s.add_development_dependency 'minitest', '~> 5.8.3'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'simplecov-rcov'
end
