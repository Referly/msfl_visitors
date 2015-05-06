require_relative '../base'
module MSFLVisitors
  module Nodes
    module Set
      class Set < Base

        attr_accessor :contents

        def accept(visitor)
          Open.new.accept visitor
          contents.each do |item|
            item.accept visitor
          end
          Close.new.accept visitor
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
end