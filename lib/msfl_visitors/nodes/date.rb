require_relative 'range_value'
module MSFLVisitors
  module Nodes
    class Date < RangeValue
      def collect_value
        value.iso8601
      end
    end
  end
end