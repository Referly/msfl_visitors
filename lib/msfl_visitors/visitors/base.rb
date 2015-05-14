module MSFLVisitors
  module Visitors
    class Base
      # @mattvanhorn we can look at moving these to protected
      attr_reader :collector, :renderer

      def initialize(collector, renderer)
        @collector = collector
        @renderer = renderer
      end

      def visit(obj)
        collector << renderer.render(obj)
      end
    end
  end
end