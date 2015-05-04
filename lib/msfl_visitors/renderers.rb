require_relative 'renderers/renderer'
require_relative 'renderers/render_binary'
require_relative 'renderers/render_constant'
require_relative 'renderers/render_string_value'
require_relative 'renderers/render_temporal'
require_relative 'renderers/render_value'

module MSFLVisitors
  module Renderers
    def Renderers.wrap_node(node)
      case node

      when Nodes::Comparison, Nodes::And
        RenderBinary.new(node)

      when Nodes::Date, Nodes::Time
        RenderTemporal.new(node)

      when Nodes::Boolean, Nodes::Number
        RenderValue.new(node)

      when Nodes::Word
        RenderStringValue.new(node)

      when Nodes::Grouping::Close
        RenderConstant.new(' )')

      when Nodes::Grouping::Open
        RenderConstant.new('( ')

      else
        fail ArgumentError.new("Unrecognized node type: #{node.class}")
      end
    end
  end
end