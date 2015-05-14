module MSFLVisitors
  module Visitors
    module Chewy
      class TermFilter < Base
        def visit(obj)
          # Only override behavior for nodes when the Collector's or Renderer's behavior needs to be adapted based on the
          # encountered node type
          #
          # Leave actual rendering to the renderer
          case obj
            when Nodes::ExplicitFilter
              collector.next_clause!

            when Nodes::Dataset
              collector.current_dataset = renderer.render(obj)
              return
          end
          collector << renderer.render(obj)
        end
      end
    end
  end
end