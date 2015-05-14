module MSFLVisitors
  module Nodes
    class NamedValue
      attr_accessor :name, :value

      def initialize(name, value)
        self.name = name
        self.value = value
      end

      def accept(visitor)
        visitor.visit(self)
      end
    end
  end
end