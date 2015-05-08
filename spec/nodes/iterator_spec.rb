require 'spec_helper'

describe MSFLVisitors::Nodes::Iterator do

  describe "#==" do

    let(:one) { MSFLVisitors::Nodes::Number.new(1) }

    let(:two) { MSFLVisitors::Nodes::Number.new(2) }

    let(:left) { MSFLVisitors::Nodes::Iterator.new [one, two] }

    let(:right) { MSFLVisitors::Nodes::Iterator.new [one, two] }

    subject { left == right }

    context "when lhs and rhs are the same class" do

      context "when lhs#items is equal to rhs#items" do

        it { is_expected.to be true }
      end

      context "when lhs#items is not equal to rhs#items" do

        let(:right) {  MSFLVisitors::Nodes::Iterator.new [one] }

        it { is_expected.to be false }
      end
    end

    context "when lhs is a different class than rhs" do

      let(:right) { Object.new }

      it { is_expected.to be false }
    end
  end
end