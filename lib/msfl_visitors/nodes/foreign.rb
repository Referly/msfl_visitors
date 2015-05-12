require_relative 'binary'
module MSFLVisitors
  module Nodes
    class Foreign < Binary
      # left is the dataset node
      # right is the filter node
    end
  end
end