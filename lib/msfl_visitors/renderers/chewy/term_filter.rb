module MSFLVisitors
  module Renderers
    module Chewy
      class TermFilter
        BINARY_OPERATORS = {
          Nodes::GreaterThan      => ' > ',
          Nodes::LessThan         => ' < ',
          Nodes::GreaterThanEqual => ' >= ',
          Nodes::LessThanEqual    => ' <= ',
          Nodes::Equal            => ' == ',
        }

        ITERATIVE_OPERATORS = {
            Nodes::And            => ' & ',
        }

        def render(node)
          case node

          when Nodes::Comparison
            BINARY_OPERATORS[node.class]

          when Nodes::Iterator
            ITERATIVE_OPERATORS[node.class]

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

          when Nodes::Set::Close
            ' ]'

          when Nodes::Set::Delimiter
            ', '

          when Nodes::Set::Open
            '[ '

          else
            fail ArgumentError.new("Unrecognized node type: #{node.class}")
          end
        end
      end
    end
  end
end
