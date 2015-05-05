require_relative 'base'
module MSFLVisitors
  module Nodes
    class Filter < Base

      attr_accessor :contents

      def accept(visitor)
        contents.each do |item|
          item.accept visitor
        end
      end

      # @param nodes [Array<MSFL::Nodes::Base>] the nodes that the filter surrounds
      def initialize(nodes)
        self.contents = Array(nodes)
      end

      def ==(other)
        self.class == other.class &&
            contents == other.contents
      end
    end
  end
end