module MSFLVisitors
  module Renderers
    class Renderer
      def initialize(node)
        @node = node
      end

      private

      attr_reader :node
    end
  end
end
