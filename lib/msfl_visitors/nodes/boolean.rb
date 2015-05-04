require_relative 'value'
module MSFLVisitors
  module Nodes
    class Boolean < Value
      def collect_value
        value
      end
    end
  end
end