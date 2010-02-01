# RDF Isomorphism

Provides RDF Isomorphism functionality for RDF.rb RDF::Enumerables.  That
includes RDF::Repository, RDF::Graph, query results, and more.

## Synopsis:

    require 'rdf/isomorphic'
    require 'rdf/ntriples'
    a = RDF::Repository.load './tests/isomorphic/test1/test1-1.nt'
    a.first
    => < RDF::Statement:0xd344c4(<http://example.org/a> <http://example.org/prop> <_:abc> .) >
    
    b = RDF::Repository.load './tests/isomorphic/test1/test1-2.nt'
    b.first
    => < RDF::Statement:0xd3801a(<http://example.org/a> <http://example.org/prop> <_:testing> .) >

    a.isomorphic_with? b
    => true
    a.bijection_to b
    => { #<RDF::Node:0xd345a0(_:abc)>=>#<RDF::Node:0xd38574(_:testing)> }

## Algorithm

More discussion on the algorithm used will be in a forthcoming blog post, but
it is very, very similar to the one described by Jeremy Carroll in
<http://www.hpl.hp.com/techreports/2001/HPL-2001-293.pdf>.

Generally speaking, the Carroll algorithm is a very good fit for RDF graphs. It
is a specialization of the naive factorial-time test for graph isomorphism,
wherin non-anonymous RDF data lets us eliminate vast quantities of options well
before we try them.  Pathological cases, such as graphs which only contain
anonymous resources, will experience poor performance.

### Equality

Although it was considered to provide `==` to mean isomorphic, RDF isomorphism is a
factorial-complexity problem and it seemed better to perhaps not overwrite such
a commonly used method for that.  But it's really useful for specs in RDF
libraries.  Try this:

    require 'rdf/isomorphic'
    module RDF
      module Isomorphic
        alias_method :==, :isomorphic_with
      end
    end
    
    describe 'something' do
      context 'does' do
        it 'should be equal' do
          repository_a.should == repository_b
        end
      end
    end

### Information
 * Author: Ben Lavender <blavender@gmail.com>
 * Source: http://github.com/bhuga/RDF-Isomorphic
 * Issues: http://github.com/bhuga/RDF-Isomorphic/issues

### "License"

rdf-isomorphic is free and unemcumbered software in the public domain.  For more information, see the accompanying UNLICENSE file or <http://unlicense.org>
