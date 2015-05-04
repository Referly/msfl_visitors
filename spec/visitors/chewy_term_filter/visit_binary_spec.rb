require 'spec_helper'

describe MSFLVisitors::Visitors::ChewyTermFilter do

  subject { node.accept visitor }

  let(:node) { fail ArgumentError, "You must define the node variable in each scope." }

  let(:visitor) { described_class.new collector }

  let(:collector) { String.new }

  let(:left) { MSFLVisitors::Nodes::Word.new "lhs" }

  let(:right) { MSFLVisitors::Nodes::Word.new "rhs" }

  describe "visiting an And node" do

    let(:node) { MSFLVisitors::Nodes::And.new left, right }

    it "matches ( left ) & ( right )" do
      expect(subject).to match "( lhs ) & ( rhs )"
    end
  end

end