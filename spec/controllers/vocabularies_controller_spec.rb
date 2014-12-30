require 'rails_helper'

RSpec.describe VocabulariesController do
  describe "GET 'new'" do
    fake(:vocabulary)
    let(:result) { get 'new' }
    before do
      stub(Vocabulary).new { vocabulary }
      result
    end
    it "should be successful" do
      expect(result).to be_success
    end
    it "assigns @vocabulary" do
      expect(assigns(:vocabulary)).to eq vocabulary
    end
    it "renders new" do
      expect(result).to render_template("new")
    end
  end

  describe "GET 'index'" do
    before do
      get :index
    end
    it "should be successful" do
      expect(response).to be_success
    end
    it "renders index" do
      expect(response).to render_template "index"
    end
  end

  describe "POST create" do
    fake(:vocabulary)
    fake(:term_callback)
    let(:vocabulary_params) do
      {
        "label" => ["Test1"],
        "comment" => ["Test2"]
      }
    end
    let(:result) { post 'create', :vocabulary => vocabulary_params }
    before do
      stub(VocabulariesController::CreateResponder).new(controller) { term_callback }
      stub(VocabularyCreator).call(any_args) do
        controller.render :nothing => true
      end
      result
    end
    it "should call vocabulary creator" do
      expect(VocabularyCreator).to have_received.call(vocabulary_params, term_callback)
    end
  end

  describe "Create Responder" do
    subject { VocabulariesController::CreateResponder.new(controller) }
    let(:vocabulary) { Vocabulary.new("Creator") }
    let(:result) { post 'create', :vocabulary => {} }
    before do
      stub(vocabulary).persisted? { true }
    end
    describe "#success" do
      before do
        stub(controller).create do
          subject.success(vocabulary)
        end
        result
      end
      it "should redirect" do
        expect(response).to redirect_to "/ns/Creator"
      end
    end
    describe "#failure" do
      before do
        stub(controller).create do
          subject.failure(vocabulary)
        end
        result
      end
      it "render new" do
        expect(response).to render_template "new"
      end
      it "assigns @vocabulary" do
        expect(assigns(:vocabulary)).to eq vocabulary
      end
    end
  end
end
