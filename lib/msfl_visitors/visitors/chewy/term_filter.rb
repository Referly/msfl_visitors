require_relative '../base'
module MSFLVisitors
  module Visitors
    module Chewy
      class TermFilter < Base

        SUPPORTED_NODES = [

            Nodes::Grouping::Grouping,
            Nodes::Grouping::Close,
            Nodes::Grouping::Open,
            Nodes::Set::Close,
            Nodes::Set::Delimiter,
            Nodes::Set::Open,
            Nodes::Set::Set,

            Nodes::And,
            Nodes::BinaryAnd,
            Nodes::Boolean,
            Nodes::Comparison,
            Nodes::Containment,
            Nodes::Dataset,
            Nodes::Date,
            Nodes::DateTime,
            Nodes::Equal,
            Nodes::ExplicitFilter,
            Nodes::Field,
            Nodes::Filter,
            Nodes::Foreign,
            Nodes::GreaterThan,
            Nodes::GreaterThanEqual,
            Nodes::LessThan,
            Nodes::LessThanEqual,
            Nodes::Number,
            Nodes::Time,
            Nodes::Word,

        ]

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
          super
        end

        def supported_node?(node)
          SUPPORTED_NODES.include? node.class
        end
      end
    end
  end
end