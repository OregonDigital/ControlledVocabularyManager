# frozen_string_literal: true

require 'rails_helper'
require 'terms_are_importable'

RSpec.describe ImportableTerm do
  xit "should not validate with TermIsUnique" do
    expect(described_class.validators).not_to include TermIsUnique
  end
  let(:list) { ImportableTermList.new( [Term.new(term_id)] ) }
  let(:list2) { ImportableTermList.new( [Term.new(term_id2)] ) }

  let(:term_id) { "blah" }
  let(:term_id2) { "I_exist" }
  let(:term) { Term.new(term_id2) }
  let(:validator) { TermsAreImportable.new }
  context "when a term in the list already exists" do
    before do
      term.persist!
    end
    it "should allow the unique term" do
      validator.validate(list)
      expect(list.errors.size).to be 0
    end
    it "should fail the duplicate term" do
      validator.validate(list2)
      expect(list2.errors.messages.to_s).to include("Id already exists")
    end
  end
end
