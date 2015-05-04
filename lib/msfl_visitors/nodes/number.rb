require_relative 'range_value'
module MSFLVisitors
  module Nodes
    class Number < RangeValue
      def collect_value
        value
      end
    end
  end
end