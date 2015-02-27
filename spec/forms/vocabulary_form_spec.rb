
require 'rails_helper'

RSpec.describe VocabularyForm do
  subject { VocabularyForm.new(term_factory, params) }
  let(:term_factory) { Vocabulary }
  let(:params) do
    {
      :id => id,
      :comment => ["Comment"],
      :label => ["Label"]
    }
  end

  let(:id) { "term" }

  def id_exists(id, exists=true)
    allow(term_factory).to receive(:exists?).with(id).and_return(exists)
  end

  def stub_term_factory
    term = instance_double("Term")
    allow(term_factory).to receive(:new).and_return(term)
    allow(term).to receive(:attributes=)
    allow(term).to receive(:fields).and_return([:comment, :label])
    term
  end

  it "should set attributes" do
    term = stub_term_factory
    subject
    expect(term).to have_received(:attributes=).with(:comment => ["Comment"], :label => ["Label"])
  end

  describe "#editable_fields" do
    it "should delegate to Term" do
      term = stub_term_factory
      allow(term).to receive(:editable_fields).and_return([:label])

      expect(subject.editable_fields).to eq [:label]
    end
  end

  describe "validations" do
    it "should be valid by default" do
      expect(subject).to be_valid
    end
    context "when the term already exists" do
      before do
        id_exists(id)
      end
      it "should not be valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:id]).to include "already exists in the repository"
      end
    end
    context "when the id is blank" do
      let(:id) {""}
      it "should not be valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:id]).to include "can't be blank"
      end
    end
  end

  describe "#save" do
    context "when valid" do
      it "should return true" do
        expect(subject.save).to eq true
      end
    end
    context "when invalid" do
      let(:id) {""}
      it "should return false" do
        expect(subject.save).to eq false
      end
    end
  end
end
