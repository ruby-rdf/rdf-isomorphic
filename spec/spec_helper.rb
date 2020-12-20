$:.unshift(File.expand_path("../../lib/", __FILE__))

require "bundler/setup"
require 'rdf'

begin
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ])
  SimpleCov.start do
    add_filter "/spec/"
  end
  Coveralls.wear!
rescue LoadError => e
  STDERR.puts "Coverage Skipped: #{e.message}"
end
