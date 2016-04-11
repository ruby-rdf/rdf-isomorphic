#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

GEMSPEC = Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'rdf-isomorphic'
  gem.homepage           = 'http://ruby-rdf.github.com/rdf-isomorphic'
  gem.license            = 'Unlicense'
  gem.description        = 'RDF.rb extension for graph bijections and isomorphic equivalence.'
  gem.summary            = 'RDF Graph/Dataset Isomorphism as defined in RDF 1.1 Concepts.'
  gem.rubyforge_project  = 'rdf'

  gem.authors            = ['Ben Lavender','Arto Bendiken']
  gem.email              = 'public-rdf-ruby@w3.org'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS README.md UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.bindir             = %q(bin)
  gem.executables        = %w()
  gem.default_executable = gem.executables.first
  gem.require_paths      = %w(lib)
  gem.extensions         = %w()
  gem.test_files         = %w()
  gem.has_rdoc           = false

  gem.required_ruby_version      = '>= 2.0'
  gem.requirements               = []
  gem.add_runtime_dependency     'rdf',      '~> 2.0'
  gem.add_development_dependency 'rdf-spec', '~> 2.0'
  gem.add_development_dependency 'rspec',    '~> 3.0'
  gem.add_development_dependency 'yard' ,    '~> 0.8.7'

  gem.post_install_message       = nil
end
