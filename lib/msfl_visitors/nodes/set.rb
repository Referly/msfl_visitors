require_relative 'base'
module MSFLVisitors
  module Nodes
    class Set < Base

      extend Forwardable

      attr_accessor :contents

      def_delegators :contents, :count, :first, :each

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