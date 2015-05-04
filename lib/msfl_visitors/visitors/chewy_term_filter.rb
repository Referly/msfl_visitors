module MSFLVisitors
  module Visitors
    class ChewyTermFilter < Base

      def render(obj)
        Renderers.wrap_node(obj).render
      end
    end
  end
end