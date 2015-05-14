require 'forwardable'
# require_relative 'collector'
require_relative 'renderers'
module MSFLVisitors
  class Visitor

    def visit(node)
      send node.class.name.split('::').reject{ |n| n == 'MSFLVisitors' }.unshift('visit').join('_'), node
    end

    def visit_Nodes_Equal(node)
      [{ clause: "#{node.left.accept(self)} == #{node.right.accept(self)}" }]
    end

    def visit_Nodes_Field(node)
      node.value.to_s
    end

    def visit_Nodes_Word(node)
      "\"#{node.value}\""
    end
  end
end
