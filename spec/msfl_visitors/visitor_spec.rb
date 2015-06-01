require 'spec_helper'

describe MSFLVisitors::Visitor do

  context "when creating an instance of #{described_class}" do

    subject { described_class.new }

    it "sets the mode to term" do
      subject
      expect(subject.send(:mode)).to eq :term
    end
  end
end