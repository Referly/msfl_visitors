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

      subject { -> (filter) { described_class.new.parse filter } }

      let(:implicit_equality_filter) { { value: 1000 } }

      let(:explicit_gte_filter) { { value: { gte: 1000 } } }

      it "handles implicit equality comparisons" do
        expect(subject.call(implicit_equality_filter)).to eq expected_node.call(MSFLVisitors::Nodes::Equal.new(left, right))
      end

      it "handles explicit comparisons" do
        comparison_node = MSFLVisitors::Nodes::GreaterThanEqual.new(left, right)
        expect(subject.call(explicit_gte_filter)).to eq expected_node.call(comparison_node)
      end

      it "handles containments"

      context "when the filter contains an unsupported type" do

        let(:bad_filter) { { foo: Object.new } }

        it "raises an ArgumentError" do
          expect { subject.call(bad_filter) }.to raise_error ArgumentError
        end
      end
    end
  end
end