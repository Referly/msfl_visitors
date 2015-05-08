# This is a working file until I split these up
require 'spec_helper'

describe MSFLVisitors::Parsers::MSFLParser do

  let(:expected_node) { ->(comp_node) { MSFLVisitors::Nodes::Filter.new [ comp_node ] } }

  let(:left) { MSFLVisitors::Nodes::Field.new :value }

  let(:right) { MSFLVisitors::Nodes::Number.new 1000 }

  describe "parsing a trivial filter" do

    subject { described_class.new.parse msfl }

    let(:msfl) { { value: 1000 } }

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

        let(:filter) { { value: 1000 } }

        it "is the expected Equal node" do
          expect(subject).to eq expected_node.call(MSFLVisitors::Nodes::Equal.new(left, right))
        end
      end

      describe "parsing explict comparisons" do

        describe "parsing a gte filter" do

          let(:filter) { { value: { gte: 1000 } } }

          it "is the expected GreaterThanEqual node" do
            comparison_node = MSFLVisitors::Nodes::GreaterThanEqual.new left, right
            expect(subject).to eq expected_node.call(comparison_node)
          end
        end
      end

      describe "parsing containment" do

        let(:filter) { { value: { in: set_of_values } } }

        # { value: { in: [50, 250, 20000] } }
        #
        #  => Nodes::Containment.new(Nodes::Field.new(:value),
        #                            Nodes::Set::Set.new([
        #                               Nodes::Number.new(50),
        #                               Nodes::Number.new(250),
        #                               Nodes::Number.new(20000)]))
        it "handles containments" do
          containment_node = MSFLVisitors::Nodes::Containment.new left, set_node
          expect(subject).to eq expected_node.call(containment_node)
        end
      end

      describe "parsing an and filter" do

        let(:filter) { { and: set_of_values } }

        let(:and_node) { MSFLVisitors::Nodes::And.new set_node }

        it "parses the filter" do
          expect(subject).to eq expected_node.call(and_node)
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