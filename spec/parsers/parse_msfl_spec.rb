# This is a working file until I split these up
require 'spec_helper'

describe MSFLVisitors::Parsers::MSFLParser do

   describe "parsing a trivial filter" do

     subject { described_class.new.parse msfl }

     let(:msfl) { { make: "Ferrari" } }

     let(:expected) { MSFLVisitors::Nodes::Filter.new [ MSFLVisitors::Nodes::Equal.new(left, right) ] }

     let(:left) { MSFLVisitors::Nodes::Word.new :make }

     let(:right) { MSFLVisitors::Nodes::Word.new "Ferrari" }

     it "is the expected AST" do
       expect(subject).to eq expected
     end
   end
end