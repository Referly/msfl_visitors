require_relative '../base'
module MSFLVisitors
  module Visitors
    module Chewy
      class Aggregations < Base

        SUPPORTED_NODES = [
            Nodes::GreaterThan,
            Nodes::Partial,
            Nodes::Given,
        ]

        def supported_node?(node)
          SUPPORTED_NODES.include? node.class
        end
      end
    end
  end
end