require 'delegate'
module MSFLVisitors
  module Collectors
    module Chewy
      class Aggregations < SimpleDelegator

        def initialize
          __setobj__(Array.new)
        end

        def contents
          __getobj__.map { |clause| {clause: clause } }
        end
      end
    end
  end
end