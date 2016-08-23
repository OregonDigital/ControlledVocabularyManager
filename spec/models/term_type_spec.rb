require 'rails_helper'

RSpec.describe TermType do
  it "should return 6 models" do
    expect(TermType.models.length).to eq(6)
  end
  it "should return 6 names" do
    expect(TermType.names.length).to eq(6)
  end
  it "should show all models having field 'date'" do
    expect(TermType.models_having_visible_property('date').length).to eq(6)
  end


  # Run through all of the TermType related models as well as Vocabulary and Predicate
  TermType.models.concat(%w[Vocabulary Predicate]).each do |m|
    context "when evaluating #{m}" do
      let(:klass) { m.constantize }
      let(:term) { klass.new }
      if m == 'Vocabulary'
        it "should be a Vocabulary" do
          expect(TermType.vocabulary?(term.type[0].to_s)).to be_truthy
          expect(TermType.predicate?(term.type[0].to_s)).to be_falsey
        end
      elsif m == 'Predicate'
        it "should be a Predicate" do
          expect(TermType.vocabulary?(term.type[0].to_s)).to be_falsey
          expect(TermType.predicate?(term.type[0].to_s)).to be_truthy
        end
      else
        it "should not be a Vocabulary or a Predicate" do
          expect(TermType.vocabulary?(term.type[0].to_s)).to be_falsey
          expect(TermType.predicate?(term.type[0].to_s)).to be_falsey
        end
      end

      it "should return its name" do
        expect(TermType.name_for(term.type[0].to_s)).to eq(klass.option_text)
      end

      it "should return its url" do
        expect(TermType.url_for(m)).to eq(klass.uri)
      end

      it "should return the proper class" do
        expect(TermType.class_from_types(term.type)).to eq(klass)
      end
    end
  end
end
