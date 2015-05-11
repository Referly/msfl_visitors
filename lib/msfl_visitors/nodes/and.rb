require_relative 'iterator'
module MSFLVisitors
  module Nodes
    class And < Iterator

      def accept(visitor)
        nodes = Array.new
        if set.count > 1
          set.each do |item|
            nodes << MSFLVisitors::Nodes::Grouping::Grouping.new(item)
            nodes << BinaryAnd.new
          end
          nodes.pop
        elsif set.count == 1
          nodes << set.first
        end

        nodes.each do |node|
          node.accept visitor
        end
      end
    end
  end
end