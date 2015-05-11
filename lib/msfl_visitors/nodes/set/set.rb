require_relative '../base'
module MSFLVisitors
  module Nodes
    module Set
      class Set < Base

        extend Forwardable

        attr_accessor :contents

        def_delegators :contents, :count, :first, :each

        def accept(visitor)
          nodes = Array.new
          nodes << Open.new
          if contents.count > 0
            contents.each do |item|
              nodes << item
              nodes << Delimiter.new
            end
            # Remove the last (and therefore extra) delimiter
            nodes.pop
          end
          nodes << Close.new

          nodes.each do |node|
            node.accept visitor
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
end