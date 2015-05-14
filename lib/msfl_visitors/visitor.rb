require 'forwardable'
require_relative 'visitors'
require_relative 'collector'
require_relative 'renderers'
module MSFLVisitors
  class Visitor
    extend Forwardable

    attr_accessor :aggregations_visitor, :terms_visitor, :collector

    def_delegators :collector, :contents

    VISITORS = [
        Visitors::Chewy::Aggregations,
        Visitors::Chewy::TermFilter,
    ]

    RENDERERS = {
        Visitors::Chewy::Aggregations => MSFLVisitors::Renderers::Chewy::Aggregations,
        Visitors::Chewy::TermFilter => MSFLVisitors::Renderers::Chewy::TermFilter,
    }

    def initialize(visitors = {})
      self.collector                = Collector.new
      self.aggregations_visitor     = visitor_factory visitors[:aggregations_visitor]
      self.terms_visitor            = visitor_factory visitors[:terms_visitor]
      self.current_visitor          = terms_visitor
    end

    # @TODO add spec that verifies behavior when none of the visitors support a node type
    def visit(obj)
      if current_visitor.supported_node? obj
        current_visitor.visit(obj)
      else
        visitors = [aggregations_visitor, terms_visitor]
        next_visitor = visitors.select { |v| v.supported_node? obj }.first
        fail ArgumentError, "Node type is not supported by any visitor" unless next_visitor
        self.current_visitor = next_visitor
        visit(obj)
      end
    end

  private
    attr_accessor :current_visitor

    # Pass in a supported Visitors Class (the actual class constant) a newly created instance is returned
    #
    # @param klass [Class] this should be the class that you want to use to generate
    #  a new visitor instance of that type
    # @return [MSFLVisitors::Visitors::Base] the visitor instance
    #
    def visitor_factory(klass)
      klass.new(collector, RENDERERS[klass].new) if VISITORS.include?(klass)
    end
  end
end
