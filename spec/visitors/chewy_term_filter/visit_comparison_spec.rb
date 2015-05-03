require 'spec_helper'

describe MSFL::Visitors::ChewyTermFilter do

  subject { node.accept visitor }

  let(:node) { fail ArgumentError, "You must define the node variable in each scope." }

  let(:visitor) { described_class.new collector }

  let(:collector) { String.new }

  let(:left) { MSFL::Nodes::Word.new "lhs" }

  let(:right) { MSFL::Nodes::Word.new "rhs" }

  describe "visiting an Equal node" do

    let(:node) { MSFL::Nodes::Equal.new left, right }

    it "matches left == right" do
      expect(subject).to match "lhs == rhs"
    end
  end

  describe "visiting a GreaterThan node" do

    let(:node) { MSFL::Nodes::GreaterThan.new left, right }

    it "matches left > right" do
      expect(subject).to match "lhs > rhs"
    end
  end

  describe "visiting a GreaterThanEqual node" do

    let(:node) { MSFL::Nodes::GreaterThanEqual.new left, right }

    it "matches left >= right" do
      expect(subject).to match "lhs >= rhs"
    end
  end

  describe "visiting a LessThan node" do

    let(:node) { MSFL::Nodes::LessThan.new left, right }

    it "matches left < right" do
      expect(subject).to match "lhs < rhs"
    end
  end

  describe "visiting a LessThanEqual node" do

    let(:node) { MSFL::Nodes::LessThanEqual.new left, right }

    it "matches left <= right" do
      expect(subject).to match "lhs <= rhs"
    end
  end
end