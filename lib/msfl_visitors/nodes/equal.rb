require_relative 'comparison'
module MSFLVisitors
  module Nodes
    class Equal < Comparison

      def accept(visitor)
        visitor.visit self
        #
        # case visitor.current_visitor
        #   when Visitors::Chewy::TermFilter
        #     super
        #
        #   when Visitors::Chewy::Aggregations
        #     @value = { left.accept(visitor) => right.accept(visitor) }
        #     visitor.visit(self)
        #
        #   else
        #     fail ArgumentError, "Unknown current visitor type."
        # end
      end

    end
  end
end