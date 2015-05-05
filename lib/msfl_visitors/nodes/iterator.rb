require_relative 'base'
module MSFLVisitors
  module Nodes
    class Iterator < Base

      attr_accessor :items

      def initialize(nodes)
        self.items = nodes
      end

      def ==(other)
        self.class == other.class &&
            items == other.items
      end
    end
  end
end