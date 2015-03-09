require 'rails_helper'

RSpec.describe VocabularyInjector do
  subject { described_class.new(params) }
  let(:params) do
    {
    }
  end

  describe "#all_vocabs_query" do
    let(:query) { instance_double("AllVocabsQuery") }
    before do
      allow(AllVocabsQuery).to receive(:new).and_return(query)
      allow(query).to receive(:all)
      subject.all_vocabs_query.call
    end
    context "when there's no page argument" do
      it "should instantiate" do
        expect(AllVocabsQuery).to have_received(:new).with(anything, {})
        expect(query).to have_received(:all)
      end
    end
    context "when there's a page argument" do
      let(:params) do
        { :page => "1" }
      end
      it "should set limit and offset" do
        expect(AllVocabsQuery).to have_received(:new).with(anything, {:limit => 10, :offset => 0})
      end
      context "and it's set to a future page" do
        let(:params) do
          { :page => "2" }
        end
        it "should set limit and offset correctly" do

          expect(AllVocabsQuery).to have_received(:new).with(anything, {:limit => 10, :offset => 10})
        end
      end
    end
  end
end
