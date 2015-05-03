require_relative 'binary'
module MSFL
  module Nodes
    class And < Binary

      def accept(visitor)
        MSFL::Nodes::Grouping::Grouping.new(left).accept visitor
        visitor.visit self
        MSFL::Nodes::Grouping::Grouping.new(right).accept visitor
      end
    end
  end
end