require 'rails_helper'

RSpec.describe TermCreator do
  subject { TermCreator.new(params, vocabulary, [callback]) }
  let(:params) do
    {
      :id => id,
      :creator => ["Creator"],
      :label => ["Label"]
    }
  end
  let(:id) { "testing" }
  let(:vocabulary) { vocabulary_mock }
  let(:vocabulary_persisted) { true }
  let(:callback) { instance_double("TermsController") }
  let(:term) { term_mock }
  let(:term_valid) { true }
  let(:errors) { instance_double("ActiveModel::Errors") }
  let(:error_empty) { true } 
  before do
    allow(Term).to receive(:new).with("#{vocabulary.id}/#{id}").and_return(term)
    allow(vocabulary).to receive(:persisted?).and_return(vocabulary_persisted)
    allow(term).to receive(:errors).and_return(errors)
    allow(term).to receive(:valid?).and_return(term_valid)
    allow(term).to receive(:attributes=)
    allow(errors).to receive(:empty?).and_return(error_empty)
  end

  describe "#call" do
    subject { TermCreator.call(params, vocabulary, callback) }
    it "should initialize and call perform" do
      i = instance_double("TermCreator")
      expect(TermCreator).to receive(:new).with(params, vocabulary, callback).and_return(i)
      expect(i).to receive(:perform)
      subject
    end
  end

  describe "#perform" do
    context "when given valid parameters" do
      before do
        allow(callback).to receive(:success).with(term, vocabulary)
        allow(term).to receive(:persist!)
      end
      it "should call success on callback" do
        expect(callback).to receive(:success).with(term, vocabulary)
        subject.perform
      end
      it "should set attributes" do
        expect(term).to receive(:attributes=).with(params.except(:id))
        subject.perform
      end
      it "should persist the term" do
        expect(term).to receive(:persist!).with(:validate => true)
        subject.perform
      end
    end
    end
  context "when something has gone wrong" do
    let(:error_empty) { false }
    before do
      allow(callback).to receive(:failure).with(term, vocabulary)
    end
    context "when term has errors" do
      it "should call failure on callback" do
        expect(callback).to receive(:failure).with(term, vocabulary)
        subject.perform
      end
      it "should not call persist!" do
        expect(term).not_to receive(:persist!)
        subject.perform
      end
    end
    context "when term id is nil" do
      let(:id) { nil }
      it "adds errors to the term" do
        expect(errors).to receive(:add).with(:id, anything)
        subject.perform
      end
    end
    context "when the vocabulary is not persisted" do
      let(:vocabulary_persisted) { false }
      it "adds errors to the term" do
        expect(errors).to receive(:add).with(:id, anything)
        subject.perform
      end
    end
    context "when the term IS persisted already" do
      before do
        allow(Term).to receive(:exists?).with(id).and_return(true)
      end
      it "adds errors to the term" do
        expect(errors).to receive(:add).with(:id, anything)
        subject.perform
      end
    end
  end
end
