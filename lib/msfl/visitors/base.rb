module MSFL
  module Visitors
    class Base
      attr_accessor :collector

      def visit(obj)
        send("visit_#{obj.class.to_s.gsub('::', '_')}", obj, collector)
      end

      def initialize(collector)
        self.collector = collector
      end
    end
  end
end