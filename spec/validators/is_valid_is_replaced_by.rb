require 'rails_helper'
require 'term_is_sanitary'

RSpec.describe IsValidIsReplacedBy do
  let(:term_id) { "test" }
  let(:is_replaced_by) { "http://bla.com/" }
  let(:record) { Term.new(term_id) }
  let(:validator) { described_class.new }
  it "it should have more than one error" do
    validator.validate(record)
    expect(record.errors.size).to be > 0
  end
  describe "a term being deprecated" do
    it "it should pass validation when is_replaced_by is valid" do
      record.is_replaced_by = [is_replaced_by]
      validator.validate(record)
      expect(record.errors.size).to be 0
    end
    it "it should fail validation when is_replaced_by is blank" do
      validator.validate(record)
      expect(record.errors[:is_replaced_by].first).to include("can't be blank")
    end
  end
  describe "a term being deprecated with invalid is_replaced_by" do
    let(:is_replaced_by) { "bla" }
    it "it should fail validation when is_replaced_by is invalid" do
      record.is_replaced_by = [is_replaced_by]
      validator.validate(record)
      expect(record.errors[:is_replaced_by].first).to include("invalid uri")
    end
  end
end
