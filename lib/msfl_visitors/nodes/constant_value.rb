require_relative 'base'
module MSFLVisitors
  module Nodes
    class ConstantValue < Base

      def accept(visitor)
        visitor.visit self
      end
    end
  end
end