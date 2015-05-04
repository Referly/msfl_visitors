module MSFLVisitors
  module Visitors
    class Base
      attr_accessor :collector

      def visit(obj)
        collector << obj.collect_value
      end

      def initialize(collector)
        self.collector = collector
      end
    end
  end
end