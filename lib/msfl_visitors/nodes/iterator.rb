require_relative 'base'
module MSFLVisitors
  module Nodes
    class Iterator < Base

      attr_accessor :set

      # Be extra defensive, because even after adding previous comment I still tend to make the mistake of
      # passing in an array.
      #
      # @param set [MSFLVisitors::Nodes::Set::Set] a set node that allows its elements to be iterated over
      def initialize(set)
        unless set.is_a? MSFLVisitors::Nodes::Set::Set
          fail ArgumentError, "Argument to Iterator initialize must be instance of MSFLVisitors::Nodes::Set::Set"
        end
        self.set = set
      end

      def ==(other)
        self.class == other.class &&
            set == other.set
      end
    end
  end
end