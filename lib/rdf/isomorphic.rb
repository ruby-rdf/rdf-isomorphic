require 'digest/sha1'
require 'rdf'


module RDF
  ##
  # Isomorphism for rdf.rb Enumerables
  #
  # RDF::Isomorphic provides the functions isomorphic_with and bijection_to for RDF::Enumerable.
  #
  # @see http://rdf.rubyforge.org
  # @see http://www.hpl.hp.com/techreports/2001/HPL-2001-293.pdf
  module Isomorphic

    # Returns `true` if this RDF::Enumerable is isomorphic with another.
    # @return [Boolean]
    # @example
    #     repository_a.isomorphic_with repository_b #=> true
    def isomorphic_with(other)
      !(bijection_to(other).nil?)
    end

    alias_method :isomorphic?, :isomorphic_with
    alias_method :isomorphic_with?, :isomorphic_with


    # Returns a hash of RDF::Nodes => RDF::Nodes representing an isomorphic
    # bijection of this RDF::Enumerable's blank nodes, or nil if a bijection
    # cannot be found.
    # @example
    #     repository_a.bijection_to repository_b
    # @param other [RDF::Enumerable]
    # @return [Hash, nil]
    def bijection_to(other)
      named_statements_match = true
      each_statement do |statement|
        unless statement.has_blank_nodes?
          named_statements_match = other.has_statement?(statement)
        end
        break unless named_statements_match
      end

      unless named_statements_match
        nil
      else
        blank_nodes = find_all { |statement| statement.has_blank_nodes? }
        other_blank_nodes = other.find_all { |statement| statement.has_blank_nodes? }
        identifiers = blank_identifiers_in(blank_nodes)
        other_identifiers = blank_identifiers_in(other_blank_nodes)
        build_bijection_to blank_nodes, identifiers, other_blank_nodes, other_identifiers
      end
    end

    protected

    def build_bijection_to(anon_stmts, nodes, other_anon_stmts, other_nodes, hashes = {})

      # Some variable descriptions:
      # anon_stmts, other_anon_stmts:  All statements from this and other with anonymous nodes
      # nodes, other_nodes: All anonymous nodes from this and other
      # hashes: hashes of signature of an anonymous nodes' relevant statements.  Only contains hashes for grounded nodes.
      # potential_hashes: as hashes, but not limited to grounded nodes
      # bijection: node => node mapping representing an anonymous node bijection
      # bijection_hashes: duplicate of hashes from which we remove hashes to make sure bijection is one to one
     
      # A grounded node, the difference between the contents of
      # potential_hashes and hashes, is a node which has no ungrounded
      # anonymous neighbors in a relevant statement.
      #
      potential_hashes = {}
      [ [anon_stmts,nodes], [other_anon_stmts,other_nodes] ].each do | tuple |
        hash_needed = true
        while hash_needed 
          hash_needed = false
          tuple.last.each do | node |
            unless hashes.member? node
              grounded, hash = node_hash_for(node, tuple.first, hashes) unless hashes.member? node
              if grounded
                hash_needed = true
                hashes[node] = hash
              end
              potential_hashes[node] = hash
            end
          end
        end
      end

      # see variables above
      bijection = {}
      bijection_hashes = hashes.dup

      # We are looking for nodes such that
      # hashes[node] == hashes[some_other_node]
      nodes.each do | node |
        tuple = bijection_hashes.find do |k, v| 
          (v == bijection_hashes[node]) && 
          # eql? instead of include? since RDF.rb coincedentally-same-named identifiers will be ==
          other_nodes.any? do | item | k.eql?(item) end
        end
        next unless tuple
        target = tuple.first
        bijection_hashes.delete target
        bijection[node] = target
      end

      # This if is the return statement, believe it or not.
      #
      # First, is the anonymous node mapping 1 to 1?
      # If so, we have a bijection and are done
      if (bijection.keys.sort == nodes.sort) && (bijection.values.sort == other_nodes.sort)
        bijection
      # So we've got unhashed nodes that can't be definitively grounded.  Make
      # a tentative bijection between two with identical ungrounded signatures
      # in the graph and recurse.
      else
        bijection = nil
        nodes.each do | node |
          # we don't replace grounded nodes' hashes
          next if hashes.member? node
          bijectable = other_nodes.any? do | other_node |
            # we don't replace grounded nodes' hashes
            next if hashes.member? other_node
            # don't bother unless its even feasible
            next unless potential_hashes[node] == potential_hashes[other_node]
            hash = Digest::SHA1.hexdigest(node.to_s)
            test_hashes = { node => hash, other_node => hash}
            bijection = build_bijection_to(anon_stmts, nodes, other_anon_stmts, other_nodes, hashes.merge(test_hashes))
          end
          break if bijection
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
          if statement.subject.anonymous? && (!(statement.subject == identifier))
            if hashes.member? statement.subject
              node_hashes << (hashes[statement.subject] + statement.predicate.to_s)
            else
              grounded = false
            end
          elsif !(statement.subject.anonymous?)
            node_hashes << (statement.subject.to_s + statement.predicate.to_s)
          end

          if statement.object.anonymous? && (!(statement.object == identifier))
            if hashes.member? statement.object
              node_hashes << (statement.predicate.to_s + hashes[statement.object])
            else
              grounded = false
            end
          elsif !(statement.object.anonymous?)
            node_hashes << (statement.predicate.to_s + statement.object.to_s)
          end
        end
      end
      [grounded,Digest::SHA1.hexdigest(node_hashes.sort.to_s)]
    end
  end



  module Enumerable 
    include RDF::Isomorphic
  end
end

