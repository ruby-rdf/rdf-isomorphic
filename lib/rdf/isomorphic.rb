require 'digest/sha1'
require 'rdf'


module RDF
  module Isomorphic

    def isomorphic_with(other)
      named_statements_match = true
      each_statement do |statement|
        unless statement.has_blank_nodes?
          named_statements_match = other.has_statement?(statement)
        end
        break unless named_statements_match
      end
      named_statements_match && !(bijection_to(other).nil?)
    end

    alias_method :isomorphic?, :isomorphic_with
    alias_method :isomorphic_with?, :isomorphic_with

    def bijection_to(other)
      blank_nodes = find_all { |statement| statement.has_blank_nodes? }
      other_blank_nodes = other.find_all { |statement| statement.has_blank_nodes? }
      identifiers = blank_identifiers_in(blank_nodes)
      other_identifiers = blank_identifiers_in(other_blank_nodes)
      build_bijection_to blank_nodes, identifiers, other_blank_nodes, other_identifiers
    end

    protected

    def build_bijection_to(blank_nodes, identifiers, other_blank_nodes, other_identifiers, hashes = {})
      all_identifiers = []
      potential_hashes = {}
      identifiers.each do | identifier | 
        grounded, hash = node_hash_for(identifier,blank_nodes,hashes) unless hashes.member? identifier
        hashes[identifier] = hash if grounded
        potential_hashes[identifier] = hash
      end
      other_identifiers.each do | identifier | 
        grounded, hash = node_hash_for(identifier,other_blank_nodes,hashes) unless hashes.member? identifier
        hashes[identifier] = hash if grounded
        potential_hashes[identifier] = hash
      end
      
      # foreach my identifiers, there exists a hash key from the other list of identifiers with the same hash
      bijection = {}
      bijectable = true
      puts "hashes: #{hashes.inspect}"
      bijection_hashes = hashes.dup
      identifiers.each do | identifier |
        tuple = bijection_hashes.find do |k, v| 
          (v == bijection_hashes[identifier]) && 
          # eql? instead of include? since RDF.rb coincedentally-same-named identifiers will be ==
          other_identifiers.any? do | item | k.eql?(item) end
        end
        puts "tuple for #{identifier}: #{tuple.inspect}"
        next unless tuple
        (bijectable = false ; break) unless tuple
        target = tuple.first
        bijection_hashes.delete target
        bijection[identifier] = target
      end
      puts "bijection: #{bijection.inspect}"

      # This is the return statement
      if (bijection.keys.sort == identifiers.sort) && (bijection.values.sort == other_identifiers.sort)
        puts "that last bijection?  totally awesome and good."
        bijection
      #elsif (hashes.keys.sort == identifiers.sort)
      elsif (identifiers.find_all do | iden | hashes.member? iden end.size) >= identifiers.size - 1
        puts "collected #{identifiers.find_all do | iden | hashes.member? iden end.inspect}"
        puts "cannot reconcile.  false."
        nil
      else
        puts "collected (and ignored) #{identifiers.find_all do | iden | hashes.member? iden end.inspect}"
        bijection = nil
        identifiers.each do | identifier |
          puts "checking for #{identifier} in hashes for recursion (#{!(hashes.member?(identifier)) || hashes[identifier].nil?})"
          # we don't replace grounded identifiers' hashes
          next if hashes.member? identifier 
          puts "not found, here we go"
          hash = Digest::SHA1.hexdigest(identifier.to_s)
          bijectable = other_identifiers.any? do | other_identifier |
            # we don't replace grounded identifiers' hashes
            next if hashes.member? other_identifier
            puts "is it possible? #{potential_hashes[identifier] == potential_hashes[other_identifier]}"
            puts "why? #{potential_hashes[identifier]} must ==  #{potential_hashes[other_identifier]}"
            # don't bother unless its even feasible
            next unless potential_hashes[identifier] == potential_hashes[other_identifier]
            test_hashes = { identifier => hash, other_identifier => hash}
            puts "trying another level of recursion, adding #{test_hashes}"
            result = build_bijection_to(blank_nodes, identifiers, other_blank_nodes, other_identifiers, hashes.merge(test_hashes))
            puts "that worked! we're done after adding #{test_hashes}" if result
            bijection = result
          end
          break if bijection
          puts "that didn't work..."
        end
        bijection
      end
    end

    def blank_identifiers_in(blank_node_list)
      identifiers = []
      blank_node_list.each do | statement |
        identifiers << statement.object if statement.object.anonymous?
        identifiers << statement.subject if statement.subject.anonymous?
      end
      identifiers.uniq
    end
  
    def node_hash_for(identifier,statements,hashes)
      # we use a numeric hash instead of a digest hash because there's no way
      # to canonically order bnodes and thus no way to order the statements
      # that bnodes appear in.  so we hash everything related to it and add
      # those up instead.  
      node_hashes = []
      grounded = true
      statements.each do | statement |
        if (statement.object == identifier) || (statement.subject == identifier)
          puts "adding #{statement.predicate.to_s} to hashes for #{identifier}"
          if statement.subject.anonymous? && (!(statement.subject == identifier))
            if hashes.member? statement.subject
              puts "adding #{statement.subject.to_s} to hashes for #{identifier}"
              node_hashes << (hashes[statement.subject] + statement.predicate.to_s)
            else
              puts "grounded false for #{identifier} on #{statement.subject}"
              grounded = false
            end
          elsif !(statement.subject.anonymous?)
            puts "adding #{statement.subject.to_s} to hashes for #{identifier}"
            node_hashes << (statement.subject.to_s + statement.predicate.to_s)
          end

          if statement.object.anonymous? && (!(statement.object == identifier))
            if hashes.member? statement.object
              puts "adding #{statement.object.to_s} to hashes for #{identifier}"
              node_hashes << (statement.predicate.to_s + hashes[statement.object])
            else
              puts "grounded false for #{identifier} on #{statement.object}"
              grounded = false
            end
          elsif !(statement.object.anonymous?)
            puts "adding #{statement.object.to_s} to hashes for #{identifier}"
            node_hashes << (statement.predicate.to_s + statement.object.to_s)
          end
        end
      end
      puts "node_hash_for #{identifier} returning #{[grounded,Digest::SHA1.hexdigest(node_hashes.sort.to_s)].inspect}"
      [grounded,Digest::SHA1.hexdigest(node_hashes.sort.to_s)]
    end
  end



  module Enumerable 
    include RDF::Isomorphic
  end
end

