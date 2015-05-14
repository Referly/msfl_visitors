require_relative 'term_filter'
module MSFLVisitors
  module Renderers
    module Chewy
      class Aggregations < TermFilter
        def render(node)
          case node

            when Nodes::Given
              byebug
              ' GIVEN '

            else
              super
          end
        end
      end
    end
  end
end
