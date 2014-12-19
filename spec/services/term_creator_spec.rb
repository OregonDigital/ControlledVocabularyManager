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
  let(:vocabulary) { instance_double("Vocabulary") }
  let(:vocabulary) do
    v = instance_double("Vocabulary")
    allow(v).to receive(:id).and_return(vocabulary_id)
    v
  end
  let(:vocabulary_id) { "bla/bla" }
  let(:vocabulary_persisted) { true }
  let(:callback) { double("callback") }
  let(:term) { instance_double("Term") }
  let(:term_persisted) { false }
  let(:term_valid) { true }
  let(:errors) { double("errors") }
  let(:error_empty) { true } 
  before do
    allow(Term).to receive(:new).with("bla/bla/testing").and_return(term)
    allow(vocabulary).to receive(:persisted?).and_return(vocabulary_persisted)
    allow(term).to receive(:persisted?).and_return(term_persisted)
    allow(term).to receive(:errors).and_return(errors)
    allow(term).to receive(:valid?).and_return(term_valid)
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
        allow(callback).to receive(:success).with(term)
        allow(term).to receive(:persist!)
      end
      it "should call success on callback" do
        expect(callback).to receive(:success).with(term)
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
      allow(callback).to receive(:failure).with(term)
    end
    context "when term has errors" do
      it "should call failure on callback" do
        expect(callback).to receive(:failure).with(term)
        subject.perform
      end
      it "should not call persist!" do
        expect(term).not_to receive(:persist!)
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
      let(:term_persisted) { true }
      it "adds errors to the term" do
        expect(errors).to receive(:add).with(:id, anything)
        subject.perform
      end
    end
  end
end
