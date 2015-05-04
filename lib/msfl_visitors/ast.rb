module MSFLVisitors
  class AST

    attr_accessor :root

    def initialize(msfl)
      self.root = MSFLVisitors::Parsers::MSFLParser.parse msfl
    end
  end
end