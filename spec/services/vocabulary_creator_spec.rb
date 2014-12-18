require 'rails_helper'

RSpec.describe VocabularyCreator do
  let(:params) do
    {
      :id => id,
      :label => label,
      :comment => comment
    }
  end
  let(:id) { "Creator" }
  let(:label) { ["Test Label"] }
  let(:comment) { ["Test Comment"] }
  subject { VocabularyCreator.call(params) }
  before do
    stub_repository
  end

  describe "#call" do
    it "should call vocabulary" do
      expect_any_instance_of(VocabularyCreator).to receive(:vocabulary).at_least(1).times.and_call_original
      subject
    end
  end
  
  describe ".call.vocabulary" do
    let(:result) { subject.vocabulary }
    context "when given good parameters" do
      it "should return a Vocabulary" do
        expect(result).to be_kind_of Vocabulary
      end
      it "should have a good id" do
        expect(result.rdf_subject.to_s).to eq "http://opaquenamespace.org/ns/Creator"
      end
      it "should set attributes" do
        expect(result.label).to eq label
        expect(result.comment).to eq comment
      end
      it "should be persisted" do
        expect(result).to be_persisted
      end
      it "should have a true result" do
        result
        expect(subject.result).to eq true
      end
    end
    context "when given an already existing vocabulary" do
      before do
        Vocabulary.new(id).persist!
      end
      it "should have errors" do
        expect(result.errors).not_to be_empty
      end
      it "should have a false result" do
        result
        expect(subject.result).to eq false
      end
    end
    context "when given bad parameters" do
      let(:id) {nil}
      it "should not be valid" do
        expect(result).not_to be_valid
      end
      it "should not be persisted" do
        expect(result).not_to be_persisted
      end
      it "should have a false result" do
        result
        expect(subject.result).to eq false
      end
    end
  end
end
