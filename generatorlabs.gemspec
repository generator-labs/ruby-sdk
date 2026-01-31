# frozen_string_literal: true

require_relative 'lib/generatorlabs/version'

Gem::Specification.new do |spec|
  spec.name          = 'generatorlabs'
  spec.version       = GeneratorLabs::VERSION
  spec.authors       = ['Generator Labs, Inc.']
  spec.email         = ['support@generatorlabs.com']

  spec.summary       = 'Official Ruby SDK for the Generator Labs API'
  spec.description   = 'A Ruby wrapper for the Generator Labs API v4.0, ' \
                       'providing RBL monitoring, contact management, and more'
  spec.homepage      = 'https://generatorlabs.com'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/generator-labs/ruby-sdk'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/generator-labs/ruby-sdk/issues'
  spec.metadata['documentation_uri'] = 'https://docs.generatorlabs.com/api/v4/'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*', 'LICENSE', 'README.md']
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 2.7'
  spec.add_dependency 'faraday-retry', '~> 2.2'
end
