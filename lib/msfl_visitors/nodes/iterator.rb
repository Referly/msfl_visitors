require_relative 'base'
module MSFLVisitors
  module Nodes
    class Iterator < Base

      attr_accessor :set

      # @param set [MSFLVisitors::Nodes::Set::Set] a set node that allows its elements to be iterated over
      def initialize(set)
        self.set = set
      end

      def ==(other)
        self.class == other.class &&
            set == other.set
      end
    end
  end
end