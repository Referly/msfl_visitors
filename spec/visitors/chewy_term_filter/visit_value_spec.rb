require 'spec_helper'

describe MSFL::Visitors::ChewyTermFilter do

  let(:collector) { Array.new }

  let(:node) { fail ArgumentError, "You must define the node variable in each scope." }

  let(:test_instance) { described_class.new }

  describe "#visit_MSFL_Nodes_Boolean" do

    subject { test_instance.visit_MSFL_Nodes_Boolean node, collector }

    let(:node) { MSFL::Nodes::Boolean.new value }

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

  describe "#visit_MSFL_Nodes_Word" do

    subject { test_instance.visit_MSFL_Nodes_Word node, collector }

    let(:node) { MSFL::Nodes::Word.new "node_content" }

    it "is a literal string" do
      expect(subject.first).to match /node_content/
    end
  end
end