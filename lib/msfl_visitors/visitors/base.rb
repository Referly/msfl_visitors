module MSFLVisitors
  module Visitors
    class Base
      attr_accessor :collector

      def initialize(collector)
        self.collector = collector
      end

      def visit(obj)
        collector << render(obj)
      end
    end
  end
end