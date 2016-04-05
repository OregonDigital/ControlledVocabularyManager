require 'rails_helper'

RSpec.describe TermType do
  it "should return 7 terms" do
    expect(TermType.terms.length).to eq(7)
  end
  it "should return 7 names" do
    expect(TermType.names.length).to eq(7)
  end
  it "should return 7 models" do
    expect(TermType.models.length).to eq(7)
  end
  context "when evaluating a vocabulary" do
    let(:term) { Vocabulary.new }
    it "should be a vocabulary" do
      expect(TermType.vocabulary?(term.type[0].to_s)).to be_truthy
    end
    it "should return 'Vocabulary'" do
      expect(TermType.name_for(term.type[0].to_s)).to eq("Vocabulary")
    end
  end
  context "when evaluating a term" do
    let(:term) { Term.new }
    it "should not be a vocabulary" do
      expect(TermType.vocabulary?(term.type[0].to_s)).to be_falsey
    end
    it "should return 'Generic Term'" do
      expect(TermType.name_for(term.type[0].to_s)).to eq("Generic Term")
    end
    it "should return '' for its url" do
      expect(TermType.url_for("Term")).to eq("")
    end
  end
end
