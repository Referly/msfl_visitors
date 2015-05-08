module MSFLVisitors
  module Collectors
    module Chewy
      class TermFilter < String

        def <<(obj)
          super(obj.to_s)
        end
      end
    end
  end
end