# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeprecatePredicateForm do
  subject { DeprecatePredicateForm.new(vocabulary_form, repository) }
  let(:vocabulary_form) { VocabularyForm.new(term, Vocabulary) }
  let(:repository) { Vocabulary }
  let(:term) do
    t = Term.new("1/test")
    t.attributes = params
    t
  end
  let(:params) do
    {
      :comment => ["Comment"],
      :label => ["Label"]
    }
  end
  let(:vocabulary_exists) { true }

  before do
    allow(term.class).to receive(:exists?).and_return(false)
    id_exists("1", vocabulary_exists)
  end

  def id_exists(id, exists=true)
    allow(term.class).to receive(:exists?).with(id).and_return(exists)
  end

  describe "validations" do
    it "should not be valid by default" do
      expect(subject).not_to be_valid
      expect(subject.is_valid?).not_to be_truthy
    end
    context "when is_replaced_by is blank" do
      it "should not be valid" do
        expect(subject).not_to be_valid
        expect(subject.is_valid?).not_to be_truthy
        expect(subject.errors[:is_replaced_by]).to include "can't be blank"
      end
    end
    context "when is_replaced_by is valid" do
      let(:params) do
        {
          :comment => ["Comment"],
          :label => ["Label"],
          :is_replaced_by => ["http://bla.com/"]
        }
      end
      it "should be valid" do
        expect(subject).to be_valid
        expect(subject.is_valid?).to be_truthy
        expect(subject.errors[:is_replaced_by]).not_to include "can't be blank"
        expect(subject.errors[:is_replaced_by]).not_to include "invalid uri"
      end
    end
    context "when is_replaced_by is invalid" do
      let(:params) do
        {
          :comment => ["Comment"],
          :label => ["Label"],
          :is_replaced_by => ["bla"]
        }
      end

      it "should be invalid" do
        expect(subject).not_to be_valid
        expect(subject.is_valid?).not_to be_truthy
        expect(subject.errors[:is_replaced_by]).to include "invalid uri"
      end
    end
  end

  describe "#save" do
    context "when valid" do
      let(:params) do
        {
          :comment => ["Comment"],
          :label => ["Label"],
          :is_replaced_by => ["http://bla.com/"]
        }
      end
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
