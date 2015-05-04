module MSFLVisitors
  module Renderers
    class RenderBinary < Renderer
      BINARY_OPERATORS = {
        Nodes::And              => ' & ',
        Nodes::GreaterThan      => ' > ',
        Nodes::LessThan         => ' < ',
        Nodes::GreaterThanEqual => ' >= ',
        Nodes::LessThanEqual    => ' <= ',
        Nodes::Equal            => ' == ',
      }

      def render
        BINARY_OPERATORS[node.class]
      end
    end
  end
end
