module MSFL
  module Visitors
    class Base
      def visit(obj, collector)
        send("visit_#{obj.class.to_s.gsub('::', '_')}", obj, collector)
      end
    end
  end
end