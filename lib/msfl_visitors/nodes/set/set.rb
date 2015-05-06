require_relative '../base'
module MSFLVisitors
  module Nodes
    module Set
      class Set < Base

        attr_accessor :contents

        def accept(visitor)
          # I've basically used this same iteration logic here and in Nodes::And
          # 1. It could be deduplicated
          # 2. It's rather unrubyish - despite not using a loop explicitly that's basically what's happening
          Open.new.accept visitor
          contents.inject(1) do |iteration, item|
            if iteration < contents.count
              if iteration > 1
                Delimiter.new.accept visitor
              end
              item.accept visitor
            end
            iteration + 1
          end
          if contents.count > 1
            Delimiter.new.accept visitor
          end
          contents.last.accept visitor
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