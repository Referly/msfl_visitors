module MSFL
  module Visitors
    class ChewyTermFilter < Base

      def visit_MSFL_Nodes_Date(obj, collector)
        collector << obj.value.iso8601
      end

      def visit_MSFL_Nodes_DateTime(obj, collector)
        collector << obj.value.iso8601
      end

      def visit_MSFL_Nodes_Number(obj, collector)
        collector << obj.value
      end

      def visit_MSFL_Nodes_Word(obj, collector)
        collector << "#{obj.value.to_s}"
      end


    end
  end
end