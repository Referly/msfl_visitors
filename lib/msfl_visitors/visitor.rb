require 'forwardable'
# require_relative 'collector'
require_relative 'renderers'
module MSFLVisitors
  class Visitor

    attr_writer :mode

    def initialize
      @mode = :term # or :aggregations
    end

    def visit(node)
      case node
        when Nodes::Partial
          in_aggregation_mode do
            get_visitor.visit(node)
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

    private

    attr_reader :mode

    class TermFilterVisitor
      def initialize(visitor)
        @visitor = visitor
      end

      def visit(node)
        case node
          when Nodes::Equal
            [{ clause: "#{node.left.accept(@visitor)} == #{node.right.accept(@visitor)}" }]
          when Nodes::Field
            node.value.to_s
          when Nodes::Word
            "\"#{node.value}\""
          when Nodes::Number
            node.value
          when Nodes::GreaterThan
            fail 'YO'
          else
            fail "TERM: #{node.class.name}"
        end
      end
    end

    class AggregationsVisitor
      def initialize(visitor)
        @visitor = visitor
      end

      def visit(node)
        case node
          when Nodes::Partial
            [{ clause: { given: Hash[[node.left.accept(visitor), node.right.accept(visitor)]] }}]

          when Nodes::Equal
            { term: { node.left.accept(visitor) => node.right.accept(visitor) } }
            # [{ clause:  }]
          when Nodes::Field
            node.value.to_sym
          when Nodes::Word, Nodes::Number
            node.value
          when Nodes::GreaterThan
            { range: { node.left.accept(visitor) => {gt: node.right.accept(visitor) } } }
          when Nodes::Given
            [:filter, node.contents.first.accept(visitor)]
          when Nodes::ExplicitFilter
            [:filter, node.contents.map { |n| n.accept(visitor) }.reduce({}) { |hsh, x| hsh.merge!(x); hsh } ]
          when Nodes::NamedValue
            [:aggs, {node.name.accept(visitor).to_sym => Hash[[node.value.accept(visitor)]]}]
          else
            fail "AGGREGATIONS: #{node.class.name}"
        end
      end

      private

      attr_reader :visitor
    end
  end
end

