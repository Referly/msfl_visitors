require 'delegate'

module MSFLVisitors
  module Collectors
    class Simple < SimpleDelegator

      def initialize
        __setobj__(String.new)
      end

      def <<(obj)
        __getobj__ << (obj.to_s)
      end

    end
  end
end