module MSFL
  module Visitors
    class ChewyTermFilter < Base

      # Instead of using string interpolation only supported operators are enabled
      COMPARISON_OPERATORS = { eq: "==", gt: ">", gte: ">=", lt: "<", lte: "<=" }

      def visit_MSFL_Nodes_Boolean(obj, collector)
        collector << obj.value
      end

      def visit_MSFL_Nodes_Date(obj, collector)
        collector << obj.value.iso8601
      end

      def visit_MSFL_Nodes_DateTime(obj, collector)
        collector << obj.value.iso8601
      end

      def visit_MSFL_Nodes_Equal(obj, collector, suppress_parens = false)
        comparison_helper :eq, obj, collector, suppress_parens
      end

      def visit_MSFL_Nodes_GreaterThan(obj, collector, suppress_parens = false)
        comparison_helper :gt, obj, collector, suppress_parens
      end

      def visit_MSFL_Nodes_GreaterThanEqual(obj, collector, suppress_parens = false)
        comparison_helper :gte, obj, collector, suppress_parens
      end

      def visit_MSFL_Nodes_LessThan(obj, collector, suppress_parens = false)
        comparison_helper :lt, obj, collector, suppress_parens
      end

      def visit_MSFL_Nodes_LessThanEqual(obj, collector, suppress_parens = false)
        comparison_helper :lte, obj, collector, suppress_parens
      end

      def visit_MSFL_Nodes_Number(obj, collector)
        collector << obj.value
      end

      def visit_MSFL_Nodes_Time(obj, collector)
        collector << obj.value.iso8601
      end

      def visit_MSFL_Nodes_Word(obj, collector)
        collector << "#{obj.value.to_s}"
      end

    private
      def comparison_helper(operator, obj, collector, suppress_parens = false)
        unless suppress_parens
          collector << "( "
        end
        collector = visit obj.left, collector
        collector << " #{COMPARISON_OPERATORS.fetch(operator.to_sym)} "
        collector = visit obj.right, collector
        unless suppress_parens
          collector << " )"
        end
        collector
      end
    end
  end
end