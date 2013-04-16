#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

GEMSPEC = Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'rdf-isomorphic'
  gem.homepage           = 'http://ruby-rdf.github.com/rdf-isomorphic'
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.description        = 'RDF.rb plugin for graph bijections and isomorphic equivalence.'
  gem.summary            = 'RDF.rb plugin for graph bijections and isomorphic equivalence.'
  gem.rubyforge_project  = 'rdf'

  gem.authors            = ['Ben Lavender','Arto Bendiken']
  gem.email              = 'public-rdf-ruby@w3.org'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS README UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.bindir             = %q(bin)
  gem.executables        = %w()
  gem.default_executable = gem.executables.first
  gem.require_paths      = %w(lib)
  gem.extensions         = %w()
  gem.test_files         = %w()
  gem.has_rdoc           = false

  gem.required_ruby_version      = '>= 1.8.2'
  gem.requirements               = []
  gem.add_runtime_dependency     'rdf',      '>= 1.0'
  gem.add_development_dependency 'rdf-spec', '>= 1.0'
  gem.add_development_dependency 'rspec',    '>= 2.12.0'
  gem.add_development_dependency 'yard' ,    '>= 0.8.3'
  gem.post_install_message       = nil
end
