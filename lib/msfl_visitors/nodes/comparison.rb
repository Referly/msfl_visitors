require_relative 'binary'
module MSFLVisitors
  module Nodes
    class Comparison < Binary
      def collect_value
        MSFLVisitors::Nodes::BINARY_OPERATORS[self.class]
      end
    end
  end
end