require 'rails_helper'

RSpec.describe VocabularyInjector do
  subject { described_class.new(params) }
  let(:params) do
    {
    }
  end

  describe "#all_vocabs_query" do
    let(:query) { instance_double("PaginatableTerms") }
    before do
      allow(PaginatableTerms).to receive(:new).and_return(query)
      allow(query).to receive(:page).and_return(query)
      allow(query).to receive(:per).and_return(query)
      subject.all_vocabs_query.call
    end
    context "when there's no page argument" do
      it "should instantiate" do
        expect(query).to have_received(:page).with(1)
        expect(query).to have_received(:per).with(10)
      end
    end
    context "when there's a page argument" do
      let(:params) do
        { :page => "1" }
      end
      it "should set page" do
        expect(query).to have_received(:page).with(1)
        expect(query).to have_received(:per).with(10)
      end
      context "and it's set to a future page" do
        let(:params) do
          { :page => "2" }
        end
        it "should set page" do
          expect(query).to have_received(:page).with(2)
        end
      end
    end
  end
end
