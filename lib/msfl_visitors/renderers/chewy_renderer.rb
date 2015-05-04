module MSFLVisitors
  module Renderers
    class ChewyRenderer
      def render(node)
        wrap_node(node).render
      end

      def wrap_node(node)
        case node

        when Nodes::Comparison, Nodes::And
          RenderBinary.new(node)

        when Nodes::Date, Nodes::Time
          RenderTemporal.new(node)

        when Nodes::Boolean, Nodes::Number
          RenderValue.new(node)

        when Nodes::Word
          RenderStringValue.new(node)

        when Nodes::Grouping::Close
          RenderConstant.new(' )')

        when Nodes::Grouping::Open
          RenderConstant.new('( ')

        else
          fail ArgumentError.new("Unrecognized node type: #{node.class}")
        end
      end

      class Renderer
        def initialize(node)
          @node = node
        end

        private

        attr_reader :node
      end

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

      class RenderConstant < Renderer
        def initialize(constant)
          @rendered = constant
        end
        def render
          @rendered
        end
      end

      class RenderStringValue < Renderer
        def render
          node.value.to_s
        end
      end

      class RenderTemporal < Renderer
        def render
          node.value.iso8601
        end
      end

      class RenderValue < Renderer
        def render
          node.value
        end
      end

    end
  end
end
