require_relative '../constant_value'
module MSFLVisitors
  module Nodes
    module Grouping
      class Open < ConstantValue
        def collect_value
          "( "
        end
      end
    end
  end
end