module MSFLVisitors
  class Visitor
    def initialize(collector, renderer)
      @collector = collector
      @renderer = renderer
    end

    def visit(obj)
      collector << renderer.render(obj)
    end

    private

    attr_reader :collector, :renderer
  end
end
