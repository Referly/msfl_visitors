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

  describe "#visit_MSFL_Nodes_Date" do

    subject { test_instance.visit_MSFL_Nodes_Date node, collector }

    let(:node) { MSFL::Nodes::Date.new Date.today }

    it "is today's date using iso8601 formatting" do
      expect(subject.first).to eq Date.today.iso8601
    end
  end

  describe "#visit_MSFL_Nodes_DateTime" do

    subject { test_instance.visit_MSFL_Nodes_DateTime node, collector }

    let(:now) { DateTime.now }

    let(:node) { MSFL::Nodes::DateTime.new now }

    it "is the current date and time using iso8601 formatting" do
      expect(subject.first).to eq now.iso8601
    end
  end

  describe "#visit_MSFL_Nodes_Number" do

    subject { test_instance.visit_MSFL_Nodes_Number node, collector }

    let(:node) { MSFL::Nodes::Number.new number }

    let(:number) { 123 }

    it "is the number" do
      expect(subject.first).to eq number
    end

    context "when the number is a float" do

      let(:number) { 123.456 }

      it "is the number with the same precision" do
        expect(subject.first).to eq number
      end
    end
  end
end