require_relative '../base'
module MSFLVisitors
  module Visitors
    module Chewy
      class Aggregations < Base

        SUPPORTED_NODES = [
            Nodes::Equal,
            Nodes::Field,
            Nodes::Given,
            Nodes::GreaterThan,
            Nodes::Partial,
            Nodes::Word,
        ]

        def visit(obj)
          return false unless supported_node?(obj)
          case obj
            when Nodes::Field
              collector.push(renderer.render obj)

            when Nodes::Word
              foo = collector.pop
              foo.call(renderer.render(obj))

            when Nodes::Equal
              left = collector.pop
              collector.push Proc.new { |r| renderer.render(obj, [left,r]) }
          end
        end

        def supported_node?(node)
          SUPPORTED_NODES.include? node.class
        end
      end
    end
  end
end