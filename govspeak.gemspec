# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name          = "govspeak"
  s.version       = "0.8.8"
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
    'Gemfile',
    'Rakefile'
  ]
  s.test_files    = Dir['test/**/*']
  s.require_paths = ["lib"]

  s.add_dependency 'kramdown', '~> 0.13.3'
  s.add_dependency 'htmlentities', '~> 4'
  
  s.add_development_dependency 'rake', '~> 0.9.0'
  
end
