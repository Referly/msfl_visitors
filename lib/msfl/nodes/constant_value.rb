module MSFL
  module Nodes
    class ConstantValue

      def accept(visitor)
        visitor.visit self
      end
    end
  end
end