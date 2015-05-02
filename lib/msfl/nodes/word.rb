module MSFL
  module Nodes
    class Word

      attr_accessor :value

      def accept(visitor)
        visitor.visit self
      end
    end
  end
end