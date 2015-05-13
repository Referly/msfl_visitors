require_relative 'binary/binary'
require_relative 'binary/prefix'
module MSFLVisitors
  module Nodes
    class Partial < Binary::Binary
      include Binary::Prefix
    end
  end
end