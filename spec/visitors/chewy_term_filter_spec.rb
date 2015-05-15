require 'spec_helper'

describe MSFLVisitors::Visitor do

  let(:node) { fail ArgumentError, "You must define the node variable in each scope." }

  let(:visitor) { described_class.new }

  let(:left) { MSFLVisitors::Nodes::Field.new "lhs" }

  let(:right) { MSFLVisitors::Nodes::Word.new "rhs" }

  subject(:result) { node.accept visitor }

  context "when visiting" do

    # chewy looks like
    # Index::Type.filter { match_all }.aggregations({toyotas: {terms: {make: 'Toyota'}, aggregations: { filter: { range: { avg_age: { gt: 10 }}} }}})
    describe "a Partial node" do

      let(:node)                    { MSFLVisitors::Nodes::Partial.new given_node, named_value }

        let(:given_node)              { MSFLVisitors::Nodes::Given.new [given_equal_node] }

          let(:given_equal_node)        { MSFLVisitors::Nodes::Equal.new given_field_node, given_value_node }

          let(:given_field_node)          { MSFLVisitors::Nodes::Field.new :make }

            let(:given_value_node)        { MSFLVisitors::Nodes::Word.new "Toyota" }


      let(:named_value)    { MSFLVisitors::Nodes::NamedValue.new MSFLVisitors::Nodes::Word.new("partial"), explicit_filter_node }

        let(:explicit_filter_node)    { MSFLVisitors::Nodes::ExplicitFilter.new [greater_than_node] }

            let(:greater_than_node)              { MSFLVisitors::Nodes::GreaterThan.new field_node, value_node }

              let(:field_node)              { MSFLVisitors::Nodes::Field.new :age }

              let(:value_node)              { MSFLVisitors::Nodes::Number.new 10 }


      subject { visitor.visit_tree node }

      it "results in the appropriate aggregation clause" do
        exp = [{
                   clause: {
                       given: {
                           filter: {
                               term: { make: "Toyota" }
                           },
                           aggs: {
                               partial: {
                                   filter: { range: { age: { gt: 10 }}}
                               }
                           }
                       }
                   },
                   method_to_execute: :aggregations
               }]
        visitor.mode = :aggregations
        expect(subject).to eq exp
      end
    end

    describe "a Given node" do

      let(:node)                    { MSFLVisitors::Nodes::Given.new [given_equal_node] }

        let(:given_equal_node)        { MSFLVisitors::Nodes::Equal.new given_field_node, given_value_node }

          let(:given_field_node)        { MSFLVisitors::Nodes::Field.new :make }

          let(:given_value_node)        { MSFLVisitors::Nodes::Word.new "Toyota" }


      it "results in: [:filter, { term: { make: \"Toyota\" } }]" do
        visitor.mode = :aggregations
        expect(subject).to eq([:filter, { term: { make: "Toyota" } }])
      end
    end

    describe "a Foreign node" do

      let(:node) { MSFLVisitors::Nodes::Foreign.new dataset_node, filter_node }

      let(:dataset_node) { MSFLVisitors::Nodes::Dataset.new "person" }

      let(:filter_node) { MSFLVisitors::Nodes::ExplicitFilter.new [equal_node] }

      let(:equal_node) { MSFLVisitors::Nodes::Equal.new left, right }

      let(:left) { MSFLVisitors::Nodes::Field.new :age }

      let(:right) { MSFLVisitors::Nodes::Number.new 25 }

      context "when using the TermFilter visitor" do

        it "results in: 'has_child( :person ).filter { age == 25 }" do
          expect(subject).to eq "has_child( :person ).filter { age == 25 }"
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it "results in: { has_child: { type: \"person\", filter: { term: { age: 25 } } } }" do
          expect(subject).to eq({ has_child: { type: "person", filter: { term: { age: 25 } } } })
        end
      end
    end

    describe "a Containment node" do

      let(:node) { MSFLVisitors::Nodes::Containment.new field, values }

      let(:values) { MSFLVisitors::Nodes::Set::Set.new(MSFL::Types::Set.new([item_one, item_two, item_three])) }

      let(:item_one) { MSFLVisitors::Nodes::Word.new "item_one" }

      let(:item_two) { MSFLVisitors::Nodes::Word.new "item_two" }

      let(:item_three) { MSFLVisitors::Nodes::Word.new "item_three" }

      let(:field)  { left }

      context "when using the TermFilter visitor" do

        it "results in: 'lhs == [ \"item_one\", \"item_two\", \"item_three\" ]'" do
          expect(subject).to eq "lhs == [ \"item_one\" , \"item_two\" , \"item_three\" ]"
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it "results in: { terms: { lhs: [\"item_one\", \"item_two\", \"item_three\"] } }" do
          expect(subject).to eq({ terms: { lhs: ["item_one", "item_two", "item_three"] } })
        end
      end
    end

    describe "a Set node" do

      let(:node) { MSFLVisitors::Nodes::Set::Set.new values }

      let(:values) { MSFL::Types::Set.new([item_one, item_two]) }

      let(:item_one) { MSFLVisitors::Nodes::Word.new "item_one" }

      let(:item_two) { MSFLVisitors::Nodes::Word.new "item_two" }

      context "when using the TermFilter visitor" do

        it "results in: '[ \"item_one\" , \"item_two\" ]'" do
          expect(result).to eq "[ \"item_one\" , \"item_two\" ]"
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it "results in: [\"item_one\", \"item_two\"]" do
          expect(result).to eq ["item_one", "item_two"]
        end
      end
    end

    describe "an Equal node" do

      let(:node) { MSFLVisitors::Nodes::Equal.new left, right }

      context "when the current visitor is Chewy::TermFilter" do

        it "results in: 'left == right'" do
          expect(result).to eq "lhs == \"rhs\""
        end
      end

      context "when the current visitor is Chewy::Aggregations" do

        before { visitor.mode = :aggregations }

        it "results in: { term: { lhs: \"rhs\" } }" do
          expect(result).to eq({ term: { lhs: "rhs" } })
        end
      end
    end

    describe "a GreaterThan node" do

      let(:node) { MSFLVisitors::Nodes::GreaterThan.new left, right }

      let(:right) { MSFLVisitors::Nodes::Number.new 1000 }

      context "when using the TermFilter visitor" do

        it "returns: 'left > 1000'" do
          expect(result).to eq "lhs > 1000"
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it "results in: { range: { lhs: { gt: 1000 } } }" do
          expect(result).to eq({ range: { lhs: { gt: 1000 } } })
        end
      end
    end

    describe "a GreaterThanEqual node" do

      let(:node) { MSFLVisitors::Nodes::GreaterThanEqual.new left, right }

      let(:right) { MSFLVisitors::Nodes::Number.new 10.52 }

      context "when using the TermFilter visitor" do

        it "returns: 'left >= 10.52'" do
          expect(result).to eq "lhs >= 10.52"
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it "results in: { range: { lhs: { gte: 10.52 } } }" do
          expect(result).to eq({ range: { lhs: { gte: 10.52 } } })
        end
      end
    end

    describe "a LessThan node" do

      let(:node) { MSFLVisitors::Nodes::LessThan.new left, right }

      let(:right) { MSFLVisitors::Nodes::Number.new 133.7 }

      context "when using the TermFilter visitor" do

        it "returns: 'left < 133.7'" do
          expect(result).to eq 'lhs < 133.7'
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it "returns: { range: { lhs: { lt: 133.7 } } }" do
          expect(result).to eq({ range: { lhs: { lt: 133.7 } } })
        end
      end
    end

    describe "a LessThanEqual node" do

      let(:node) { MSFLVisitors::Nodes::LessThanEqual.new left, right }

      let(:right) { MSFLVisitors::Nodes::Date.new Date.today }

      context "when using the TermFilter visitor" do

        it "returns: 'left <= \"#{Date.today}\"'" do
          expect(result).to eq "lhs <= \"#{Date.today}\""
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it "returns: { range: { lhs: { lte: \"#{Date.today}\" } } }" do
          expect(result).to eq({ range: { lhs: { lte: "#{Date.today}" } } })
        end
      end
    end

    describe "an And node" do

      let(:first_field) { MSFLVisitors::Nodes::Field.new "first_field" }

      let(:first_value) { MSFLVisitors::Nodes::Word.new "first_word" }

      let(:first) { MSFLVisitors::Nodes::Equal.new(first_field, first_value) }

      let(:second_field) { MSFLVisitors::Nodes::Field.new "second_field" }

      let(:second_value) { MSFLVisitors::Nodes::Word.new "second_word" }

      let(:second) { MSFLVisitors::Nodes::Equal.new(second_field, second_value) }

      let(:third_field) { MSFLVisitors::Nodes::Field.new "third_field" }

      let(:third_value) { MSFLVisitors::Nodes::Word.new "third_word" }

      let(:third) { MSFLVisitors::Nodes::Equal.new(third_field, third_value) }

      let(:node) { MSFLVisitors::Nodes::And.new(set_node) }

      context "when the And node has zero items" do

        let(:set_node) { MSFLVisitors::Nodes::Set::Set.new [] }

        context "when using the TermFilter visitor" do

          it "is empty" do
            expect(result).to be_empty
          end
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: { and: [] }" do
            expect(result).to eq({ and: [] })
          end
        end
      end

      context "when the node has one item" do

        let(:set_node) { MSFLVisitors::Nodes::Set::Set.new [first] }

        context "when using the TermFilter visitor" do

          it "returns: the item without adding parentheses" do
            expect(result).to eq 'first_field == "first_word"'
          end
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: { and: [{ term: { first_field: \"first_word\" }] }" do
            expect(result).to eq({ and: [{ term: { first_field: "first_word" } }] })
          end
        end
      end

      context "when the node has two items" do

        let(:set_node) { MSFLVisitors::Nodes::Set::Set.new [first, second] }

        context "when using the TermFilter visitor" do

          it "returns: '( first_field == \"first_word\" ) & ( second_field == \"second_word\" )'" do
            expect(result).to eq '( first_field == "first_word" ) & ( second_field == "second_word" )'
          end
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: { and: [{ term: { first_field: \"first_word\" } },{ term: { second_field: \"second_word\" } }] }" do
            expect(result).to eq({ and: [{ term: { first_field: "first_word" }}, { term: { second_field: "second_word" } }] })
          end
        end
      end

      context "when the node has three items" do

        let(:set_node) { MSFLVisitors::Nodes::Set::Set.new [first, second, third] }

        context "when using the TermFilter visitor" do

          it "returns: '( first_field == \"first_word\" ) & ( second_field == \"second_word\" ) & ( third_field == \"third_word\" )'" do
            expect(result).to eq '( first_field == "first_word" ) & ( second_field == "second_word" ) & ( third_field == "third_word" )'
          end
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: { and: [{ term: { first_field: \"first_word\" } },{ term: { second_field: \"second_word\" } },{ term: { third_field: \"third_word\" } }] }" do
            expect(result).to eq({ and: [{ term: { first_field: "first_word" } },{ term: { second_field: "second_word" } },{ term: { third_field: "third_word" } }] })
          end
        end
      end

      context "when one of the node's items is a containment node" do

        let(:node) do
          MSFLVisitors::Nodes::And.new(
              MSFLVisitors::Nodes::Set::Set.new(
                  [
                      MSFLVisitors::Nodes::Filter.new(
                          [
                              MSFLVisitors::Nodes::Containment.new(
                                  MSFLVisitors::Nodes::Field.new(:make),
                                  MSFLVisitors::Nodes::Set::Set.new(
                                      [
                                          MSFLVisitors::Nodes::Word.new("Honda"),
                                          MSFLVisitors::Nodes::Word.new("Chevy"),
                                          MSFLVisitors::Nodes::Word.new("Volvo")
                                      ]
                                  )
                              )
                          ]
                      ),
                      MSFLVisitors::Nodes::Filter.new(
                          [
                              MSFLVisitors::Nodes::GreaterThanEqual.new(
                                  MSFLVisitors::Nodes::Field.new(:value),
                                  MSFLVisitors::Nodes::Number.new(1000)
                              )
                          ]
                      )
                  ]
              )
          )
        end

        context "when using the TermFilter visitor" do

          it "returns: '( make == [ \"Honda\" , \"Chevy\" , \"Volvo\" ] ) & ( value >= 1000 )'" do
            expect(result).to eq '( make == [ "Honda" , "Chevy" , "Volvo" ] ) & ( value >= 1000 )'
          end
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: { and: [{ terms: { make: [\"Honda\",\"Chevy\",\"Volvo\"]} }, { range: { value: { gte: 1000 } } }] }" do
            expected = { and: [{ terms: { make: ["Honda", "Chevy", "Volvo"]} }, { range: { value: { gte: 1000 } } }] }
            expect(result).to eq expected
          end
        end
      end
    end

    describe "value nodes" do
      describe "a Boolean node" do

        let(:node) { MSFLVisitors::Nodes::Boolean.new value }

        subject(:result) { node.accept visitor }

        context "with a value of true" do

          let(:value) { true }

          context "when using the TermFilter visitor" do

            it "returns: true" do
              expect(result).to eq true
            end
          end

          context "when using the Aggregations visitor" do

            before { visitor.mode = :aggregations }

            it "returns: true" do
              expect(result).to eq true
            end
          end
        end

        context "with a value of false" do

          let(:value) { false }

          it "returns: false" do
            expect(result).to eq false
          end

          context "when using the Aggregations visitor" do

            before { visitor.mode = :aggregations }

            it "returns: false" do
              expect(result).to eq false
            end
          end
        end
      end

      describe "a Word node" do

        let(:word) { "node_content" }

        let(:node) { MSFLVisitors::Nodes::Word.new word }

        it "is a double quoted literal string" do
          expect(result).to eq "\"#{word}\""
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: the literal string" do
            expect(result).to eq "#{word}"
          end
        end
      end
    end

    describe "range value nodes" do

      subject(:result) { node.accept visitor }

      describe "a Date node" do

        let(:today) { Date.today }

        let(:node) { MSFLVisitors::Nodes::Date.new today }

        it "returns: the date using iso8601 formatting" do
          expect(result).to eq "\"#{today.iso8601}\""
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: the date using iso8601 formatting" do
            expect(result).to eq "#{today.iso8601}"
          end
        end
      end

      describe "a Time node" do

        let(:now) { Time.now }

        let(:node) { MSFLVisitors::Nodes::Time.new now }

        it "returns: the time using iso8601 formatting" do
          expect(result).to eq "\"#{now.iso8601}\""
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: the date using iso8601 formatting" do
            expect(result).to eq "#{now.iso8601}"
          end
        end
      end

      describe "a DateTime node" do

        let(:now) { DateTime.now }

        let(:node) { MSFLVisitors::Nodes::DateTime.new now }

        it "returns: the date and time using iso8601 formatting" do
          expect(result).to eq "\"#{now.iso8601}\""
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: the date and time using iso8601 formatting" do
            expect(result).to eq "#{now.iso8601}"
          end
        end
      end

      describe "a Number node" do

        let(:number) { 123 }

        let(:node) { MSFLVisitors::Nodes::Number.new number }

        it "returns: 123" do
          expect(result).to eq number
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: 123" do
            expect(result).to eq number
          end
        end

        context "when the number is a float" do

          let(:number) { 123.456 }

          it "returns: the number with the same precision" do
            expect(result).to eq number
          end

          context "when using the Aggregations visitor" do

            before { visitor.mode = :aggregations }

            it "returns: the number with the same precision" do
              expect(result).to eq number
            end
          end
        end
      end
    end
  end
end