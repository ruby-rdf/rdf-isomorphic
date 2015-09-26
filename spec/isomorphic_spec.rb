require File.join(File.dirname(__FILE__), 'spec_helper.rb')
require 'rdf/isomorphic'
require 'rdf/ntriples'
require 'rdf/nquads'

tests = {}
[:isomorphic, :non_isomorphic].each do |type|
  tests[type] = {}
  testdirs = Dir.glob(File.join(File.dirname(__FILE__), 'tests', type.to_s, '*'))
  testdirs.each do |dir|
    testfiles = Dir.glob(File.join(dir, '*'))
    tests[type][File.basename(dir)] = testfiles
  end
end

describe RDF::Isomorphic do

  it "should extend RDF::Enumerable" do
    repo = RDF::Repository.new
    expect(repo).to be_a RDF::Enumerable
    expect(repo).to be_a RDF::Isomorphic
  end

  context "when comparing isomorphic enumerables" do
    tests[:isomorphic].keys.each do | test_number |
      it "should find all enumerables associated with #{test_number} isomorphic" do
        first, second = tests[:isomorphic][test_number].map {|t| RDF::Repository.load(t)}
        expect(first).to be_isomorphic_with second
      end
    end
  end

  context "when comparing non-isomorphic enumerables" do
    tests[:non_isomorphic].keys.each do | test_number |
      it "should find enumerables from #{test_number} non-isomorphic" do
        first, second = tests[:non_isomorphic][test_number].map {|t| RDF::Repository.load(t)}
        expect(first).not_to be_isomorphic_with second
      end
    end
  end
end

describe RDF::Enumerable::Enumerator do
  it "includes behavior from RDF::Isomorphic" do
    expect(RDF::Enumerable::Enumerator < RDF::Isomorphic).to be_truthy
  end
end
