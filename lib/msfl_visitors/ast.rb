module MSFLVisitors
  class AST

    attr_accessor :root

    def initialize(msfl)
      self.root = MSFLVisitors::Parsers::MSFLParser.build_ast msfl
    end
  end
end