require_relative 'base'
module MSFLVisitors
  module Nodes
    class Filter < Base

      attr_accessor :contents

      def accept(visitor)
        contents.accept visitor
      end

      # @param nodes [Array<MSFL::Nodes::Base>] the nodes that the filter surrounds
      def initialize(nodes)
        self.contents = nodes
      end

      def ==(other)
        self.class == other.class &&
            contents == other.contents
      end
    end
  end
end