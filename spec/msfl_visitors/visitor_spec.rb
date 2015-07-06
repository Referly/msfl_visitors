require 'spec_helper'

describe MSFLVisitors::Visitor do

  context "when creating an instance of #{described_class}" do

    subject { described_class.new }

    it "sets the mode to term" do
      subject
      expect(subject.send(:mode)).to eq :term
    end
  end

  describe "#escape_es_special_regex_chars" do

    include MSFLVisitors::VisitorHelpers
    {
        'ab@cd' => 'ab\@cd',
        'ab&cd' => 'ab\&cd',
        'ab<cd' => 'ab\<cd',
        'ab>cd' => 'ab\>cd',
        'ab~cd' => 'ab\~cd',
    }.each do |str, expected|

      it "escapes '#{str}' as '#{expected}'" do
        expect(escape_es_special_regex_chars str).to eq expected
      end
    end
  end
end