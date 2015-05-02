module MSFL
  module Visitors
    class Base
      def visit(obj)
        send("visit_#{obj.class.to_s.gsub('::', '_')}", obj)
      end
    end
  end
end