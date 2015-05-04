module MSFLVisitors
  module Renderers
    class RenderConstant < Renderer
      def initialize(constant)
        @rendered = constant
      end
      def render
        @rendered
      end
    end
  end
end
