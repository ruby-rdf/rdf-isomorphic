$:.unshift(File.expand_path("../../lib/", __FILE__))

require "bundler/setup"
require 'rdf'

begin
  require 'simplecov'
  require 'simplecov-lcov'
  require 'coveralls'

  SimpleCov::Formatter::LcovFormatter.config do |config|
    #Coveralls is coverage by default/lcov. Send info results
    config.report_with_single_file = true
    config.single_report_path = 'coverage/lcov.info'
  end

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter
  ])
  SimpleCov.start do
    add_filter "/spec/"
  end
rescue LoadError => e
  STDERR.puts "Coverage Skipped: #{e.message}"
end
