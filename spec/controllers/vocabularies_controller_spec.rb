require 'rails_helper'

RSpec.describe VocabulariesController do
  describe "GET 'new'" do
    let(:result) { get 'new' }
    before do
      result
    end
    it "should be successful" do
      expect(result).to be_success
    end
    it "assigns @vocabulary" do
      assigned = assigns(:vocabulary)
      expect(assigned).to be_kind_of Vocabulary
      expect(assigned).to be_new_record
    end
    it "renders new" do
      expect(result).to render_template("new")
    end
  end

  describe "POST create" do
    let(:vocabulary_params) do
      {
        :label => ["Test1"],
        :comment => ["Test2"]
      }
    end
    let(:vocabulary_creator_core) { instance_double("VocabularyCreator") }
    let(:vocabulary_creator) do
      allow(vocabulary_creator_core).to receive(:result).and_return(create_result)
      allow(vocabulary_creator_core).to receive(:vocabulary).and_return(vocabulary)
      vocabulary_creator_core
    end
    let(:create_result) { true }
    let(:vocabulary) { instance_double("Vocabulary") }
    let(:result) { post 'create', :vocabulary => vocabulary_params }
    before do
      allow(VocabularyCreator).to receive(:call).and_return(vocabulary_creator)
      result
    end
    it "should call vocabulary creator" do
      expect(VocabularyCreator).to have_received(:call).with(vocabulary_params)
    end
    context "and vocabulary creator returns false" do
      let(:create_result) { false }
      it "should assign @vocabulary" do
        assigned = assigns(:vocabulary)
        expect(assigned).to eq vocabulary
      end
      it "should render new" do
        expect(result).to render_template("new")
      end
    end
    context "and vocabulary creator returns true" do
      it "should redirect" do
        expect(response).to be_redirect
      end
    end
  end
end
