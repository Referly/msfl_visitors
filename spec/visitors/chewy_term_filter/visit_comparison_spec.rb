require 'spec_helper'

describe MSFLVisitors::Visitors::ChewyTermFilter do

  subject { node.accept visitor }

  let(:node) { fail ArgumentError, "You must define the node variable in each scope." }

  let(:visitor) { described_class.new collector }

  let(:collector) { String.new }

  let(:left) { MSFLVisitors::Nodes::Word.new "lhs" }

  let(:right) { MSFLVisitors::Nodes::Word.new "rhs" }

  describe "visiting an Equal node" do

    let(:node) { MSFLVisitors::Nodes::Equal.new left, right }

    it "matches left == right" do
      expect(subject).to match "lhs == rhs"
    end
  end

  describe "visiting a GreaterThan node" do

    let(:node) { MSFLVisitors::Nodes::GreaterThan.new left, right }

    it "matches left > right" do
      expect(subject).to match "lhs > rhs"
    end
  end

  describe "visiting a GreaterThanEqual node" do

    let(:node) { MSFLVisitors::Nodes::GreaterThanEqual.new left, right }

    it "matches left >= right" do
      expect(subject).to match "lhs >= rhs"
    end
  end

  describe "visiting a LessThan node" do

    let(:node) { MSFLVisitors::Nodes::LessThan.new left, right }

    it "matches left < right" do
      expect(subject).to match "lhs < rhs"
    end
  end

  describe "visiting a LessThanEqual node" do

    let(:node) { MSFLVisitors::Nodes::LessThanEqual.new left, right }

    it "matches left <= right" do
      expect(subject).to match "lhs <= rhs"
    end
  end
end