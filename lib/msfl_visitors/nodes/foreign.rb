require_relative 'binary/binary'
require_relative 'binary/prefix'
module MSFLVisitors
  module Nodes
    class Foreign < Binary::Binary
      include Binary::Prefix
    end
  end
end