require_relative 'base'
module MSFL
  module Nodes
    class Binary < Base

      attr_accessor :left, :right

      def accept(visitor)
        visitor.visit left
        visitor.visit self
        visitor.visit right
      end

      def initialize(left, right)
        self.left = left
        self.right = right
      end
    end
  end
end