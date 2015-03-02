require 'rails_helper'

RSpec.describe VocabulariesController do
  let(:logged_in) { true }
  before do
    allow(controller).to receive(:check_auth).and_return(true) if logged_in
  end

  describe "GET 'new'" do
    let(:result) { get 'new' }
    before do
      result
    end
    context "when logged out" do
      let(:logged_in) { false }
      it "should require login" do
        expect(result).to redirect_to login_path
      end
    end
    it "should be successful" do
      expect(result).to be_success
    end
    it "assigns @vocabulary" do
      assigned = assigns(:vocabulary)
      expect(assigned).to be_kind_of VocabularyForm
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
    context "when not logged in" do
      let(:logged_in) { false }
      it "should not redirect" do
        expect(response).not_to be_redirect
      end
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
    let(:vocabulary_form) { VocabularyForm.new(vocabulary, Vocabulary) }
    let(:result) { post 'create', :vocabulary => vocabulary_params }
    let(:save_success) { true }
    before do
      allow(VocabularyForm).to receive(:new).and_return(vocabulary_form)
      allow(Vocabulary).to receive(:new).and_return(vocabulary)
      allow(vocabulary_form).to receive(:save).and_return(save_success)
      allow(vocabulary).to receive(:id).and_return("test")
      allow(vocabulary).to receive(:attributes=)
      post 'create', :vocabulary => vocabulary_params 
    end
    it "should save term form" do
      expect(vocabulary_form).to have_received(:save)
    end
    context "when blank arrays are passed in" do
      let(:vocabulary_params) do
        {
          :label => ["test"],
          :comment => [""]
        }
      end
      it "should not pass them to vocabulary" do
        expect(vocabulary).to have_received(:attributes=).with({"label" => ["test"], "comment" => []})
      end
    end
    context "when save fails" do
      let(:save_success) { false }
      it "should render new template" do
        expect(response).to render_template("new")
      end
      it "should assign @vocabulary" do
        expect(assigns(:vocabulary)).to eq vocabulary_form
      end
    end
    context "when all goes well" do
      it "should redirect to the term" do
        expect(response).to redirect_to("/ns/#{vocabulary.id}")
      end
    end
  end
end
