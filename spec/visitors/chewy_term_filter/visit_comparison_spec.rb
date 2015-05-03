require 'spec_helper'

describe MSFL::Visitors::ChewyTermFilter do

  let(:collector) { String.new }

  let(:node) { fail ArgumentError, "You must define the node variable in each scope." }

  let(:test_instance) { described_class.new }

  let(:left) { MSFL::Nodes::Word.new "lhs" }

  let(:right) { MSFL::Nodes::Word.new "rhs" }

  describe "#visit_MSFL_Nodes_Equal" do

    subject { test_instance.visit_MSFL_Nodes_Equal node, collector }

    let(:node) { MSFL::Nodes::Equal.new left, right }

    it "matches ( left == right )" do
      expect(subject).to match "( lhs == rhs )"
    end
  end

  describe "#visit_MSFL_Nodes_GreaterThan" do

    subject { test_instance.visit_MSFL_Nodes_GreaterThan node, collector }

    let(:node) { MSFL::Nodes::GreaterThan.new left, right }

    it "matches ( left > right )" do
      expect(subject).to match "( lhs > rhs )"
    end
  end

  describe "#visit_MSFL_Nodes_GreaterThanEqual" do

    subject { test_instance.visit_MSFL_Nodes_GreaterThanEqual node, collector }

    let(:node) { MSFL::Nodes::GreaterThanEqual.new left, right }

    it "matches ( left >= right )" do
      expect(subject).to match "( lhs >= rhs )"
    end
  end

  describe "#visit_MSFL_Nodes_LessThan" do

    subject { test_instance.visit_MSFL_Nodes_LessThan node, collector }

    let(:node) { MSFL::Nodes::LessThan.new left, right }

    it "matches ( left < right )" do
      expect(subject).to match "( lhs < rhs )"
    end
  end

  describe "#visit_MSFL_Nodes_LessThanEqual" do

    subject { test_instance.visit_MSFL_Nodes_LessThanEqual node, collector }

    let(:node) { MSFL::Nodes::LessThanEqual.new left, right }

    it "matches ( left <= right )" do
      expect(subject).to match "( lhs <= rhs )"
    end
  end
end