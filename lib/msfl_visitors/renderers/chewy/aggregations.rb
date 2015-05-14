require_relative 'term_filter'
module MSFLVisitors
  module Renderers
    module Chewy
      class Aggregations
        def render(node, args = [])
          case node

            when Nodes::Given
              ' GIVEN '

            when Nodes::Field
              node.value.to_sym

            when Nodes::Word
              node.value.to_s

            when Nodes::Equal
              { term: { args.first => args.second } }

            else
              fail ArgumentError, "Unable to render node in MSFLVisitors::Renderers::Chewy::Aggregations#render"
          end
        end
      end
    end
  end
end
