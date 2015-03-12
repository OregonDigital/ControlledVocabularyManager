require 'rails_helper'

RSpec.describe CombinedId do
  subject { described_class.new(vocab, term) }
  describe "#to_s" do
    context "when given a vocab and term" do
      let(:vocab) { "test" }
      let(:term) { "banana" }
      it "should be test/banana" do
        expect(subject.to_s).to eq "test/banana"
      end
    end
  end
end
