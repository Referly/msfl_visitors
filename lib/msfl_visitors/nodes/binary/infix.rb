module MSFLVisitors
  module Nodes
    module Binary
      module Infix
        def accept(visitor)
          left.accept visitor
          visitor.visit self
          right.accept visitor
        end
      end
    end
  end
end