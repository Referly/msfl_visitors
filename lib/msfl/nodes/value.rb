module MSFL
  module Nodes
    class Value

      attr_accessor :value

      def accept(visitor)
        visitor.visit self
      end

      def initialize(expr)
        self.value = expr
      end
    end
  end
end