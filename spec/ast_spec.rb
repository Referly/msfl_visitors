require 'spec_helper'

describe MSFLVisitors::AST do

  let(:msfl) { { make: "Honda" } }

  describe "#initialize" do

    let(:parser) do
      p = double('Fake Parser')
      expect(p).to receive(:parse).with(msfl).once
      p
    end

    subject { described_class.new msfl, parser }

    it "eagerly parses the first argument" do
      subject
    end

    context "when a parser is specified" do

      it "uses the specified parser" do
        subject
      end
    end
  end

  describe "#accept" do

    let(:parser) { double('Fake Parser', parse: root) }

    let(:root) do
      r = double('Fake Root Node')
      expect(r).to receive(:accept).with(visitor).once
      r
    end

    let(:visitor) { double('Fake Visitor') }

    subject { described_class.new(msfl, parser).accept visitor }

    it "delegates to the root node" do
      subject
    end
  end

  describe "#==" do

    subject { left == right }

    let(:left) { described_class.new(msfl) }

    let(:right) { described_class.new(msfl) }

    context "when the two ASTs are the same class" do

      context "when the two ASTs have equal root nodes" do

        it { is_expected.to be true }
      end

      context "when the two ASTs do not have equal root nodes" do

        let(:right) { described_class.new({ value: 1000 }) }

        it { is_expected.to be false }
      end
    end

    context "when the two ASTs are not the same class" do

      let(:right) { double('Fake AST') }

      it { is_expected.to be false }
    end
  end
end