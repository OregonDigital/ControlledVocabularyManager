# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PolymorphicTermRepository do

  describe ".new" do

    context "when given a vocab id" do
      subject { PolymorphicTermRepository.new(Vocabulary) }
      let(:id) { "vocab" }
      let(:result) { subject.new(id) }

      it "should return a Vocabulary" do
        expect(result).to be_instance_of Vocabulary
      end
    end

    context "when given a term id" do
      subject { PolymorphicTermRepository.new(Term) }
      let(:id) { "vocab/term" }
      let(:result) { subject.new(id) }

      it "should return a Term" do
        expect(result).to be_instance_of Term
      end
    end
  end

  describe ".find" do

    let(:id) { "vocab" }
    let(:result) { subject.find(id) }
    let(:vocabulary) { double("vocabulary") }
    let(:term) { double("term")}
    context "when given a vocab id" do
      subject { PolymorphicTermRepository.new(Vocabulary) }
      before do
        allow(Vocabulary).to receive(:find).and_return(vocabulary)
        result
      end
      it "should find a vocabulary" do
        expect(Vocabulary).to have_received(:find).with(id)
        expect(result).to eq vocabulary
      end
    end
    context "when given a term id" do
      subject { PolymorphicTermRepository.new(Term) }
      let(:id) { "vocab/term" }
      before do
        allow(Term).to receive(:find).and_return(term)
        result
      end
      it "should find a term" do
        expect(Term).to have_received(:find).with(id)
        expect(result).to eq term
      end
    end
  end
end
