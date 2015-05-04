module MSFLVisitors
  module Visitors
    class ChewyTermFilter < Base

      def render(obj)
        renderer.render(obj)
      end

      private

      attr_reader :renderer
    end
  end
end