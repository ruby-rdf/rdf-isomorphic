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
    def isomorphic_with?(other)
      !(bijection_to(other).nil?)
    end

    alias_method :isomorphic?, :isomorphic_with?


    # Returns a hash of RDF::Nodes => RDF::Nodes representing an isomorphic
    # bijection of this RDF::Enumerable's to another RDF::Enumerable's blank
    # nodes, or nil if a bijection cannot be found.
    # @example
    #     repository_a.bijection_to repository_b
    # @param other [RDF::Enumerable]
    # @return [Hash, nil]
    def bijection_to(other)

      grounded_stmts_match = (size == other.size)

      grounded_stmts_match &&= each_statement.all? do | stmt |
        stmt.has_blank_nodes? || other.has_statement?(stmt)
      end

      if grounded_stmts_match
        # blank_stmts and other_blank_stmts are just a performance
        # consideration--we could just as well pass in self and other.  But we
        # will be iterating over this list quite a bit during the algorithm, so
        # we break it down to the parts we're interested in.
        blank_stmts = find_all { |statement| statement.has_blank_nodes? }
        other_blank_stmts = other.find_all { |statement| statement.has_blank_nodes? }

        nodes = RDF::Isomorphic.blank_nodes_in(blank_stmts)
        other_nodes = RDF::Isomorphic.blank_nodes_in(other_blank_stmts)
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
    #
    # @param [RDF::Enumerable]  anon_stmts
    # @param [Array]            nodes
    # @param [RDF::Enumerable]  other_anon_stmts
    # @param [Array]            other_nodes
    # @param [Hash]             these_grounded_hashes
    # @param [Hash]             other_grounded_hashes
    # @return [nil,Hash]
    # @private
    def build_bijection_to(anon_stmts, nodes, other_anon_stmts, other_nodes, these_grounded_hashes = {}, other_grounded_hashes = {})


      # Create a hash signature of every node, based on the signature of
      # statements it exists in.  
      # We also save hashes of nodes that cannot be reliably known; we will use
      # that information to eliminate possible recursion combinations.
      # 
      # Any mappings given in the method parameters are considered grounded.
      these_hashes, these_ungrounded_hashes = RDF::Isomorphic.hash_nodes(anon_stmts, nodes, these_grounded_hashes)
      other_hashes, other_ungrounded_hashes = RDF::Isomorphic.hash_nodes(other_anon_stmts, other_nodes, other_grounded_hashes)


      # Using the created hashes, map nodes to other_nodes
      bijection = {}
      nodes.each do | node |
        other_node, other_hash = other_hashes.find do | other_node, other_hash |
          # we need to use eql?, as coincedentally-named bnode identifiers are == in rdf.rb
          these_hashes[node].eql? other_hash
        end
        next unless other_node
        bijection[node] = other_node
        
        # we need to delete , as we don't want two nodes with the same hash
        # to be mapped to the same other_node.
        other_hashes.delete other_node
      end

      # bijection is now a mapping of nodes to other_nodes.  If all are
      # accounted for on both sides, we have a bijection.
      #
      # If not, we will speculatively mark pairs with matching ungrounded
      # hashes as bijected and recurse.
      unless (bijection.keys.sort == nodes.sort) && (bijection.values.sort == other_nodes.sort)
        bijection = nil
        nodes.any? do | node |

          # We don't replace grounded nodes' hashes
          next if these_hashes.member? node
          other_nodes.any? do | other_node |

            # We don't replace grounded other_nodes' hashes
            next if other_hashes.member? other_node

            # The ungrounded signature must match for this to potentially work
            next unless these_ungrounded_hashes[node] == other_ungrounded_hashes[other_node]

            hash = Digest::SHA1.hexdigest(node.to_s)
            bijection = build_bijection_to(anon_stmts, nodes, other_anon_stmts, other_nodes, these_hashes.merge( node => hash), other_hashes.merge(other_node => hash))
          end
          bijection
        end
      end

      bijection
    end

    # Blank nodes appearing in given list of statements
    # @private
    # @return [RDF::Node]
    def self.blank_nodes_in(blank_stmt_list)
      nodes = []
      blank_stmt_list.each do | statement |
        nodes << statement.object if statement.object.node?
        nodes << statement.subject if statement.subject.node?
      end
      nodes.uniq
    end

    # Given a set of statements, create a mapping of node => SHA1 for a given
    # set of blank nodes.  grounded_hashes is a mapping of node => SHA1 pairs
    # that we will take as a given, and use those to make more specific
    # signatures of other nodes.  
    #
    # Returns a tuple of hashes:  one of grounded hashes, and one of all
    # hashes.  grounded hashes are based on non-blank nodes and grounded blank
    # nodes, and can be used to determine if a node's signature matches
    # another.
    #
    # @param [Array] statements 
    # @param [Array] nodes
    # @param [Hash] grounded_hashes
    # @private
    # @return [Hash, Hash]
    def self.hash_nodes(statements, nodes, grounded_hashes)
      hashes = grounded_hashes.dup
      ungrounded_hashes = {}
      hash_needed = true

      # We may have to go over the list multiple times.  If a node is marked as
      # grounded, other nodes can then use it to decide their own state of
      # grounded.
      while hash_needed 
        hash_needed = false
        nodes.each do | node |
          unless hashes.member? node
            grounded, hash = node_hash_for(node, statements, hashes)
            if grounded
              hash_needed = true
              hashes[node] = hash
            end
            ungrounded_hashes[node] = hash
          end
        end
      end
      [hashes,ungrounded_hashes]
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
    def self.node_hash_for(node,statements,hashes)
      statement_signatures = []
      grounded = true
      statements.each do | statement |
        if (statement.object == node) || (statement.subject == node)
          statement_signatures << hash_string_for(statement,hashes,node)
          [statement.subject, statement.object].each do | resource |
            grounded = false unless grounded(resource, hashes) || resource == node
          end
        end
      end
      # Note that we sort the signatures--without a canonical ordering, 
      # we might get different hashes for equivalent nodes.
      [grounded,Digest::SHA1.hexdigest(statement_signatures.sort.to_s)]
    end

    # Provide a string signature for the given statement, collecting
    # string signatures for grounded node elements.
    # return [String]
    # @private
    def self.hash_string_for(statement,hashes,node)
      string = ""
      string << string_for_node(statement.subject,hashes,node)
      string << statement.predicate.to_s
      string << string_for_node(statement.object,hashes,node)
      string 
    end

    # Returns true if a given node is grounded
    # A node is groundd if it is not a blank node or it is included
    # in the given mapping of grounded nodes.
    # @return [Boolean]
    # @private
    def self.grounded(node, hashes)
      (!(node.node?)) || (hashes.member? node)
    end

    # Provides a string for the given node for use in a string signature
    # Non-anonymous nodes will return their string form.  Grounded anonymous
    # nodes will return their hashed form.
    # @return [String]
    # @private
    def self.string_for_node(node, hashes,target)
      case
        when node == target
          "itself"
        when node.node? && hashes.member?(node)
          hashes[node]
        when node.node?
          "a blank node"
        else
          node.to_s
      end
    end
  end


  # Extend RDF::Enumerables with these functions.
  module Enumerable 
    include RDF::Isomorphic
  end

  autoload :VERSION,  'rdf/isomorphic/version'
end

