require 'spec_helper'

describe MSFLVisitors::Visitors::ChewyTermFilter do

  subject { node.accept visitor }

  let(:node) { fail ArgumentError, "You must define the node variable in each scope." }

  let(:visitor) { described_class.new collector }

  let(:collector) { Array.new }

  describe "visiting a Boolean node" do

    let(:node) { MSFLVisitors::Nodes::Boolean.new value }

    context "when the node has a value of true" do

      let(:value) { true }

      it "is true" do
        expect(subject.first).to be true
      end
    end

    context "when the node has a value of false" do

      let(:value) { false }

      it "is false" do
        expect(subject.first).to be false
      end
    end
  end

  describe "visiting a Word node" do

    let(:node) { MSFLVisitors::Nodes::Word.new "node_content" }

    it "is a literal string" do
      expect(subject.first).to match /node_content/
    end
  end
end