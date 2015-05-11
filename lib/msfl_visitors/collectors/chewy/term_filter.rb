require 'delegate'

module MSFLVisitors
  module Collectors
    module Chewy
      class TermFilter < SimpleDelegator

        def initialize
          __setobj__(String.new)
        end

        def <<(obj)
          __getobj__ << (obj.to_s)
        end

      end
    end
  end
end