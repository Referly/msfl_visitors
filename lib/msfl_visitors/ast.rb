module MSFLVisitors
  class AST

    attr_accessor :root

    def initialize(obj, parser = MSFLVisitors::Parsers::MSFLParser.new)
      self.root = parser.parse obj
    end

    # Use this method to walk the AST with a particular visitor
    def accept(visitor)
      root.accept visitor
    end

    def ==(other)
      self.class == other.class &&
          root == other.root
    end
  end
end