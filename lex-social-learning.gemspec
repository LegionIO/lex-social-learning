# frozen_string_literal: true

require_relative 'lib/legion/extensions/social_learning/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-social-learning'
  spec.version       = Legion::Extensions::SocialLearning::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Social Learning'
  spec.description   = "Bandura's Social Cognitive Theory for LegionIO: vicarious learning via model observation and reproduction"
  spec.homepage      = 'https://github.com/LegionIO/lex-social-learning'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-social-learning'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-social-learning'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-social-learning'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-social-learning/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{lib,spec}/**/*') + %w[lex-social-learning.gemspec Gemfile]
  end
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end
