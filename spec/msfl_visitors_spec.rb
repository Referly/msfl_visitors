require 'spec_helper'

describe MSFLVisitors do

  describe ".get_chewy_clauses" do

    subject { described_class.get_chewy_clauses dataset, msfl }

    let(:dataset) { MSFL::Datasets::Car.new }

    let(:msfl) { { make: "Toyota" } }

    it "converts an msfl filter into normal MSFL form" do
      imitation_converter = double('Imitation Converter')
      expect(imitation_converter).to receive(:run_conversions).once
      expect(MSFL::Converters::Operator).to receive(:new).once { imitation_converter }
      subject
    end

    context "when the first argument is not a descendant of MSFL::Datasets::Base" do

      let(:dataset) { double('Invalid Dataset') }

      it "raises an ArgumentError" do
        expect { subject }.to raise_error ArgumentError
      end
    end

    describe "examples from README" do

      context "when the filter is { make: \"Toyota\" }" do

        it 'returns: [{ clause: "make == \"Toyota\"" }]' do
          expect(subject).to eq [{ clause: "make == \"Toyota\"" }]
        end
      end

      context "when the filter is { partial: { given: { make: \"Toyota\" }, filter: { avg_age: 10 } } }" do

        let(:msfl) { { partial: { given: { make: "Toyota" }, filter: { avg_age: 10 } } } }

        it "returns: [
            {
                clause: {
                    agg_field_name: :avg_age,
                    operator: :eq,
                    test_value: 10
                },
                method_to_execute: :aggregations
            }, {clause: \"make == \"Toyota\"\"}
        ]" do

          expect(subject).to eq [
            {
                clause: {
                    agg_field_name: :avg_age,
                    operator: :eq,
                    test_value: 10
                },
                method_to_execute: :aggregations
            }, {clause: "make == \"Toyota\""}
          ]
        end
      end
    end
  end
end