require 'rails_helper'

RSpec.describe TermFactory do
  subject { TermFactory }

  describe ".find" do
    let(:id) { "test/1" }
    let(:term) do
      t = Term.new(id)
      t.persist!
      t
    end
    let(:result) { subject.find(id) }
    context "when a term exists" do
      before do
        term
      end
      it "should have found a Term" do
        expect(result.__getobj__).to be_kind_of Term
      end
    end
    context "when a Vocabulary exists" do
      let(:id) { "test" }
      let(:term) do
        t = Vocabulary.new(id)
        t.persist!
        t
      end
      before do
        term
      end
      it "should have found a Vocabulary" do
        expect(result).to be_persisted
        expect(result.__getobj__).to be_kind_of Vocabulary
      end
    end
    it "should decorate it" do
      term

      new_result = result
      [TermWithChildren, SetsModified, Term].each do |klass|
        expect(new_result).to be_instance_of(klass)
        new_result = new_result.__getobj__ if new_result.respond_to?(:__getobj__)
      end
    end
  end
end
