require_relative 'term_filter'
module MSFLVisitors
  module Renderers
    module Chewy
      class Aggregations
        def render(node)
          case node

            when Nodes::Given
              ' GIVEN '

            when Nodes::Field
              node.value.to_sym

            when Nodes::Word
              node.value.to_s

            when Nodes::Equal
              { term: node.value }

            else
              fail ArgumentError, "Unable to render node in MSFLVisitors::Renderers::Chewy::Aggregations#render"
          end
        end
      end
    end
  end
end
