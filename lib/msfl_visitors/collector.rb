require_relative 'collectors'
module MSFLVisitors
  class Collector

    attr_accessor :collectors, :current_mode

    COLLECTOR_MODES = {
        Visitors::Chewy::Aggregations => :aggregations,
        Visitors::Chewy::TermFilter => :terms,
    }

    def initialize
      self.collectors = Hash.new
      self.current_mode = :terms
      collectors[:terms]          = MSFLVisitors::Collectors::Chewy::TermFilter.new
      collectors[:aggregations]   = MSFLVisitors::Collectors::Chewy::Aggregations.new
    end

    def <<(obj)
      collectors[current_mode] << obj
    end

    def next_clause!
      collectors[current_mode].next_clause!
    end

    def current_dataset=(dataset)
      collectors[current_mode].current_dataset = dataset
    end

    def set_visitor_mode(klass)
      self.current_mode = COLLECTOR_MODES[klass]
    end

    def contents
      string_collectors = [collectors[:terms]]
      all_clauses = []
      string_collectors.each do |c|
        all_clauses.concat c.contents
      end
      all_clauses
    end

    def push(obj)
      collectors[current_mode].push obj
    end

    def pop
      collectors[current_mode].pop
    end
  end
end