require 'spec_helper'

describe MSFLVisitors::Visitors::ChewyTermFilter do

  let(:node) { fail ArgumentError, "You must define the node variable in each scope." }

  let(:visitor) { described_class.new collector }

  let(:collector) { String.new }

  let(:left) { MSFLVisitors::Nodes::Word.new "lhs" }

  let(:right) { MSFLVisitors::Nodes::Word.new "rhs" }

  subject(:result) { node.accept visitor }

  describe "the result of visiting an Equal node" do

    let(:node) { MSFLVisitors::Nodes::Equal.new left, right }

    it "is: 'left == right'" do
      expect(result).to eq "lhs == rhs"
    end
  end

  describe "the result of visiting a GreaterThan node" do

    let(:node) { MSFLVisitors::Nodes::GreaterThan.new left, right }

    it "is: 'left > right'" do
      expect(result).to eq "lhs > rhs"
    end
  end

  describe "the result of visiting a GreaterThanEqual node" do

    let(:node) { MSFLVisitors::Nodes::GreaterThanEqual.new left, right }

    it "is: 'left >= right'" do
      expect(result).to eq "lhs >= rhs"
    end
  end

  describe "the result of visiting a LessThan node" do

    let(:node) { MSFLVisitors::Nodes::LessThan.new left, right }

    it "is: 'left < right'" do
      expect(result).to eq "lhs < rhs"
    end
  end

  describe "the result of visiting a LessThanEqual node" do

    let(:node) { MSFLVisitors::Nodes::LessThanEqual.new left, right }

    it "is: 'left <= right'" do
      expect(result).to eq "lhs <= rhs"
    end
  end
end