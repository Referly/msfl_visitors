module MSFLVisitors
  module Collectors
    module Chewy
      class TermFilter
        attr_accessor :clauses, :current_clause_wrapper, :current_clause, :current_dataset

        def initialize
          self.clauses = Array.new
          new_clause
        end

        def <<(obj)
          current_clause << (obj.to_s)
        end

        def next_clause!
          new_clause
          delete_empty_clauses
        end

        def current_dataset=(dataset)
          @current_dataset = dataset
          self.current_clause_wrapper[:dataset] = dataset
        end

        # Creates a new Array containing clauses and the current clause without modifying the
        # clauses object.
        #
        # Example return value
        #  => [{clause: "make == \"Honda\""}]
        #
        #  => [{clause: "make == \"Honda\""},{clause: "age == 25", dataset: "person"}]
        #
        # @return [Array<Hash>] an Array of Hashes each having a key of :clause which contains the actual string and optional
        #  key of :dataset, which if present indicates an explicit dataset that the clause references
        def contents
          all_clauses = [].concat @clauses
          if current_clause_wrapper
            all_clauses << current_clause_wrapper unless current_clause.empty?
          end
          all_clauses
        end

      private

        def new_clause
          if current_clause_wrapper
            clauses << current_clause_wrapper unless current_clause.empty?
          end
          self.current_clause_wrapper = Hash.new
          self.current_clause = Simple.new
          self.current_clause_wrapper[:clause] = current_clause
        end

        # This is pretty lousy behavior as the number of clauses grows because we keep rechecking the early
        # clauses even though they can't have changed. Tolerable for now as the number of clauses is a relatively
        # small number for foreseeable scenarios.
        def delete_empty_clauses
          clauses.select { |c| c[:clause] == "" }.each { |c| clauses.delete c }
        end
      end
    end
  end
end