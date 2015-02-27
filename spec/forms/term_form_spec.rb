require 'rails_helper'

RSpec.describe TermForm do
  subject { TermForm.new(vocabulary_form, repository) }
  let(:vocabulary_form) { VocabularyForm.new(term) }
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
    it "should be valid by default" do
      expect(subject).to be_valid
    end
    context "when the vocabulary doesn't exist" do
      let(:vocabulary_exists) { false }
      it "should not be valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:id]).to include "is in a non existent vocabulary"
      end
    end
  end
end
