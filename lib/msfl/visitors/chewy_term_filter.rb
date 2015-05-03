module MSFL
  module Visitors
    class ChewyTermFilter < Base

      # Instead of using string interpolation only supported operators are enabled
      BINARY_OPERATORS = { eq: "==", gt: ">", gte: ">=", lt: "<", lte: "<=", and: "&" }

      def visit_MSFL_Nodes_And(obj, collector)
        binary_helper :and, collector
      end

      def visit_MSFL_Nodes_Boolean(obj, collector)
        collector << obj.value
      end

      def visit_MSFL_Nodes_Date(obj, collector)
        collector << obj.value.iso8601
      end

      def visit_MSFL_Nodes_DateTime(obj, collector)
        collector << obj.value.iso8601
      end

      def visit_MSFL_Nodes_Equal(obj, collector)
        binary_helper :eq, collector
      end

      def visit_MSFL_Nodes_GreaterThan(obj, collector)
        binary_helper :gt, collector
      end

      def visit_MSFL_Nodes_GreaterThanEqual(obj, collector)
        binary_helper :gte, collector
      end

      def visit_MSFL_Nodes_Grouping_Close(obj, collector)
        collector << " )"
      end

      def visit_MSFL_Nodes_Grouping_Open(obj, collector)
        collector << "( "
      end

      def visit_MSFL_Nodes_LessThan(obj, collector)
        binary_helper :lt, collector
      end

      def visit_MSFL_Nodes_LessThanEqual(obj, collector)
        binary_helper :lte, collector
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
      def binary_helper(operator, collector)
        collector << " #{BINARY_OPERATORS.fetch(operator.to_sym)} "
      end
    end
  end
end