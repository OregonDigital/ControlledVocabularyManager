require 'rails_helper'

RSpec.describe ControlledVocabManager::IsoLanguageTranslator do
  let(:translator) {described_class}

  describe "#language_list" do
    context "When requesting a list with symbol access" do
      it "should return a list of ISO_639 languages with symbol access" do
        expect(translator.language_list(:symbol)).to be_kind_of Hash
        expect(translator.language_list(:symbol).length).to eq ISO_639::ISO_639_1.length
        expect(translator.language_list(:symbol)[:de]).to eq "German"
      end
    end
    context "When requesting a list with string access" do
      it "should return a list of ISO_639 languages with symbol access" do
        expect(translator.language_list(:string)).to be_kind_of Hash
        expect(translator.language_list(:string).length).to eq ISO_639::ISO_639_1.length
        expect(translator.language_list(:string)["German"]).to eq :de
      end
    end
    context "When requesting a list with no args" do
      it "should default to symbol access" do
        expect(translator.language_list[:de]).to eq "German"
      end
    end
  end

  describe "#find_by_name" do
    it "should return a symbol for the language name" do
      expect(translator.find_by_name("German")).to eq :de
      expect(translator.find_by_name("german")).to eq :de
    end
  end

  describe "#find_by_symbol" do
    it "should return a string for the language symbol" do
      expect(translator.find_by_symbol(:de)).to eq "German"
      expect(translator.find_by_symbol(:banana)).to eq "Language Not Found"
    end
  end

end
