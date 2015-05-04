module MSFLVisitors
  module Renderers
    class RenderTemporal < Renderer
      def render
        node.value.iso8601
      end
    end
  end
end
