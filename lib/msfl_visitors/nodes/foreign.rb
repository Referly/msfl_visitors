require_relative 'binary'
module MSFLVisitors
  module Nodes
    class Foreign < Binary
      # left is the dataset node
      # right is the filter node
      def accept(visitor)
        visitor.visit self
        left.accept visitor
        right.accept visitor
      end
    end
  end
end