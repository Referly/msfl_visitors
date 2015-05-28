require 'forwardable'
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
            clauses.concat get_visitor.visit(node)
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
          Nodes::Containment            => '==',
          Nodes::GreaterThan            => '>',
          Nodes::GreaterThanEqual       => '>=',
          Nodes::Equal                  => '==',
          Nodes::LessThan               => '<',
          Nodes::LessThanEqual          => '<=',
      }

      def visit(node)
        case node
          when  Nodes::Field
            node.value.to_s
          when  Nodes::Word
            "\"#{node.value}\""
          when Nodes::Date, Nodes::Time
            "\"#{node.value.iso8601}\""
          when  Nodes::Number, Nodes::Boolean
            node.value
          when  Nodes::Containment,
                Nodes::GreaterThan,
                Nodes::GreaterThanEqual,
                Nodes::Equal,
                Nodes::LessThan,
                Nodes::LessThanEqual
            "#{node.left.accept(visitor)} #{BINARY_OPERATORS[node.class]} #{node.right.accept(visitor)}"
          when  Nodes::Set
            "[ " + node.contents.map { |n| n.accept(visitor) }.join(" , ") + " ]"
          when Nodes::Filter
            if node.contents.count == 1
              node.contents.first.accept(visitor)
            else
              node.contents.map { |n| "( " + n.accept(visitor) + " )" }.join(" & ")
            end

          when Nodes::And
            if node.set.contents.count == 1
              node.set.contents.first.accept(visitor)
            else
              node.set.contents.map { |n| "( " + n.accept(visitor) + " )" }.join(" & ")
            end

          when Nodes::Foreign
            "#{node.left.accept visitor}.filter { #{node.right.accept visitor} }"

          when Nodes::Dataset
            "has_child( :#{node.value} )"

          else
            fail ArgumentError, "TERMFILTER cannot visit: #{node.class.name}"
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
          Nodes::LessThan               => :lt,
          Nodes::LessThanEqual          => :lte,
      }

      def visit(node)
        case node
          when Nodes::Partial
            # { given: Hash[[node.left.accept(visitor), node.right.accept(visitor)]] }

            # build the aggregate criteria clause first
            # agg_criteria_clause = { clause: { agg_field_name: :portfolio_size, operator: :gt, test_value: 2 }, method_to_execute: :aggregations }
            agg_criteria_clause = { clause: node.right.accept(visitor), method_to_execute: :aggregations }
            # switch to the term filter mode
            visitor.mode = :term
            given_clause = { clause: node.left.accept(visitor) }

            # switch back to the aggregations mode
            visitor.mode = :aggregations
            # return the result of the visitation
            [agg_criteria_clause, given_clause]



          when Nodes::Equal
            # { term: { node.left.accept(visitor) => node.right.accept(visitor) } }
            { agg_field_name: node.left.accept(visitor), operator: :eq, test_value: node.right.accept(visitor) }
            # [{ clause:  }]
          when Nodes::Field
            node.value.to_sym
          when Nodes::Date, Nodes::Time
            node.value.iso8601
          when  Nodes::Word,
                Nodes::Number,
                Nodes::Boolean,
                Nodes::Dataset
            node.value
          when  Nodes::GreaterThan,
                Nodes::GreaterThanEqual,
                Nodes::LessThan,
                Nodes::LessThanEqual
            { agg_field_name: node.left.accept(visitor), operator: RANGE_OPERATORS[node.class], test_value: node.right.accept(visitor) }
            # { range: { node.left.accept(visitor) => { RANGE_OPERATORS[node.class] =>  node.right.accept(visitor) } } }
          when Nodes::Given
            [:filter, node.contents.first.accept(visitor)]
          when Nodes::ExplicitFilter
            # [:filter, node.contents.map { |n| n.accept(visitor) }.reduce({}) { |hsh, x| hsh.merge!(x); hsh } ]
            node.contents.map { |n| n.accept(visitor) }.first
          when Nodes::NamedValue
            # [:aggs, {node.name.accept(visitor).to_sym => Hash[[node.value.accept(visitor)]]}]
            node.value.accept(visitor)
          when Nodes::Containment
            { agg_field_name: node.left.accept(visitor).to_sym, operator: :in, test_value: node.right.accept(visitor) }
          when Nodes::Set
            node.contents.map { |n| n.accept(visitor) }
          when Nodes::Filter
            if node.contents.count == 1
              node.contents.first.accept visitor
            else
              { and: node.contents.map { |n| n.accept(visitor) } }
            end
          when Nodes::And
            { and: node.set.accept(visitor) }

          when Nodes::Foreign
            { foreign: Hash[[[:type, node.left.accept(visitor)], [:filter, node.right.accept(visitor)]]] }

          else
            fail ArgumentError, "AGGREGATIONS cannot visit: #{node.class.name}"
        end
      end

      private

      attr_reader :visitor
    end
  end
end

