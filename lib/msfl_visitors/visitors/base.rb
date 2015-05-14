module MSFLVisitors
  module Visitors
    class Base
      # @mattvanhorn we can look at moving these to protected
      attr_reader :collector, :renderer

      def initialize(collector, renderer)
        @collector = collector
        @renderer = renderer
      end

      def visit(obj)
        return false unless supported_node?(obj)
        collector << renderer.render(obj)
      end

      # True if the visitor can handle visiting the node
      #
      # @param node [MSFLVisitors::Nodes::Base] a node to check to see if it is supported by the visitor
      # @return [Boolean] true if the visitor can handle visiting the node
      def supported_node?(node)
        fail NoMethodError, "Descendents of MSFLVisitors::Visitors::Base must implement #supported_nodes method"
      end
    end
  end
end