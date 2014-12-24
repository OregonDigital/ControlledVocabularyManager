require 'rails_helper'

RSpec.describe TermCreator do
  subject { TermCreator.new(params, vocabulary, [callback]) }
  let(:params) do
    {
      :id => id,
      :label => ["Test Label"],
      :comment => ["Test Comment"]
    }
  end
  let(:id) { "testing" }
  fake(:vocabulary)
  let(:callback) { fake(:term_callback) }
  fake(:term)
  let(:vocabulary_exists) { true }
  let(:term_valid) { true }
  let(:term_id) { "#{vocabulary.id}/#{id}".gsub(/\/$/,'') }
  let(:error_empty) { true }
  before do
    stub(Term).new(term_id) { term }
    stub(Term).new(term_id+"/") { term }
    stub(term).id { term_id }
    stub(Term).exists?(term_id) { false }
    stub(vocabulary).persisted? { vocabulary_exists }
    stub(term).valid?{term_valid}
    stub(term).empty_errors? { error_empty }
  end

  describe "#call" do
    subject { TermCreator.call(params, vocabulary, callback) }
    fake(:term_creator)
    before do
      stub(TermCreator).new(params, vocabulary, callback) { term_creator }
    end
    it "should initialize and call perform" do
      subject
      expect(term_creator).to have_received.perform
    end
  end

  describe "#perform" do
    before do
      subject.perform
    end
    context "when given valid parameters" do
      it "should call success on callback" do
        expect(callback).to have_received.success(term, vocabulary)
      end
      it "should set attributes" do
        expect(term).to have_received(:attributes=, params.except(:id))
      end
      it "should persist the term" do
        expect(term).to have_received.persist!(:validate => true)
      end
    end
    context "when something has gone wrong" do
      let(:error_empty) { false }
      context "when term has errors" do
        it "should call failure on callback" do
          expect(callback).to have_received.failure(term, vocabulary)
        end
        it "should not call persist!" do
          expect(term).not_to have_received(:persist!)
        end
      end
      context "when term id is nil" do
        let(:id) { nil }
        it "adds errors to the term" do
          expect(term).to have_received.add_error(:id, anything)
        end
      end
      context "when the vocabulary is not persisted" do
        let(:vocabulary_exists) { false }
        it "adds errors to the term" do
          expect(term).to have_received.add_error(:id, anything)
        end
      end
      context "when the term IS persisted already" do
        before do
          stub(Term).exists?(term.id) { true }
          subject.perform
        end
        it "adds errors to the term" do
          expect(term).to have_received.add_error(:id, anything)
        end
      end
    end
  end
end
