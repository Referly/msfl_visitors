require 'msfl'
module MSFLVisitors
  module Parsers
    class MSFLParser
      OPERATORS_TO_NODE_CLASS = {
          and:        Nodes::And,
          gt:         Nodes::GreaterThan,
          gte:        Nodes::GreaterThanEqual,
          eq:         Nodes::Equal,
          lt:         Nodes::LessThan,
          lte:        Nodes::LessThanEqual,
          in:         Nodes::Containment,
          foreign:    Nodes::Foreign,
          dataset:    Nodes::Dataset,
          filter:     Nodes::ExplicitFilter,
          given:      Nodes::Given,
          partial:    Nodes::Partial,

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


      def initialize(dataset = nil)
        @dataset = dataset
      end

    private

      attr_accessor :dataset

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
        nodes = MSFL::Types::Set.new([])
        obj.each do |item|
          nodes << parse(item)
        end
        MSFLVisitors::Nodes::Set.new nodes
      end

      # A key/value pair needs to be parsed and handled while iterating across the Hash that the key/value pair belong to
      # lhs is for when the field is a parent of the actual operator node
      # ex. { year: { gte: 2010 } } needs to be converted to (gte(year, 2010)) -- infix operators to RPN
      def hash_dispatch(key, value, lhs = false)
        if OPERATORS_TO_NODE_CLASS.include? key
          # Detect the node type, forward the lhs if it was passed in (essentially when the operator is a binary op)
          case key
            when :foreign
              args = [hash_dispatch(:dataset, value[:dataset]), hash_dispatch(:filter, value[:filter])]

            when :partial
              args = [hash_dispatch(:given, value[:given]), hash_dispatch(:filter, value[:filter])]

            when :dataset
              args = [value]
            when :filter, :given
              # Explicit Filter
              # ex { foreign: { dataset: "person", filter: { age: 25 } } }
              # ex { partial: { given: { make: "Toyota" }, filter: { avg_age: 10 } } }
              args = value.map { |k,v| hash_dispatch(k,v) }
            else
              # fall back to a Filter Node
              args = [lhs, parse(value)] if lhs
              args ||= [parse(value)]
          end
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