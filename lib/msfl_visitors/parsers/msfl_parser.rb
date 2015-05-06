require 'msfl'
module MSFLVisitors
  module Parsers
    class MSFLParser
      include MSFL::Validators::Definitions::HashKey

      OPERATORS_TO_NODE_CLASS = {
          gt:         Nodes::GreaterThan,
          gte:        Nodes::GreaterThanEqual,
      }

      def parse(obj, lhs = false)
        case obj

          when Float, Fixnum
            MSFLVisitors::Nodes::Number.new obj

          when Hash
            parse_Hash obj, lhs

          when MSFL::Types::Set
            parse_Set obj, lhs

          when Symbol, String, NilClass
            MSFLVisitors::Nodes::Word.new obj.to_s

          else
            fail ArgumentError, "Invalid NMSFL, unable to parse."
        end
      end




    private

      def parse_Hash(obj, lhs = false)
        nodes = Array.new
        obj.each do |k, v|
          nodes << hash_dispatch(k, v, lhs)
        end
        # If there's exactly one node in nodes and it's a filter node we don't want to wrap it in yet
        # another filter node, so we just return the filter node
        if nodes.count == 1 && nodes.first.is_a?(MSFLVisitors::Nodes::Filter)
          nodes.first
        else
          MSFLVisitors::Nodes::Filter.new nodes
        end
      end

      def parse_Set(obj, lhs = false)

      end

      def hash_dispatch(key, value, lhs = false)
        if hash_key_operators.include? key
          # Detect the node type, forward the lhs if it was passed in (essentially when the operator is a binary op)
          args = [lhs, parse(value)] if lhs
          args ||= [parse(value)]
          OPERATORS_TO_NODE_CLASS[key].new(*args)
        else
          # the key is a field
          # there are three possible scenarios when they key is a field
          # 1. the implicit equality scenario, where the right side is a value
          #     { make: "toyota" }
          #
          # 2. the explicit comparison scenario
          #     { value: { gte: 2000 } }
          #
          # 3. the containment scenario
          #     { model: { in: ["Corolla", "Civic", "Mustang"] } }
          #
          # 2 & 3 are just hashes and can be parsed using the same method
          lhs = MSFLVisitors::Nodes::Field.new key

          # the node type generated by parsing value can use the lhs node when appropriate and otherwise ignore it
          # although I can't think of a situation when it would ignore it.
          rhs = parse value, lhs
          if rhs.is_a? MSFLVisitors::Nodes::Value
            MSFLVisitors::Nodes::Equal.new lhs, rhs
          else
            rhs
          end
        end
      end
    end
  end
end