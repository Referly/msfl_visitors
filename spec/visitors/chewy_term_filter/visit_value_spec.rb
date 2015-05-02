require 'spec_helper'

describe MSFL::Visitors::ChewyTermFilter do

  let(:collector) { Array.new }

  let(:node) { fail ArgumentError, "You must define the node variable in each scope." }

  let(:test_instance) { described_class.new }

  describe "#visit_MSFL_Nodes_Word" do

    subject { test_instance.visit_MSFL_Nodes_Word node, collector }

    let(:node) { MSFL::Nodes::Word.new "node_content" }

    it "is a literal string" do
      expect(subject.first).to match /node_content/
    end
  end
end