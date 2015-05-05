require 'spec_helper'

describe MSFLVisitors::Visitor do

  let(:node) { fail ArgumentError, "You must define the node variable in each scope." }

  let(:collector) { String.new }

  let(:renderer) { MSFLVisitors::Renderers::Chewy::TermFilter.new }

  let(:visitor) { described_class.new collector, renderer }

  let(:left) { MSFLVisitors::Nodes::Word.new "lhs" }

  let(:right) { MSFLVisitors::Nodes::Word.new "rhs" }

  subject(:result) { node.accept visitor }

  context "when visiting" do

    describe "an Equal node" do

      let(:node) { MSFLVisitors::Nodes::Equal.new left, right }

      it "results in: 'left == right'" do
        expect(result).to eq "lhs == rhs"
      end
    end

    describe "a GreaterThan node" do

      let(:node) { MSFLVisitors::Nodes::GreaterThan.new left, right }

      it "returns: 'left > right'" do
        expect(result).to eq "lhs > rhs"
      end
    end

    describe "a GreaterThanEqual node" do

      let(:node) { MSFLVisitors::Nodes::GreaterThanEqual.new left, right }

      it "returns: 'left >= right'" do
        expect(result).to eq "lhs >= rhs"
      end
    end

    describe "a LessThan node" do

      let(:node) { MSFLVisitors::Nodes::LessThan.new left, right }

      it "returns: 'left < right'" do
        expect(result).to eq "lhs < rhs"
      end
    end

    describe "a LessThanEqual node" do

      let(:node) { MSFLVisitors::Nodes::LessThanEqual.new left, right }

      it "returns: 'left <= right'" do
        expect(result).to eq "lhs <= rhs"
      end
    end

    describe "an And node" do

      let(:node) { MSFLVisitors::Nodes::And.new left, right }

      it "returns: '( left ) & ( right )'" do
        expect(result).to eq "( lhs ) & ( rhs )"
      end
    end

    describe "value nodes" do
      describe "a Boolean node" do

        let(:collector) { Array.new }

        let(:node) { MSFLVisitors::Nodes::Boolean.new value }

        subject(:result) { node.accept(visitor).first }

        context "with a value of true" do

          let(:value) { true }

          it "returns: true" do
            expect(result).to be true
          end
        end

        context "with a value of false" do

          let(:value) { false }

          it "returns: false" do
            expect(result).to be false
          end
        end
      end

      describe "a Word node" do

        let(:word) { "node_content" }

        let(:node) { MSFLVisitors::Nodes::Word.new word }

        it "is a literal string" do
          expect(result).to eq word
        end
      end
    end

    describe "range value nodes" do

      let(:collector) { Array.new }

      subject(:result) { node.accept(visitor).first }

      describe "a Date node" do

        let(:today) { Date.today }

        let(:node) { MSFLVisitors::Nodes::Date.new today }

        it "returns: the date using iso8601 formatting" do
          expect(result).to eq today.iso8601
        end
      end

      describe "a Time node" do

        let(:now) { Time.now }

        let(:node) { MSFLVisitors::Nodes::Time.new now }

        it "returns: the time using iso8601 formatting" do
          expect(result).to eq now.iso8601
        end
      end

      describe "a DateTime node" do

        let(:now) { DateTime.now }

        let(:node) { MSFLVisitors::Nodes::DateTime.new now }

        it "returns: the date and time using iso8601 formatting" do
          expect(result).to eq now.iso8601
        end
      end

      describe "a Number node" do

        let(:number) { 123 }

        let(:node) { MSFLVisitors::Nodes::Number.new number }

        it "returns: the number" do
          expect(result).to eq number
        end

        context "when the number is a float" do

          let(:number) { 123.456 }

          it "returns: the number with the same precision" do
            expect(result).to eq number
          end
        end
      end
    end
  end
end