require_relative 'value'
module MSFLVisitors
  module Nodes
    class Word < Value
      def collect_value
        value.to_s
      end
    end
  end
end