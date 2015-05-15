require_relative 'msfl_visitors/nodes'
require_relative 'msfl_visitors/visitor'
require_relative 'msfl_visitors/parsers/msfl_parser'

module MSFLVisitors

  class << self
    def get_chewy_clauses(dataset, msfl)
      unless dataset.is_a? MSFL::Datasets::Base
        raise ArgumentError, "The first argument to MSFLVisitors.get_chewy_clauses must be a descendant of MSFL::Datasets::Base."
      end
      parser    = MSFLVisitors::Parsers::MSFLParser.new dataset
      converter = MSFL::Converters::Operator.new
      nmsfl     = converter.run_conversions msfl
      ast       = parser.parse nmsfl
      visitor   = MSFLVisitors::Visitor.new
      visitor.visit_tree ast
    end
  end
end