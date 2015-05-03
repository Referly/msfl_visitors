require 'spec_helper'

describe MSFL::Visitors::ChewyTermFilter do

  subject { node.accept visitor }

  let(:node) { fail ArgumentError, "You must define the node variable in each scope." }

  let(:visitor) { described_class.new collector }

  let(:collector) { String.new }

  let(:left) { MSFL::Nodes::Word.new "lhs" }

  let(:right) { MSFL::Nodes::Word.new "rhs" }

  describe "#visit_MSFL_Nodes_And" do

    let(:node) { MSFL::Nodes::And.new left, right }

    it "matches ( left ) & ( right )" do
      expect(subject).to match "( lhs ) & ( rhs )"
    end
  end

end