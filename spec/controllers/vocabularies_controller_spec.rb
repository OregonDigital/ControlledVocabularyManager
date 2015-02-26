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

  describe "GET 'index'" do
    context "when there are vocabularies" do
      let(:vocabulary) { vocabulary_mock }
      before do
        allow(vocabulary).to receive(:repository).and_return(Vocabulary.new.repository)
        allow(AllVocabsQuery).to receive(:call).with(vocabulary.repository.query_client).and_return([vocabulary])
      end
      it "should set @vocabularies to all vocabs" do
        get :index

        expect(assigns(:vocabularies)).to eq [vocabulary]
      end
    end
    it "should be successful" do
      get :index

      expect(response).to be_success
    end
    it "renders index" do
      get :index

      expect(response).to render_template "index"
    end
  end

  describe "POST create" do
    let(:vocabulary_params) do
      {
        :label => ["Test1"],
        :comment => ["Test2"]
      }
    end
    let(:vocabulary) { instance_double("Vocabulary") }
    let(:result) { post 'create', :vocabulary => vocabulary_params }
    let(:responder_class) {class_double("VocabulariesController::CreateResponder").as_stubbed_const}
    let(:responder) {instance_double("VocabulariesController::CreateResponder")}
    before do
      expect(VocabulariesController::CreateResponder).to receive(:new).with(controller).and_return(responder)
      allow(VocabularyCreator).to receive(:call)
      allow(controller).to receive(:render)
      result
    end
    it "should call vocabulary creator" do
      expect(VocabularyCreator).to have_received(:call).with(vocabulary_params, responder)
    end
    context "when blank values are passed in" do
      let(:vocabulary_params) do
        {
          :label => [""],
          :comment => ["Test2"]
        }
      end
      it "should not pass them through to VocabularyCreator" do
        expect(VocabularyCreator).to have_received(:call).with({:label => [], :comment => ["Test2"]}, anything)
      end
    end
  end

  describe "Create Responder" do
    subject { VocabulariesController::CreateResponder.new(controller) }
    let(:vocabulary) { Vocabulary.new }
    let(:result) { post 'create', :vocabulary => {} }
    describe "#success" do
      before do
        allow(VocabularyCreator).to receive(:call) do
          subject.success(vocabulary)
        end
        allow(vocabulary).to receive(:id).and_return("1")
        allow(vocabulary).to receive(:persisted?).and_return(true)
        result
      end
      it "should redirect" do
        expect(response).to redirect_to "/ns/1"
      end
    end
    describe "#failure" do
      before do
        allow(VocabularyCreator).to receive(:call) do
          subject.failure(vocabulary)
        end
        allow(vocabulary).to receive(:id).and_return("1")
        allow(vocabulary).to receive(:persisted?).and_return(true)
      end
      it "render new" do
        result
        expect(response).to render_template "new"
      end
      it "assigns @vocabulary" do
        result
        expect(assigns(:vocabulary)).to eq vocabulary
      end
    end
  end
end
