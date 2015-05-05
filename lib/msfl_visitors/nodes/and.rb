require_relative 'iterator'
module MSFLVisitors
  module Nodes
    class And < Iterator

      def accept(visitor)
        unless items.empty?
          items.inject(1) do |iteration, item|
            if iteration < items.count
              MSFLVisitors::Nodes::Grouping::Grouping.new(item).accept visitor
              visitor.visit self
            end
            iteration + 1
          end
          if items.count > 1
            MSFLVisitors::Nodes::Grouping::Grouping.new(items.last).accept(visitor)
          else
            items.last.accept visitor
          end
        end
      end
    end
  end
end