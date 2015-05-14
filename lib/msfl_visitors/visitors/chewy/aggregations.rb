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

        attr_accessor :visitor

        def visit(obj)
          return false unless supported_node?(obj)

          case obj

            # { clause: { range: { year: { gt: 2010 } } } }

            # { clause: { term: { make: "Toyota" } } }

            # { and: [x,y,z] }

            # { clause: { and: [{ term: { make: "Toyota" }}, {range: { year: { gt: 2010 } } }] }

            when Nodes::Equal
              collector << { term: { obj.left.accept(visitor) => obj.right.accept(visitor) }}

            else
              renderer.render obj
          end
          # collector << renderer.render(obj)
        end

        def supported_node?(node)
          SUPPORTED_NODES.include? node.class
        end
      end
    end
  end
end


