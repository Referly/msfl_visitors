require_relative 'set/set'
module MSFLVisitors
  module Nodes
    class Filter < Set::Set
      # def accept(visitor)
      #   nodes = Array.new
      #   if contents.count > 0
      #     contents.each do |item|
      #       nodes << item
      #       nodes << Set::Delimiter.new
      #     end
      #     # Remove the last (and therefore extra) delimiter
      #     nodes.pop
      #   end
      #   nodes.each do |node|
      #     node.accept visitor
      #   end
      # end
    end
  end
end