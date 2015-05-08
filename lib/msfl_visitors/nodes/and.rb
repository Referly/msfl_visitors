require_relative 'iterator'
module MSFLVisitors
  module Nodes
    class And < Iterator

      def accept(visitor)
        nodes = Array.new
        if items.count > 1
          items.each do |item|
            nodes << MSFLVisitors::Nodes::Grouping::Grouping.new(item)
            nodes << BinaryAnd.new
          end
          nodes.pop
        elsif items.count == 1
          nodes << items.first
        end

        nodes.each do |node|
          node.accept visitor
        end
      end
    end
  end
end