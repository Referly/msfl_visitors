module MSFLVisitors
  module Collectors
    module Chewy
      class Aggregations < Hash

        attr_accessor :stack

        def push(obj)
          self.stack ||= Array.new
          self.stack.push obj
        end

        def pop
          self.stack ||= Array.new
          self.stack.pop
        end
      end
    end
  end
end