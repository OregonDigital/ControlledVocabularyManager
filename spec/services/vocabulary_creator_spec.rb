require 'rails_helper'

RSpec.describe VocabularyCreator do
  let(:params) do
    {
      :id => vocabulary.id,
      :label => label,
      :comment => comment
    }
  end
  let(:label) { ["Test Label"] }
  let(:comment) { ["Test Comment"] }
  let(:callback) { fake(:callback) { VocabulariesController::CreateResponder  }}
  let(:vocabulary) { vocabulary_mock }
  let(:persist_success) { true }
  subject { VocabularyCreator.call(params, callback) }
  before do
    stub_repository
    stub(Vocabulary).new(vocabulary.id) {vocabulary}
    stub(vocabulary).add_error(anything, anything)
    stub(Vocabulary).exists?(vocabulary.id) { false }
    stub(vocabulary).persist!(:validate => true) { persist_success }
  end

  describe ".call" do
    let(:result) { subject }
    context "when given good parameters" do
      before do
        subject
      end
      it "should call #success on the callback" do
        expect(callback).to have_received.success(vocabulary)
      end
      it "should instantiate a vocab with an ID" do
        expect(Vocabulary).to have_received.new(vocabulary.id)
      end
      it "should set attributes" do
        expect(vocabulary).to have_received(:attributes=, params.except(:id))
      end
      it "should persist" do
        expect(vocabulary).to have_received.persist!({:validate => true})
      end
    end
    context "when given an already existing vocabulary" do
      before do
        stub(Vocabulary).exists?(vocabulary.id) { true }
        stub(vocabulary).empty_errors? { false }
        subject
      end
      it "should have errors" do
        expect(vocabulary).to have_received.add_error(anything, anything)
      end
      it "should notify callbacks of failure" do
        expect(callback).to have_received.failure(vocabulary)
      end
    end
    context "when given bad parameters" do
      before do
        stub(vocabulary).empty_errors? { false }
        subject
      end
      it "should not be persisted" do
        expect(vocabulary).not_to have_received.persist!({:validate => true})
      end
      it "should notify callbacks of failure" do
        expect(callback).to have_received.failure(vocabulary)
      end
    end
  end
end
