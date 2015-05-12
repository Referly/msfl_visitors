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

      let(:set_node) { MSFLVisitors::Nodes::Set::Set.new set_of_nodes }

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

        # { value: { in: [50, 250, 20000] } }
        #
        #  => Nodes::Containment.new(Nodes::Field.new(:value),
        #                            Nodes::Set::Set.new([
        #                               Nodes::Number.new(50),
        #                               Nodes::Number.new(250),
        #                               Nodes::Number.new(20000)]))
        it "is the expected Containment node" do
          expect(subject).to eq expected_node.call(containment_node)
        end
      end

      describe "parsing a foreign filter" do

        let(:filter) { { person: { age: 25 } } }

        let(:foreign_node) { MSFLVisitors::Nodes::Foreign.new foreign_name_node, filter_node }

        let(:filter_node) { MSFLVisitors::Nodes::Filter.new [equal_node] }

        let(:equal_node) { MSFLVisitors::Nodes::Equal.new field_node, value_node }

        let(:field_node) { MSFLVisitors::Nodes::Field.new :age }

        let(:value_node) { MSFLVisitors::Nodes::Number.new 25 }

        let(:foreign_name_node) { MSFLVisitors::Nodes::Word.new :person }

        subject { described_class.new(MSFL::Datasets::Car.new).parse(filter) }

        it "is the expected Foreign node" do
          expect(subject).to eq expected_node.call(foreign_node)
        end
      end

      describe "parsing an and filter" do

        let(:filter) { { and: set_of_values } }

        let(:and_node) { MSFLVisitors::Nodes::And.new set_node }

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