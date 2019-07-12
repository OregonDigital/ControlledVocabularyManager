# frozen_string_literal: true

require 'rails_helper'

WebMock.allow_net_connect!

RSpec.describe VocabularyForm do
  subject { VocabularyForm.new(term, repository) }
  let(:term) do
    t = Vocabulary.new(id)
    t.attributes = params
    t
  end
  let(:repository) { Vocabulary }
  let(:id) { "term" }
  let(:params) do
    {
      :comment => ["Comment"],
      :label => ["Label"]
    }
  end

  def id_exists(id, exists=true)
    allow(term.class).to receive(:exists?).with(id).and_return(exists)
  end

  def stub_term_factory
    allow(term).to receive(:attributes=)
    allow(term).to receive(:fields).and_return([:comment, :label])
    term
  end

  describe "#editable_fields" do
    it "should delegate to Term" do
      term = stub_term_factory
      allow(term).to receive(:editable_fields).and_return([:label])

      expect(subject.editable_fields).to eq [:label]
    end
  end

  describe "validations" do
    let(:id) { "brandnew-blah" }
    it "should be valid by default" do
      allow(subject).to receive(:valid?).and_return(true)
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
        allow(subject).to receive(:valid?).and_return(true)
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
