#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-
$:.unshift File.expand_path('../lib', __FILE__)
require 'rdf/isomorphic/version'

GEMSPEC = Gem::Specification.new do |gem|
  gem.version            = RDF::Isomorphic::VERSION.to_s
  gem.date               = Time.now.strftime('%Y-%m-%d')

  gem.name               = 'rdf-isomorphic'
  gem.homepage           = 'http://rdf.rubyforge.org/'
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.description        = 'RDF.rb plugin for graph bijections and isomorphic equivalence.'
  gem.summary            = 'RDF.rb plugin for graph bijections and isomorphic equivalence.'
  gem.rubyforge_project  = 'rdf'

  gem.authors            = ['Ben Lavender','Arto Bendiken']
  gem.email              = 'blavender@gmail.com'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS README UNLICENSE) + Dir.glob('lib/**/*.rb')
  gem.bindir             = %q(bin)
  gem.executables        = %w()
  gem.default_executable = gem.executables.first
  gem.require_paths      = %w(lib)
  gem.extensions         = %w()
  gem.test_files         = %w()
  gem.has_rdoc           = false

  gem.required_ruby_version      = '>= 1.8.2'
  gem.requirements               = []
  gem.add_runtime_dependency     'rdf',      '>= 0.3.4'
  gem.add_development_dependency 'rdf-spec', '>= 0.2.0'
  gem.add_development_dependency 'rspec',    '>= 0.3.4'
  gem.add_development_dependency 'yard' ,    '>= 0.5.3'
  gem.post_install_message       = nil
end
