module MSFLVisitors
  module Renderers
    class RenderStringValue < Renderer
      def render
        node.value.to_s
      end
    end
  end
end
 