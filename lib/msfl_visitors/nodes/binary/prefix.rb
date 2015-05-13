module MSFLVisitors
  module Nodes
    module Binary
      module Prefix
        def accept(visitor)
          visitor.visit self
          left.accept visitor
          right.accept visitor
        end
      end
    end
  end
end