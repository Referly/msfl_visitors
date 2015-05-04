module MSFLVisitors
  module Visitors
    class Base

      def initialize(collector, renderer=Renderers::ChewyRenderer)
        @collector = collector
        @renderer = renderer.new
      end

      def visit(obj)
        collector << render(obj)
      end

      private

      attr_reader :collector
    end
  end
end
