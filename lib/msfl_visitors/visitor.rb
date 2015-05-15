require 'forwardable'
# require_relative 'collector'
require_relative 'renderers'
module MSFLVisitors
  class Visitor

    attr_accessor :clauses, :current_clause
    attr_writer :mode

    def initialize
      self.mode = :term # or :aggregations
      self.clauses = Array.new

    end

    def visit(node)
      case node
        when Nodes::Partial
          in_aggregation_mode do
            clauses << { clause: get_visitor.visit(node), method_to_execute: :aggregations }
            ""
          end
        else
          get_visitor.visit(node)
      end
    end

    def get_visitor
      (mode == :term ? TermFilterVisitor : AggregationsVisitor).new(self)
    end

    def in_aggregation_mode
      self.mode = :aggregations
      result = yield if block_given?
      self.mode = :term
      result
    end

    def visit_tree(root)
      [{clause: root.accept(self)}].concat(clauses).reject { |c| c[:clause] == "" }
    end

    private

    attr_reader :mode

    class TermFilterVisitor
      def initialize(visitor)
        @visitor = visitor
      end

      BINARY_OPERATORS = {
          Nodes::GreaterThan            => '>',
          Nodes::GreaterThanEqual       => '>=',
      }

      def visit(node)
        case node
          when Nodes::Equal
            [{ clause: "#{node.left.accept(visitor)} == #{node.right.accept(visitor)}" }]
          when Nodes::Field
            node.value.to_s
          when Nodes::Word
            "\"#{node.value}\""
          when Nodes::Number
            node.value
          when Nodes::GreaterThan, Nodes::GreaterThanEqual
            "#{node.left.accept(visitor)} #{BINARY_OPERATORS[node.class]} #{node.right.accept(visitor)}"
          when Nodes::Containment
            "#{node.left.accept(visitor)} == #{node.right.accept(visitor)}"
          when Nodes::Set::Set
            "[ " + node.contents.map { |n| n.accept(visitor) }.join(' , ') + " ]"
          else
            fail "TERMFILTER cannot visit: #{node.class.name}"
        end
      end

      private

      attr_reader :visitor
    end

    class AggregationsVisitor
      def initialize(visitor)
        @visitor = visitor
      end

      RANGE_OPERATORS = {
          Nodes::GreaterThan            => :gt,
          Nodes::GreaterThanEqual       => :gte,
      }

      def visit(node)
        case node
          when Nodes::Partial
            { given: Hash[[node.left.accept(visitor), node.right.accept(visitor)]] }

          when Nodes::Equal
            { term: { node.left.accept(visitor) => node.right.accept(visitor) } }
            # [{ clause:  }]
          when Nodes::Field
            node.value.to_sym
          when Nodes::Word, Nodes::Number
            node.value
          when Nodes::GreaterThan, Nodes::GreaterThanEqual
            { range: { node.left.accept(visitor) => { RANGE_OPERATORS[node.class] =>  node.right.accept(visitor) } } }
          when Nodes::Given
            [:filter, node.contents.first.accept(visitor)]
          when Nodes::ExplicitFilter
            [:filter, node.contents.map { |n| n.accept(visitor) }.reduce({}) { |hsh, x| hsh.merge!(x); hsh } ]
          when Nodes::NamedValue
            [:aggs, {node.name.accept(visitor).to_sym => Hash[[node.value.accept(visitor)]]}]
          when Nodes::Containment
            { terms: {node.left.accept(visitor).to_sym => node.right.accept(visitor)} }
          when Nodes::Set::Set
            node.contents.map { |n| n.accept(visitor) }
          else
            fail "AGGREGATIONS cannot visit: #{node.class.name}"
        end
      end

      private

      attr_reader :visitor
    end
  end
end

