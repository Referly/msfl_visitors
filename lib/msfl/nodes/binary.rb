module MSFL
  module Nodes
    class Binary

      attr_accessor :left, :right

      def accept(visitor)
        visitor.visit self
      end

      def initialize(left, right)
        self.left = left
        self.right = right
      end
    end
  end
end