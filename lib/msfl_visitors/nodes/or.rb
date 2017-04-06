require_relative 'iterator'
require_relative 'value'
module MSFLVisitors
  module Nodes
    class Or < Iterator

      def initialize(set)
        super
        unless valid_set_children?
          fail ArgumentError, "Members of child Set node of Or node must be expressions, not values, only containment Set nodes have values as children."
        end
      end

      private
      def valid_set_children?
        set.each do |child|
          return false if child.is_a?(Value)
        end
      end
    end
  end
end