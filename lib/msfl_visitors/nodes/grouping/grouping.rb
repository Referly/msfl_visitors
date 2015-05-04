require_relative 'close'
require_relative 'open'
module MSFLVisitors
  module Nodes
    module Grouping
      class Grouping

        attr_accessor :contents

        def accept(visitor)
          Open.new.accept visitor
          contents.accept visitor
          Close.new.accept visitor
        end

        # @param node [MSFL::Nodes::Base] the node that the grouping surrounds
        def initialize(node)
          self.contents = node
        end
      end
    end
  end
end