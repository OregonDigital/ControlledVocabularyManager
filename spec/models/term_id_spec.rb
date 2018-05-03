require 'rails_helper'

RSpec.describe TermID do
  subject { TermID.new(id) }
  let(:id) { "vocab" }

  describe "#initialize" do
    let(:subject_minted) { TermID.new(nil) }
    it "should not be blank" do
      expect(subject_minted.to_s).not_to be_empty
    end
    it "should be 8 characters long" do
      expect(subject_minted.to_s.length).to eq 8
    end
  end

  describe "#to_s" do
    it "should be the string" do
      expect(subject.to_s).to eq id
    end
  end

  describe "#vocabulary?" do
    let(:result) { subject.vocabulary? }
    context "when given a vocabulary id" do
      it "should return true" do
        expect(result).to eq true
      end
    end
    context "when given a term id" do
      let(:id) { "vocab/term" }
      it "should return false" do
        expect(result).to eq false
      end
    end
    context "when given a vocabulary URI" do
      let(:id) { RDF::URI("http://opaquenamespace.org/ns/vocab") }
      it "should return true" do
        expect(result).to eq true
      end
    end
    context "when given a term URI" do
      let(:id) { RDF::URI("http://opaquenamespace.org/ns/vocab/term") }
      it "should return false" do
        expect(result).to eq false
      end
    end
  end
end
