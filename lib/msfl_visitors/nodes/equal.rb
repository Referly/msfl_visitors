require_relative 'comparison'
module MSFLVisitors
  module Nodes
    class Equal < Comparison

      def accept(visitor)
        visitor.visit self
      end
    end
  end
end