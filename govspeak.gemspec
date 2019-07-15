# -*- encoding: utf-8 -*-

$:.push File.expand_path('lib', __dir__)

require 'govspeak/version'

Gem::Specification.new do |s|
  s.name          = "govspeak"
  s.version       = Govspeak::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["GOV.UK Dev"]
  s.email         = ["govuk-dev@digital.cabinet-office.gov.uk"]
  s.homepage      = "http://github.com/alphagov/govspeak"
  s.summary       = 'Markup language for single domain'
  s.description   = 'A set of extensions to markdown layered on top of the kramdown
library for use in the UK Government Single Domain project'

  s.files         = Dir[
    'lib/**/*',
    'assets/*',
    'config/*',
    'locales/*',
    'README.md',
    'CHANGELOG.md',
    'Gemfile',
    'Rakefile'
  ]
  s.test_files    = Dir['test/**/*']
  s.bindir        = "bin"
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = %w[lib]

  s.add_dependency 'actionview', '~> 5.0'
  s.add_dependency 'addressable', '>= 2.3.8', '< 3'
  s.add_dependency 'govuk_publishing_components', '>= 16.16'
  s.add_dependency 'htmlentities', '~> 4'
  s.add_dependency 'i18n', '~> 0.7'
  s.add_dependency 'kramdown', '~> 1.15.0'
  s.add_dependency 'nokogiri', '~> 1.5'
  s.add_dependency 'rinku', '~> 2.0'
  s.add_dependency "sanitize", "~> 5"

  s.add_development_dependency 'govuk-lint', '~> 3.11.5'
  s.add_development_dependency 'minitest', '~> 5.8.3'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'rake', '~> 0.9.0'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'simplecov-rcov'
end
