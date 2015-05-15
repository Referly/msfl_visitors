require_relative 'msfl_visitors/ast'
require_relative 'msfl_visitors/nodes'
require_relative 'msfl_visitors/visitor'
require_relative 'msfl_visitors/parsers/msfl_parser'

module MSFLVisitors

  class << self
    def get_chewy_clauses(dataset, nmsfl)
      parser    = MSFLVisitors::Parsers::MSFLParser.new dataset
      ast       = parser.parse nmsfl
      visitor   = MSFLVisitors::Visitor.new
      visitor.visit_tree ast
    end
  end
end