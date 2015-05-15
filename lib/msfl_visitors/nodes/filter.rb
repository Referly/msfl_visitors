require_relative 'base'
require 'forwardable'
module MSFLVisitors
  module Nodes
    class Filter < Base
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