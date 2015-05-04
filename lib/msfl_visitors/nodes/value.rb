require_relative 'base'
module MSFLVisitors
  module Nodes
    class Value < Base

      attr_accessor :value

      def accept(visitor)
        visitor.visit self
      end

      def initialize(expr)
        self.value = expr
      end

      def ==(other)
        self.class == other.class &&
          value == other.value
      end
    end
  end
end