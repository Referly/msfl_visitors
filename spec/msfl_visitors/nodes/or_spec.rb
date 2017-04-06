require 'spec_helper'

describe MSFLVisitors::Nodes::Or do

  context "when creating an instance of #{described_class}" do

    subject { described_class.new node }

    context "when passed as Set node as the argument to the constructor" do

      let(:node) { MSFLVisitors::Nodes::Set.new [MSFLVisitors::Nodes::Number.new(1)] }

      context "when the Set contains any nodes which inherit from Value" do

        it "raises an ArgumentError" do
          expect { subject }.to raise_error ArgumentError
        end
      end
    end
  end
end