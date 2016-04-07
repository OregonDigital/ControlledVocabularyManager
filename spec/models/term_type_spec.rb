require 'rails_helper'

RSpec.describe TermType do
  it "should return 7 models" do
    expect(TermType.models.length).to eq(7)
  end
  it "should return 7 names" do
    expect(TermType.names.length).to eq(7)
  end
  it "should show all models having field 'date'" do
    expect(TermType.models_having_visible_property('date').length).to eq(7)
  end
  context "when evaluating a vocabulary" do
    let(:term) { Vocabulary.new }
    it "should be a vocabulary" do
      expect(TermType.vocabulary?(term.type[0].to_s)).to be_truthy
    end
    it "should return 'Vocabulary'" do
      expect(TermType.name_for(term.type[0].to_s)).to eq(Vocabulary.option_text)
    end
  end
  context "when evaluating a Term" do
    let(:term) { Term.new }
    it "should not be a vocabulary" do
      expect(TermType.vocabulary?(term.type[0].to_s)).to be_falsey
    end
    it "should return 'Generic Term'" do
      expect(TermType.name_for(term.type[0].to_s)).to eq(Term.option_text)
    end
    it "should return '' for its url" do
      expect(TermType.url_for("Term")).to eq(Term.uri)
    end
  end
  context "when evaluating a CorporateName" do
    let(:term) { CorporateName.new }
    it "should not be a vocabulary" do
      expect(TermType.vocabulary?(term.type[0].to_s)).to be_falsey
    end
    it "should return its option_text" do
      expect(TermType.name_for(term.type[0].to_s)).to eq(CorporateName.option_text)
    end
    it "should return its url" do
      expect(TermType.url_for("CorporateName")).to eq(CorporateName.uri)
    end
  end
  context "when evaluating a Concept" do
    let(:term) { Concept.new }
    it "should not be a vocabulary" do
      expect(TermType.vocabulary?(term.type[0].to_s)).to be_falsey
    end
    it "should return its option_text" do
      expect(TermType.name_for(term.type[0].to_s)).to eq(Concept.option_text)
    end
    it "should return its url" do
      expect(TermType.url_for("Concept")).to eq(Concept.uri)
    end
  end
  context "when evaluating a Geographic" do
    let(:term) { Geographic.new }
    it "should not be a vocabulary" do
      expect(TermType.vocabulary?(term.type[0].to_s)).to be_falsey
    end
    it "should return its option_text" do
      expect(TermType.name_for(term.type[0].to_s)).to eq(Geographic.option_text)
    end
    it "should return its url" do
      expect(TermType.url_for("Geographic")).to eq(Geographic.uri)
    end
  end
  context "when evaluating a PersonalName" do
    let(:term) { PersonalName.new }
    it "should not be a vocabulary" do
      expect(TermType.vocabulary?(term.type[0].to_s)).to be_falsey
    end
    it "should return its option_text" do
      expect(TermType.name_for(term.type[0].to_s)).to eq(PersonalName.option_text)
    end
    it "should return its url" do
      expect(TermType.url_for("PersonalName")).to eq(PersonalName.uri)
    end
  end
  context "when evaluating a Title" do
    let(:term) { Title.new }
    it "should not be a vocabulary" do
      expect(TermType.vocabulary?(term.type[0].to_s)).to be_falsey
    end
    it "should return its option_text" do
      expect(TermType.name_for(term.type[0].to_s)).to eq(Title.option_text)
    end
    it "should return its url" do
      expect(TermType.url_for("Title")).to eq(Title.uri)
    end
  end
  context "when evaluating a Topic" do
    let(:term) { Topic.new }
    it "should not be a vocabulary" do
      expect(TermType.vocabulary?(term.type[0].to_s)).to be_falsey
    end
    it "should return its option_text" do
      expect(TermType.name_for(term.type[0].to_s)).to eq(Topic.option_text)
    end
    it "should return its url" do
      expect(TermType.url_for("Topic")).to eq(Topic.uri)
    end
  end
end
