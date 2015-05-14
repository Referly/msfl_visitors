module MSFLVisitors
  module Nodes
    class Base
      def accept(visitor)
        visitor.visit(self)
      end
    end
  end
end