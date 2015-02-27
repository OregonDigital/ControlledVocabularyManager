require 'rails_helper'

RSpec.describe TermForm do
  subject { TermForm.new(term_factory, params) }
  let(:term_factory) { TermFactory }
  let(:params) do
    {
      :vocabulary_id => "1",
      :id => id,
      :comment => ["Comment"],
      :label => ["Label"]
    }
  end

  let(:id) { "term" }
  let(:vocabulary_exists) { true }
  before do
    allow(term_factory).to receive(:exists?).and_return(false)
    id_exists("1", vocabulary_exists)
  end

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
