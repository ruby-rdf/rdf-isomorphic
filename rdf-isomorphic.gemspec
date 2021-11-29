#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

GEMSPEC = Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'rdf-isomorphic'
  gem.homepage           = 'https://ruby-rdf.github.com/rdf-isomorphic'
  gem.license            = 'Unlicense'
  gem.description        = 'RDF.rb extension for graph bijections and isomorphic equivalence.'
  gem.summary            = 'RDF Graph/Dataset Isomorphism as defined in RDF 1.1 Concepts.'

  gem.authors            = ['Ben Lavender','Arto Bendiken', 'Gregg Kellogg']
  gem.email              = 'public-rdf-ruby@w3.org'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS README.md UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.require_paths      = %w(lib)

  gem.required_ruby_version      = '>= 2.6'
  gem.requirements               = []
  gem.add_runtime_dependency     'rdf',      '~> 3.2'
  gem.add_development_dependency 'rdf-spec', '~> 3.2'
  gem.add_development_dependency 'rspec',    '~> 3.10'
  gem.add_development_dependency 'yard' ,    '~> 0.9'

  gem.post_install_message       = nil
end
