module MSFL
  module Visitors
    class ChewyTermFilter < Base
      def visit_MSFL_Nodes_Word(obj)
        puts "chewy #{obj.value.to_s}"
      end
    end
  end
end