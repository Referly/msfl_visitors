module MSFLVisitors
  class AST

    attr_accessor :root

    def initialize(msfl)
      self.root = MSFLVisitors::Parsers::MSFLParser.parse msfl
    end

    # Use this method to walk the AST with a particular visitor
    def accept(visitor)
      root.accept visitor
    end
  end
end