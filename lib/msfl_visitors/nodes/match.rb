require_relative 'comparison'
module MSFLVisitors
  module Nodes
    class Match < Comparison
      def accept(visitor)
        visitor.visit self
      end
    end
  end
end