require 'spec_helper'

describe MSFLVisitors::Visitor do

  let(:node) { fail ArgumentError, "You must define the node variable in each scope." }

  let(:collector) { String.new }

  let(:renderer) { MSFLVisitors::Renderers::Chewy::TermFilter.new }

  let(:visitor) { described_class.new collector, renderer }

  let(:left) { MSFLVisitors::Nodes::Field.new "lhs" }

  let(:right) { MSFLVisitors::Nodes::Word.new "rhs" }

  subject(:result) { node.accept visitor; collector }

  context "when visiting" do

    describe "an Equal node" do

      let(:node) { MSFLVisitors::Nodes::Equal.new left, right }

      it "results in: 'left == right'" do
        expect(result).to eq "lhs == \"rhs\""
      end
    end

    describe "a GreaterThan node" do

      let(:node) { MSFLVisitors::Nodes::GreaterThan.new left, right }

      it "returns: 'left > right'" do
        expect(result).to eq "lhs > \"rhs\""
      end
    end

    describe "a GreaterThanEqual node" do

      let(:node) { MSFLVisitors::Nodes::GreaterThanEqual.new left, right }

      it "returns: 'left >= right'" do
        expect(result).to eq "lhs >= \"rhs\""
      end
    end

    describe "a LessThan node" do

      let(:node) { MSFLVisitors::Nodes::LessThan.new left, right }

      it "returns: 'left < right'" do
        expect(result).to eq 'lhs < "rhs"'
      end
    end

    describe "a LessThanEqual node" do

      let(:node) { MSFLVisitors::Nodes::LessThanEqual.new left, right }

      it "returns: 'left <= right'" do
        expect(result).to eq 'lhs <= "rhs"'
      end
    end

    describe "an And node" do

      let(:first_field) { MSFLVisitors::Nodes::Field.new "first_field" }

      let(:first_value) { MSFLVisitors::Nodes::Word.new "first_word" }

      let(:first) { MSFLVisitors::Nodes::Equal.new(first_field, first_value) }

      let(:second_field) { MSFLVisitors::Nodes::Field.new "second_field" }

      let(:second_value) { MSFLVisitors::Nodes::Word.new "second_word" }

      let(:second) { MSFLVisitors::Nodes::Equal.new(second_field, second_value) }

      let(:third_field) { MSFLVisitors::Nodes::Field.new "third_field" }

      let(:third_value) { MSFLVisitors::Nodes::Word.new "third_word" }

      let(:third) { MSFLVisitors::Nodes::Equal.new(third_field, third_value) }

      context "when the And node has zero items" do
        let(:node) { MSFLVisitors::Nodes::And.new([]) }

        it "is empty" do
          expect(result).to be_empty
        end
      end

      context "when the node has one item" do

        let(:node) { MSFLVisitors::Nodes::And.new([first])}

        it "returns: the item without adding parentheses" do
          expect(result).to eq 'first_field == "first_word"'
        end
      end

      context "when the node has two items" do

        let(:node) { MSFLVisitors::Nodes::And.new([first, second]) }

        it "returns: '( first_field == \"first_word\" ) & ( second_field == \"second_word\" )'" do
          expect(result).to eq '( first_field == "first_word" ) & ( second_field == "second_word" )'
        end
      end

      context "when the node has three items" do

        let(:node) { MSFLVisitors::Nodes::And.new([first, second, third]) }

        it "returns: '( first_field == \"first_word\" ) & ( second_field == \"second_word\" ) & ( third_field == \"third_word\" )'" do
          expect(result).to eq '( first_field == "first_word" ) & ( second_field == "second_word" ) & ( third_field == "third_word" )'
        end
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

        it "is a double quoted literal string" do
          expect(result).to eq "\"#{word}\""
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