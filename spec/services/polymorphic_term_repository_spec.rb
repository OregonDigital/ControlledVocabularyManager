require 'rails_helper'

RSpec.describe PolymorphicTermRepository do
  subject { PolymorphicTermRepository.new(Vocabulary, Term) }

  describe ".new" do
    let(:id) { "vocab" }
    let(:result) { subject.new(id) }
    context "when given a vocab id" do
      it "should return a Vocabulary" do
        expect(result).to be_instance_of Vocabulary
      end
    end
    context "when given a term id" do
      let(:id) { "vocab/term" }
      it "should return a Term" do
        expect(result).to be_instance_of Term
      end
    end
  end

  describe ".find" do
    let(:id) { "vocab" }
    let(:result) { subject.find(id) }
    let(:term) { double("term") }
    let(:vocabulary) { double("vocabulary") }
    before do
      allow(Term).to receive(:find).and_return(term)
      allow(Vocabulary).to receive(:find).and_return(vocabulary)
      result
    end
    context "when given a vocab id" do
      it "should find a vocabulary" do
        expect(Vocabulary).to have_received(:find).with(id)
        expect(result).to eq vocabulary
      end
    end
    context "when given a term id" do
      let(:id) { "vocab/term" }
      it "should find a term" do
        expect(Term).to have_received(:find).with(id)
        expect(result).to eq term
      end
    end
  end
end
