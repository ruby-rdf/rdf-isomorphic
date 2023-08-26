#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

GEMSPEC = Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'rdf-isomorphic'
  gem.homepage           = 'https://github.com/ruby-rdf/rdf-isomorphic'
  gem.license            = 'Unlicense'
  gem.description        = 'RDF.rb extension for graph bijections and isomorphic equivalence.'
  gem.summary            = 'RDF Graph/Dataset Isomorphism as defined in RDF 1.1 Concepts.'
  gem.metadata           = {
    "documentation_uri" => "https://ruby-rdf.github.io/rdf-isomorphic",
    "bug_tracker_uri"   => "https://github.com/ruby-rdf/rdf-isomorphic/issues",
    "homepage_uri"      => "https://github.com/ruby-rdf/rdf-isomorphic",
    "mailing_list_uri"  => "https://lists.w3.org/Archives/Public/public-rdf-ruby/",
    "source_code_uri"   => "https://github.com/ruby-rdf/rdf-isomorphic",
  }

  gem.authors            = ['Ben Lavender','Arto Bendiken', 'Gregg Kellogg']
  gem.email              = 'public-rdf-ruby@w3.org'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS README.md UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.require_paths      = %w(lib)

  gem.required_ruby_version      = '>= 3.0'
  gem.requirements               = []
  gem.add_runtime_dependency     'rdf',      '~> 3.3'
  gem.add_development_dependency 'rdf-spec', '~> 3.2'
  gem.add_development_dependency 'rspec',    '~> 3.12'
  gem.add_development_dependency 'yard' ,    '~> 0.9'

  gem.post_install_message       = nil
end
