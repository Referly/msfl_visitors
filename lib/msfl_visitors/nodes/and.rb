require_relative 'binary'
module MSFLVisitors
  module Nodes
    class And < Binary

      def accept(visitor)
        MSFLVisitors::Nodes::Grouping::Grouping.new(left).accept visitor
        visitor.visit self
        MSFLVisitors::Nodes::Grouping::Grouping.new(right).accept visitor
      end
    end
  end
end