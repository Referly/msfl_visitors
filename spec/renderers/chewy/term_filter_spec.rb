require 'spec_helper'

describe MSFLVisitors::Renderers::Chewy::TermFilter do

  let(:node) { fail ArgumentError, "You must define the node variable in each scope." }

  let(:collector) { String.new }

  let(:renderer) { MSFLVisitors::Renderers::Chewy::TermFilter.new }

  describe "#render" do

    let(:node) { double('Unsupported Type') }

    subject { renderer.render node }

    context "when attempting to render an unsupported type" do

      it "raises an ArgumentError" do
        expect { subject }.to raise_error ArgumentError
      end
    end
  end
end