require 'spec_helper'

describe MSFLVisitors::Visitor do

  let(:node) { fail ArgumentError, "You must define the node variable in each scope." }

  let(:visitor) { described_class.new }

  let(:left) { MSFLVisitors::Nodes::Field.new "lhs" }

  let(:right) { MSFLVisitors::Nodes::Word.new "rhs" }

  subject(:result) { node.accept visitor }

  context "when using the ESTermFilter visitor" do

    before { visitor.mode = :es_term }

    context "when visiting" do

      describe "an unsupported node" do

        class UnsupportedNode

          def accept(visitor)
            visitor.visit self
          end
        end

        let(:node) { UnsupportedNode.new }

          it "raises an ArgumentError" do
            expect { subject }.to raise_error ArgumentError
          end
      end

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

        it "results in the appropriate clause" do
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
                     }
                 }]
          expect(subject).to eq exp
        end
      end

      describe "a Given node" do

        let(:node)                    { MSFLVisitors::Nodes::Given.new [given_equal_node] }

        let(:given_equal_node)        { MSFLVisitors::Nodes::Equal.new given_field_node, given_value_node }

        let(:given_field_node)        { MSFLVisitors::Nodes::Field.new :make }

        let(:given_value_node)        { MSFLVisitors::Nodes::Word.new "Toyota" }


        it "results in: [:filter, { term: { make: \"Toyota\" } }]" do
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

        it "results in: { has_child: { type: \"person\", filter: { term: { age: 25 } } } }" do
          expect(subject).to eq({ has_child: { type: "person", filter: { term: { age: 25 } } } })
        end
      end

      describe "a Containment node" do

        let(:node) { MSFLVisitors::Nodes::Containment.new field, values }

        let(:values) { MSFLVisitors::Nodes::Set.new(MSFL::Types::Set.new([item_one, item_two, item_three])) }

        let(:item_one) { MSFLVisitors::Nodes::Word.new "item_one" }

        let(:item_two) { MSFLVisitors::Nodes::Word.new "item_two" }

        let(:item_three) { MSFLVisitors::Nodes::Word.new "item_three" }

        let(:field)  { left }

        it "results in: { terms: { lhs: [\"item_one\", \"item_two\", \"item_three\"] } }" do
          expect(subject).to eq({ terms: { lhs: ["item_one", "item_two", "item_three"] } })
        end
      end

      describe "a Set node" do

        let(:node) { MSFLVisitors::Nodes::Set.new values }

        let(:values) { MSFL::Types::Set.new([item_one, item_two]) }

        let(:item_one) { MSFLVisitors::Nodes::Word.new "item_one" }

        let(:item_two) { MSFLVisitors::Nodes::Word.new "item_two" }

        it "results in: [\"item_one\", \"item_two\"]" do
          expect(result).to eq ["item_one", "item_two"]
        end
      end

      describe "an Equal node" do

        let(:node) { MSFLVisitors::Nodes::Equal.new left, right }

        it "results in: { term: { lhs: \"rhs\" } }" do
          expect(result).to eq({ term: { lhs: "rhs" } })
        end
      end

      describe "a GreaterThan node" do

        let(:node) { MSFLVisitors::Nodes::GreaterThan.new left, right }

        let(:right) { MSFLVisitors::Nodes::Number.new 1000 }

        it "results in: { range: { lhs: { gt: 1000 } } }" do
          expect(result).to eq({ range: { lhs: { gt: 1000 } } })
        end
      end

      describe "a GreaterThanEqual node" do

        let(:node) { MSFLVisitors::Nodes::GreaterThanEqual.new left, right }

        let(:right) { MSFLVisitors::Nodes::Number.new 10.52 }

        it "results in: { range: { lhs: { gte: 10.52 } } }" do
          expect(result).to eq({ range: { lhs: { gte: 10.52 } } })
        end
      end

      describe "a LessThan node" do

        let(:node) { MSFLVisitors::Nodes::LessThan.new left, right }

        let(:right) { MSFLVisitors::Nodes::Number.new 133.7 }

        it "returns: { range: { lhs: { lt: 133.7 } } }" do
          expect(result).to eq({ range: { lhs: { lt: 133.7 } } })
        end
      end

      describe "a LessThanEqual node" do

        let(:node) { MSFLVisitors::Nodes::LessThanEqual.new left, right }

        let(:right) { MSFLVisitors::Nodes::Date.new Date.today }

        it "returns: { range: { lhs: { lte: \"#{Date.today}\" } } }" do
          expect(result).to eq({ range: { lhs: { lte: "#{Date.today}" } } })
        end
      end

      describe "a Filter node" do

        let(:node) { MSFLVisitors::Nodes::Filter.new filtered_nodes }

        let(:filtered_nodes) do
          [
              MSFLVisitors::Nodes::GreaterThanEqual.new(
                  MSFLVisitors::Nodes::Field.new(:value),
                  MSFLVisitors::Nodes::Number.new(1000))
          ]
        end

        it "returns: { range: { value: { gte: 1000 } } }" do
          expect(result).to eq({ range: { value: { gte: 1000 } } })
        end

        context "when the filter has multiple children" do

          let(:filtered_nodes) do
            [
                MSFLVisitors::Nodes::Equal.new(
                    MSFLVisitors::Nodes::Field.new(:make),
                    MSFLVisitors::Nodes::Word.new("Chevy")
                ),
                MSFLVisitors::Nodes::GreaterThanEqual.new(
                    MSFLVisitors::Nodes::Field.new(:value),
                    MSFLVisitors::Nodes::Number.new(1000))
            ]
          end

          it "returns: { and: [{ term: { make: \"Chevy\" } },{ range: { value: { gte: 1000 } } }] }" do
            expect(result).to eq({ and: [{ term: { make: "Chevy" } },{ range: { value: { gte: 1000 } } }] })
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

          let(:set_node) { MSFLVisitors::Nodes::Set.new [] }

          it "returns: { and: [] }" do
            expect(result).to eq({ and: [] })
          end
        end

        context "when the node has one item" do

          let(:set_node) { MSFLVisitors::Nodes::Set.new [first] }

          it "returns: { and: [{ term: { first_field: \"first_word\" }] }" do
            expect(result).to eq({ and: [{ term: { first_field: "first_word" } }] })
          end
        end

        context "when the node has two items" do

          let(:set_node) { MSFLVisitors::Nodes::Set.new [first, second] }

          it "returns: { and: [{ term: { first_field: \"first_word\" } },{ term: { second_field: \"second_word\" } }] }" do
            expect(result).to eq({ and: [{ term: { first_field: "first_word" }}, { term: { second_field: "second_word" } }] })
          end
        end

        context "when the node has three items" do

          let(:set_node) { MSFLVisitors::Nodes::Set.new [first, second, third] }

          it "returns: { and: [{ term: { first_field: \"first_word\" } },{ term: { second_field: \"second_word\" } },{ term: { third_field: \"third_word\" } }] }" do
            expect(result).to eq({ and: [{ term: { first_field: "first_word" } },{ term: { second_field: "second_word" } },{ term: { third_field: "third_word" } }] })
          end
        end

        context "when one of the node's items is a containment node" do

          let(:node) do
            MSFLVisitors::Nodes::And.new(
                MSFLVisitors::Nodes::Set.new(
                    [
                        MSFLVisitors::Nodes::Filter.new(
                            [
                                MSFLVisitors::Nodes::Containment.new(
                                    MSFLVisitors::Nodes::Field.new(:make),
                                    MSFLVisitors::Nodes::Set.new(
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
          it "returns: { and: [{ terms: { make: [\"Honda\",\"Chevy\",\"Volvo\"]} }, { range: { value: { gte: 1000 } } }] }" do
            expected = { and: [{ terms: { make: ["Honda", "Chevy", "Volvo"]} }, { range: { value: { gte: 1000 } } }] }
            expect(result).to eq expected
          end
        end
      end

      describe "value nodes" do
        describe "a Boolean node" do

          let(:node) { MSFLVisitors::Nodes::Boolean.new value }

          subject(:result) { node.accept visitor }

          context "with a value of true" do

            let(:value) { true }

            it "returns: true" do
              expect(result).to eq true
            end
          end

          context "with a value of false" do

            let(:value) { false }

            it "returns: false" do
              expect(result).to eq false
            end
          end
        end

        describe "a Word node" do

          let(:word) { "node_content" }

          let(:node) { MSFLVisitors::Nodes::Word.new word }

          it "returns: the literal string" do
            expect(result).to eq "#{word}"
          end
        end
      end

      describe "range value nodes" do

        subject(:result) { node.accept visitor }

        describe "a Date node" do

          let(:today) { Date.today }

          let(:node) { MSFLVisitors::Nodes::Date.new today }

          it "returns: the date using iso8601 formatting" do
            expect(result).to eq "#{today.iso8601}"
          end
        end

        describe "a Time node" do

          let(:now) { Time.now }

          let(:node) { MSFLVisitors::Nodes::Time.new now }

          it "returns: the date using iso8601 formatting" do
            expect(result).to eq "#{now.iso8601}"
          end
        end

        describe "a DateTime node" do

          let(:now) { DateTime.now }

          let(:node) { MSFLVisitors::Nodes::DateTime.new now }

          it "returns: the date and time using iso8601 formatting" do
            expect(result).to eq "#{now.iso8601}"
          end
        end

        describe "a Number node" do

          let(:number) { 123 }

          let(:node) { MSFLVisitors::Nodes::Number.new number }

          it "returns: 123" do
            expect(result).to eq number
          end

          context "when the number is a float" do

            let(:number) { 123.456 }

            it "returns: the number with the same precision" do
              expect(result).to eq number
            end
          end
        end
      end
    end
  end
end