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
        Visitors::Aggregations,
        Visitors::Chewy::TermFilter,
    ]

    RENDERERS = {
        Visitors::Aggregations => MSFLVisitors::Renderers::Chewy::TermFilter,
        Visitors::Chewy::TermFilter => MSFLVisitors::Renderers::Chewy::TermFilter,
    }

    def initialize(visitors = {})
      # self.aggregations_visitor   = self.class.visitor_factory deps[:aggregations_visitor]
      self.collector        = Collector.new
      self.terms_visitor    = visitor_factory visitors[:terms_visitor]
    end

    def visit(obj)
      terms_visitor.visit obj
    end

  private
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
