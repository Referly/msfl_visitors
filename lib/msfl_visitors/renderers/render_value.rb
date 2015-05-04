module MSFLVisitors
  module Renderers
    class RenderValue < Renderer
      def render
        node.value
      end
    end
  end
end
