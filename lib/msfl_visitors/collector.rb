require_relative 'collectors'
module MSFLVisitors
  class Collector

    attr_accessor :terms_collector

    def initialize
      self.terms_collector = MSFLVisitors::Collectors::Chewy::TermFilter.new
    end

    def <<(obj)
      terms_collector << obj
    end

    def next_clause!
      terms_collector.next_clause!
    end

    def current_dataset=(dataset)
      terms_collector.current_dataset = dataset
    end

    def contents
      collectors = [terms_collector]
      all_clauses = []
      collectors.each do |c|
        all_clauses.concat c.contents
      end
      all_clauses
    end
  end
end