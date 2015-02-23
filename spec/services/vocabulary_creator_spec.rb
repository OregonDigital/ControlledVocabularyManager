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
  let(:callback) { double("callback") }
  let(:vocabulary) { vocabulary_mock }
  let(:persist_success) { true }
  let(:error_double) { double("errors") }
  subject { VocabularyCreator.call(params, callback) }
  before do
    stub_repository
    allow(class_double("Vocabulary").as_stubbed_const).to receive(:new).and_return(vocabulary)
    allow(vocabulary).to receive(:errors).and_return(error_double)
    allow(Vocabulary).to receive(:exists?).and_return(false)
    allow(vocabulary).to receive(:persist!).and_return(persist_success)
    allow(vocabulary).to receive(:attributes=)
    allow(vocabulary).to receive(:id).and_return(id)
    allow(error_double).to receive(:empty?).and_return(true)
  end

  describe ".call" do
    let(:result) { subject }
    context "when given good parameters" do
      before do
        allow(callback).to receive(:success)
      end
      it "should call #success on the callback" do
        expect(callback).to receive(:success).with(vocabulary)
        subject
      end
      it "should instantiate a vocab with an ID" do
        expect(Vocabulary).to receive(:new).with(id)
        subject
      end
      it "should set attributes" do
        expect(vocabulary).to receive(:attributes=).with(params.except(:id))
        subject
      end
      it "should persist" do
        expect(vocabulary).to receive(:persist!)
        subject
      end
    end
    context "when given an already existing vocabulary" do
      before do
        allow(Vocabulary).to receive(:exists?).with(id).and_return(true)
        allow(error_double).to receive(:add)
        allow(error_double).to receive(:empty?).and_return(false)
        allow(callback).to receive(:failure)
      end
      it "should have errors" do
        allow(vocabulary).to receive(:errors).and_return(error_double)
        expect(error_double).to receive(:add)
        expect(error_double).to receive(:empty?).and_return(false)
        subject
      end
      it "should notify callbacks of failure" do
        expect(callback).to receive(:failure).with(vocabulary)
        subject
      end
    end
    context "when given bad parameters" do
      before do
        expect(error_double).to receive(:empty?).and_return(false)
        allow(callback).to receive(:failure)
      end
      it "should not be persisted" do
        expect(vocabulary).not_to receive(:persist!)
        subject
      end
      it "should notify callbacks of failure" do
        expect(callback).to receive(:failure).with(vocabulary)
        subject
      end
    end
  end
end
