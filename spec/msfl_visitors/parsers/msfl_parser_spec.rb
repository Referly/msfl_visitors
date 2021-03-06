# This is a working file until I split these up
require 'spec_helper'

describe MSFLVisitors::Parsers::MSFLParser do

  let(:expected_node) { ->(wrapped_node) { MSFLVisitors::Nodes::Filter.new [ wrapped_node ] } }

  let(:left) { MSFLVisitors::Nodes::Field.new :value }

  let(:right) { MSFLVisitors::Nodes::Number.new one_thousand }

  let(:one_thousand) { 1000 }

  describe "parsing a trivial filter" do

    subject { described_class.new.parse msfl }

    let(:msfl) { { value: one_thousand } }

    it "is the expected node" do
      expect(subject).to eq expected_node.call(MSFLVisitors::Nodes::Equal.new(left, right))
    end
  end

  describe "#parse" do

    context "when parsing a filter" do

      subject { described_class.new.parse(filter) }

      let(:set_of_values) { MSFL::Types::Set.new [50, 250, 20000] }

      let(:set_of_nodes) { set_of_values.map { |value| MSFLVisitors::Nodes::Number.new value } }

      let(:set_node) { MSFLVisitors::Nodes::Set.new set_of_nodes }

      describe "parsing implicit equality" do

        let(:filter) { { value: one_thousand } }

        it "is the expected Equal node" do
          expect(subject).to eq expected_node.call(MSFLVisitors::Nodes::Equal.new(left, right))
        end
      end

      describe "parsing explict comparisons" do

        describe "parsing a gt filter" do

          let(:filter) { { value: { gt: one_thousand } } }

          let(:gt_node) { MSFLVisitors::Nodes::GreaterThan.new left, right }

          it "is the expected GreaterThan node" do
            expect(subject).to eq expected_node.call(gt_node)
          end
        end

        describe "parsing a gte filter" do

          let(:filter) { { value: { gte: one_thousand } } }

          let(:gte_node) { MSFLVisitors::Nodes::GreaterThanEqual.new left, right }

          it "is the expected GreaterThanEqual node" do
            expect(subject).to eq expected_node.call(gte_node)
          end
        end

        describe "parsing a eq filter" do

          let(:filter) { { value: { eq: one_thousand } } }

          let(:eq_node) { MSFLVisitors::Nodes::Equal.new left, right }

          it "is the expected Equal node" do
            expect(subject).to eq expected_node.call(eq_node)
          end
        end

        describe "parsing a lt filter" do

          let(:filter) { { value: { lt: one_thousand } } }

          let(:lt_node) { MSFLVisitors::Nodes::LessThan.new left, right }

          it "is the expected LessThan node" do
            expect(subject).to eq expected_node.call(lt_node)
          end
        end

        describe "parsing a lte filter" do

          let(:filter) { { value: { lte: one_thousand } } }

          let(:lte_node) { MSFLVisitors::Nodes::LessThanEqual.new left, right }

          it "is the expected LessThanEqual node" do
            expect(subject).to eq expected_node.call(lte_node)
          end
        end
      end

      describe "parsing containment" do

        let(:filter) { { value: { in: set_of_values } } }

        let(:containment_node) { MSFLVisitors::Nodes::Containment.new left, set_node }

        it "is the expected Containment node" do
          expect(subject).to eq expected_node.call(containment_node)
        end
      end

      describe "parsing filters that contain explicit filters" do

        let(:explicit_filter_node) { MSFLVisitors::Nodes::ExplicitFilter.new [equal_node] }

        let(:equal_node) { MSFLVisitors::Nodes::Equal.new field_node, value_node }

        describe "parsing a foreign filter" do

          let(:filter) { { foreign: { dataset: "person", filter: { age: 25 } } } }

          let(:foreign_node) { MSFLVisitors::Nodes::Foreign.new dataset_node, explicit_filter_node }

          let(:field_node) { MSFLVisitors::Nodes::Field.new :age }

          let(:value_node) { MSFLVisitors::Nodes::Number.new 25 }

          let(:dataset_node) { MSFLVisitors::Nodes::Dataset.new "person" }

          subject { described_class.new(MSFL::Datasets::Car.new).parse(filter) }

          it "is the expected Foreign node" do
            expect(subject).to eq expected_node.call(foreign_node)
          end
        end

        describe "parsing a partial" do

          let(:filter) { { partial: { given: given_filter, filter: { avg_age: 10 } } } }

          let(:given_filter) { { make: "Toyota" } }


          let(:partial_node)        { MSFLVisitors::Nodes::Partial.new given_node, named_value }

            let(:given_node)          { MSFLVisitors::Nodes::Given.new [given_equal_node] }

              let(:given_equal_node)    { MSFLVisitors::Nodes::Equal.new given_field_node, given_value_node }

                let(:given_field_node)    { MSFLVisitors::Nodes::Field.new :make }

                let(:given_value_node)    { MSFLVisitors::Nodes::Word.new "Toyota" }


          let(:named_value)    { MSFLVisitors::Nodes::NamedValue.new MSFLVisitors::Nodes::Word.new("partial"), explicit_filter_node }
            # explicit_filter_node already defined

              # equal_node already defined

                let(:field_node)          { MSFLVisitors::Nodes::Field.new :avg_age }

                let(:value_node)          { MSFLVisitors::Nodes::Number.new 10 }


          it "is the expected Partial node" do
            expect(subject).to eq expected_node.call(partial_node)
          end

          context "when the partial's given clause is a foreign" do

            let(:given_filter) { { foreign: { dataset: "person", filter: { gender: 'male' } } } }

            let(:given_node) { MSFLVisitors::Nodes::Given.new [foreign_node] }

            let(:foreign_node) { MSFLVisitors::Nodes::Foreign.new dataset_node, given_explicit_filter_node }

            let(:dataset_node) { MSFLVisitors::Nodes::Dataset.new "person" }

            let(:given_explicit_filter_node) { MSFLVisitors::Nodes::ExplicitFilter.new [given_exp_fil_equal_node] }

            let(:given_exp_fil_equal_node) { MSFLVisitors::Nodes::Equal.new given_exp_fil_field_node, given_exp_fil_value_node }

            let(:given_exp_fil_field_node) { MSFLVisitors::Nodes::Field.new :gender }

            let(:given_exp_fil_value_node) { MSFLVisitors::Nodes::Word.new 'male' }

            it "is the expected Partial node with a Foreign node under the Given node" do
              expect(subject).to eq expected_node.call(partial_node)
            end
          end
        end
      end

      describe "parsing an and filter" do

        let(:filter) { { and: MSFL::Types::Set.new([{ value: 1000 }]) } }

        let(:and_node) { MSFLVisitors::Nodes::And.new set_node }

        let(:set_node) { MSFLVisitors::Nodes::Set.new filter_node }

        let(:filter_node) { MSFLVisitors::Nodes::Filter.new(MSFLVisitors::Nodes::Equal.new left, right) }

        it "is the expected And node" do
          expect(subject).to eq expected_node.call(and_node)
        end

        context "when it contains a containment filter" do

          let(:makes) { MSFL::Types::Set.new(["Honda", "Chevy", "Volvo"]) }

          let(:containment_filter) { { make: { in: makes } } }

          let(:gte_filter) { { value: { gte: one_thousand } } }

          let(:and_set) { MSFL::Types::Set.new([containment_filter, gte_filter]) }

          let(:filter) { { and: and_set } }

          let(:and_node) do
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
                        MSFLVisitors::Nodes::Number.new(one_thousand)
                      )
                    ]
                  )
                ]
              )
            )
          end

          it "is the expected And node" do
            expect(subject).to eq expected_node.call(and_node)
          end

        end
      end

      context "when the filter contains an unsupported type" do

        let(:filter) { { foo: Object.new } }

        it "raises an ArgumentError" do
          expect { subject }.to raise_error ArgumentError
        end
      end
    end
  end
end