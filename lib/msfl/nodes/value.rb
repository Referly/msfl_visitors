require_relative 'base'
module MSFL
  module Nodes
    class Value < Base

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