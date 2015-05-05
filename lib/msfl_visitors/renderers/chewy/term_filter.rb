module MSFLVisitors
  module Renderers
    module Chewy
      class TermFilter
        BINARY_OPERATORS = {
          Nodes::And              => ' & ',
          Nodes::GreaterThan      => ' > ',
          Nodes::LessThan         => ' < ',
          Nodes::GreaterThanEqual => ' >= ',
          Nodes::LessThanEqual    => ' <= ',
          Nodes::Equal            => ' == ',
        }

        def render(node)
          case node

          when Nodes::Comparison, Nodes::And
            BINARY_OPERATORS[node.class]

          when Nodes::Date, Nodes::Time
            node.value.iso8601

          when Nodes::Boolean, Nodes::Number
            node.value

          when Nodes::Field
            node.value.to_s

          when Nodes::Word
            %("#{node.value.to_s}")

          when Nodes::Grouping::Close
            ' )'

          when Nodes::Grouping::Open
            '( '

          else
            fail ArgumentError.new("Unrecognized node type: #{node.class}")
          end
        end
      end
    end
  end
end
