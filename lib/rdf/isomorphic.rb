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
    # bijection of this RDF::Enumerable's to another RDF::Enumerable's blank
    # nodes, or nil if a bijection cannot be found.
    # @example
    #     repository_a.bijection_to repository_b
    # @param other [RDF::Enumerable]
    # @return [Hash, nil]
    def bijection_to(other)

      reified_stmts_match = each_statement.all? do | stmt |
        stmt.has_blank_nodes? || other.has_statement?(stmt)
      end

      if reified_stmts_match
        blank_stmts = find_all { |statement| statement.has_blank_nodes? }
        other_blank_stmts = other.find_all { |statement| statement.has_blank_nodes? }
        nodes = blank_nodes_in(blank_stmts)
        other_nodes = blank_nodes_in(other_blank_stmts)
        build_bijection_to blank_stmts, nodes, other_blank_stmts, other_nodes
      else
        nil
      end

    end

    private

    # The main recursive bijection algorithm.
    #
    # This algorithm is very similar to the one explained by Jeremy Carroll in
    # http://www.hpl.hp.com/techreports/2001/HPL-2001-293.pdf. Page 12 has the
    # relevant pseudocode.
    #
    # Many more comments are in the method itself.
    # @private
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
      
      # First we create a signature hash of each node's relevant neighbors.  As nodes become 'grounded',
      # they can be the basis for further nodes becoming grounded, so we cycle through the list until
      # we can't ground any more nodes.
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
      # hashes[node] == hashes[some_other_node].  This means we can biject the two nodes.
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
          # We don't replace grounded nodes' hashes
          next if hashes.member? node
          bijectable = other_nodes.any? do | other_node |
            # We don't replace grounded nodes' hashes
            next if hashes.member? other_node
            # The ungrounded signature must match for this pair to have a chance.
            # If the signature doesn't match, skip it.
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

    # @private
    # @return [RDF::Node]
    # Blank nodes appearing in given list of statements
    def blank_nodes_in(blank_stmt_list)
      nodes = []
      blank_stmt_list.each do | statement |
        nodes << statement.object if statement.object.anonymous?
        nodes << statement.subject if statement.subject.anonymous?
      end
      nodes.uniq
    end
 
    # Generate a hash for a node based on the signature of the statements it
    # appears in.  Signatures consist of grounded elements in statements
    # associated with a node, that is, anything but an ungrounded anonymous
    # node.  Creating the hash is simply hashing a sorted list of each
    # statement's signature, which is itself a concatenation of the string form
    # of all grounded elements.
    #
    # Nodes other than the given node are considered grounded if they are a
    # member in the given hash.
    #
    # Returns a tuple consisting of grounded being true or false and the String
    # for the hash
    # @private
    # @return [Boolean, String]
    def node_hash_for(node,statements,hashes)
      statement_signatures = []
      grounded = true
      statements.each do | statement |
        if (statement.object == node) || (statement.subject == node)
          statement_signatures << hash_string_for(statement,hashes)
          [statement.subject, statement.object].each do | resource |
            grounded = false unless grounded(resource, hashes)
          end
        end
      end
      [grounded,Digest::SHA1.hexdigest(statement_signatures.sort.to_s)]
    end

    # Provide a string signature for the given statement.
    # @private
    def hash_string_for(statement,hashes)
      hash = ""
      hash << string_for_node(statement.subject,hashes)
      hash << statement.predicate.to_s
      hash << string_for_node(statement.object,hashes)
      hash
    end

    # Returns true if a given node is grounded
    # @private
    def grounded(node, hashes)
      (!(node.anonymous?)) || (hashes.member? node)
    end

    # Provides a string for the given node for use in a string signature
    # @private
    def string_for_node(node, hashes)
      if node.anonymous?
        if hashes.member? node
          hashes[node]
        else
          ""
        end
      else
        node.to_s
      end
    end
  end



  module Enumerable 
    include RDF::Isomorphic
  end
end

