require File.join(File.dirname(__FILE__), 'spec_helper.rb')
require 'rdf/isomorphic'
require 'rdf/ntriples'

tests = {}
[:isomorphic, :non_isomorphic].each do |type|
  tests[type] = {}
  testdirs = Dir.glob(File.join(File.dirname(__FILE__), 'tests',type.to_s,'*'))
  testdirs.each do |dir|
    testfiles = Dir.glob(File.join(dir, '*.nt'))
    tests[type][File.basename(dir)] = testfiles
  end
end

describe RDF::Isomorphic do

  it "should extend RDF::Enumerable" do
    repo = RDF::Repository.new
    repo.should be_a RDF::Enumerable
    repo.should be_a RDF::Isomorphic
  end

  context "when comparing isomorphic graphs" do
    tests[:isomorphic].keys.each do | test_number |
      it "should find all graphs associated with #{test_number} isomorphic" do
        first = RDF::Repository.load(tests[:isomorphic][test_number].first)
        second = RDF::Repository.load(tests[:isomorphic][test_number][1])
        first.should be_isomorphic_with second
      end
    end
  end

  context "when comparing non-isomorphic graphs" do
    tests[:non_isomorphic].keys.each do | test_number |
      it "should find graphs from #{test_number} non-isomorphic" do
        first = RDF::Repository.load(tests[:non_isomorphic][test_number].first)
        second = RDF::Repository.load(tests[:non_isomorphic][test_number][1])
        first.should_not be_isomorphic_with second
      end
    end
  end


end
