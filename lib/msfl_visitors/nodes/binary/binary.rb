require_relative '../base'
module MSFLVisitors
  module Nodes
    module Binary
      class Binary < Base
        attr_accessor :left, :right

        def initialize(left, right)
          self.left = left
          self.right = right
        end

        def ==(other)
          self.class == other.class &&
              self.left == other.left &&
              self.right == other.right
        end
      end
    end
  end
end