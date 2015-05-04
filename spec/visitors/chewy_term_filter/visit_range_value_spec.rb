require 'spec_helper'

describe MSFLVisitors::Visitors::ChewyTermFilter do

  subject { node.accept visitor }

  let(:node) { fail ArgumentError, "You must define the node variable in each scope." }

  let(:visitor) { described_class.new collector }

  let(:collector) { Array.new }

  describe "visiting a Date node" do

    let(:node) { MSFLVisitors::Nodes::Date.new Date.today }

    it "is today's date using iso8601 formatting" do
      expect(subject.first).to eq Date.today.iso8601
    end
  end

  describe "visiting a DateTime node" do

    let(:now) { DateTime.now }

    let(:node) { MSFLVisitors::Nodes::DateTime.new now }

    it "is the current date and time using iso8601 formatting" do
      expect(subject.first).to eq now.iso8601
    end
  end

  describe "visiting a Number node" do

    let(:node) { MSFLVisitors::Nodes::Number.new number }

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

  describe "visiting a Time node" do

    let(:node) { MSFLVisitors::Nodes::Time.new current_time }

    let(:current_time) { Time.now }

    it "is the current time using iso8601 formatting" do
      expect(subject.first).to eq current_time.iso8601
    end
  end
end