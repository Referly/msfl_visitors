require 'spec_helper'

describe MSFLVisitors do

  describe ".get_chewy_clauses" do

    subject { described_class.get_chewy_clauses dataset, nmsfl }

    let(:dataset) { MSFL::Datasets::Car.new }

    let(:nmsfl) { { make: "Toyota" } }

    context "when the first argument is not a descendant of MSFL::Datasets::Base" do

      let(:dataset) { double('Invalid Dataset') }

      it "raises an ArgumentError" do
        expect { subject }.to raise_error ArgumentError
      end
    end
  end
end