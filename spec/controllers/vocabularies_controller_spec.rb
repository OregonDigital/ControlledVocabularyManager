require 'rails_helper'
require 'rugged'
require 'support/test_git_setup'

RSpec.describe VocabulariesController do
  include TestGitSetup
  let(:user) { User.create(:email => 'blah@blah.com', :password => "admin123",:role => "admin", :institution => "Oregon State University", :name => "Test")}

  before do
    sign_in(user) if user
    setup_git
  end
  after do
    FileUtils.rm_rf(ControlledVocabularyManager::Application::config.rugged_repo)
  end

  describe "GET 'new'" do
    let(:result) { get 'new' }
    before do
      result
    end
    context "when logged out" do
      let(:user) { }
      it "should require login" do
        expect(result.body).to have_content("Only admin can access")
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

  describe "GET 'edit'" do
    let(:vocabulary_form) { instance_double("VocabularyForm") }
    let(:vocabulary) { vocabulary_mock }
    before do
      allow_any_instance_of(VocabularyFormRepository).to receive(:find).and_return(vocabulary_form)
      allow(vocabulary).to receive(:attributes=)
      get 'edit', :id => vocabulary.id
    end
    it "should assign @term" do
      expect(assigns(:term)).to eq vocabulary_form
    end
    it "should render edit" do
      expect(response).to render_template 'edit'
    end
  end

  describe "PATCH 'update'" do
    let(:vocabulary) { vocabulary_mock }
    let(:injector) { VocabularyInjector.new }
    let(:twc) { TermWithoutChildren.new(vocabulary) }
    let(:voc_mod) { SetsModified.new(twc) }
    let(:vocabulary_form) { VocabularyForm.new(SetsAttributes.new(voc_mod), Vocabulary) }
    let(:params) do
      {
        :id => "blah",
        :comment => ["Test"],
        :label => ["Test"],
        :language => {
          :label => ["en"],
          :comment => ["en"]
        },
      }
    end
    let(:persist_success) { true }

    before do
      stub_repository
      allow_any_instance_of(VocabularyFormRepository).to receive(:find).and_return(vocabulary_form)
      single_graph = instance_double("RDF::Graph")
      allow(vocabulary_form).to receive(:sort_stringify).and_return("blah")
      allow(vocabulary_form).to receive(:single_graph).and_return(single_graph)
      allow(vocabulary).to receive(:blacklisted_language_properties).and_return([:id, :issued, :modified, :is_replaced_by,:date, :same_as, :is_defined_by])
      allow(vocabulary).to receive(:attributes=)
      allow(vocabulary_form).to receive(:is_valid?).and_return(true)
      allow(vocabulary).to receive(:attributes).and_return(params)
      allow(vocabulary).to receive(:valid?)
      patch :update, :id => vocabulary.id, :vocabulary => params, :is_replaced_by => ["test"]
    end

    context "when the fields are edited" do
      it "should update the properties" do
        expect(vocabulary).to have_received(:attributes=).with({:comment=>[RDF::Literal("Test", :language => :en)], :label=>[RDF::Literal("Test", :language => :en)]}).exactly(1).times
      end
      it "should redirect to the index" do
        expect(response).to redirect_to("/vocabularies")
      end
      context "and there are blank fields" do
        let(:params) do
          {
            :comment => [""],
            :label => ["Test"],
              :language => {
                :label => ["en"]
              }
          }
        end
        it "should ignore them" do
          expect(vocabulary).to have_received(:attributes=).with(:comment => [], :label => ["Test"])
        end
      end
    end

    context "when the fields are edited and the update fails" do
      before do
        allow(vocabulary_form).to receive(:is_valid?).and_return(false)
        patch :update, :id => vocabulary.id, :vocabulary => params, :is_replaced_by => ["test"]
      end
      it "should show the edit form" do
        expect(assigns(:term)).to eq vocabulary_form
        expect(response).to render_template("edit")
      end
    end
  end

  describe "PATCH 'deprecate_only'" do
    let(:vocabulary) { vocabulary_mock }
    let(:injector) { VocabularyInjector.new }
    let(:twc) { TermWithoutChildren.new(vocabulary) }
    let(:vocabulary_form) { DeprecateVocabularyForm.new(SetsAttributes.new(twc), Vocabulary) }
    let(:params) do
      {
        :id => "blah",
        :comment => ["Test"],
        :label => ["Test"],
        :is_replaced_by => ["test"],
        :language => {
          :label => ["en"],
          :comment => ["en"]
        },
      }
    end
    let(:persist_success) { true }

    before do
      allow_any_instance_of(DeprecateVocabularyFormRepository).to receive(:find).and_return(vocabulary_form)
      stub_repository
      single_graph = instance_double("RDF::Graph")
      allow(vocabulary_form).to receive(:sort_stringify).and_return("blah")
      allow(vocabulary_form).to receive(:single_graph).and_return(single_graph)
      allow(vocabulary).to receive(:blacklisted_language_properties).and_return([:id, :issued, :modified, :is_replaced_by,:date, :same_as, :is_defined_by])
      allow(vocabulary).to receive(:attributes=)
      allow(vocabulary).to receive(:is_replaced_by=)
      allow(vocabulary).to receive(:persist!).and_return(persist_success)
      allow(vocabulary_form).to receive(:valid?).and_return(true)
      allow(vocabulary).to receive(:attributes).and_return(params)
      allow(vocabulary).to receive(:is_replaced_by).and_return(params[:is_replaced_by])
      patch :deprecate_only, :id => vocabulary.id, :vocabulary => params, :is_replaced_by => ["test"]
    end

    context "when the fields are edited" do
      it "should update the replaced_by property" do
        expect(vocabulary).to have_received(:is_replaced_by=).with(params[:is_replaced_by])
      end
      it "should redirect to the index" do
        expect(response).to redirect_to("/vocabularies")
      end
    end

    context "when the fields are edited and the update fails" do
      before do
        allow(vocabulary_form).to receive(:is_valid?).and_return(false)
        patch :deprecate_only, :id => vocabulary.id, :vocabulary => params, :is_replaced_by => ["test"]
      end
      it "should show the edit form" do
        expect(assigns(:term)).to eq vocabulary_form
        expect(response).to render_template("deprecate")
      end
    end
  end


  describe "GET 'index'" do
    context "when there are vocabularies" do
      let(:injector) { VocabularyInjector.new }
      let(:aa_vocab) {
        a_v = Vocabulary.new("aa")
        a_v.label = "AA"
        a_v
      }
      let(:bb_vocab) {
        b_v = Vocabulary.new("bb")
        b_v.label = "BB"
        b_v
      }
      before do
        allow(aa_vocab).to receive(:repository).and_return(Vocabulary.new.repository)
        allow(bb_vocab).to receive(:repository).and_return(Vocabulary.new.repository)
        allow(AllVocabsQuery).to receive(:call).and_return([bb_vocab, aa_vocab])
      end
      it "should set @vocabularies to all vocabs sorted alphabetically" do
        get :index
        expect(assigns(:vocabularies)).to eq [aa_vocab, bb_vocab]
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
          :id => "blah",
          :label => ["test"],
          :comment => ["blah"],
          :language => {
            :label => ["en"],
            :comment => ["en"]
          }
        }
    end
    let(:injector) { VocabularyInjector.new }
    let(:twc) { TermWithoutChildren.new(vocabulary) }
    let(:voc_iss) { SetsIssued.new(twc) }
    let(:voc_mod) { SetsModified.new(voc_iss) }
    let(:voc_res) { AddResource.new(voc_mod) }
    let(:vocabulary) { instance_double("Vocabulary") }
    let(:vocabulary_form) { VocabularyForm.new(SetsAttributes.new(voc_res), Vocabulary) }
    let(:result) { post 'create', :vocabulary => vocabulary_params }
    let(:save_success) { true }
    before do
      stub_repository
      single_graph = instance_double("RDF::Graph")
      allow(vocabulary_form).to receive(:single_graph).and_return(single_graph)
      allow(vocabulary_form).to receive(:sort_stringify).and_return("blah")
      allow_any_instance_of(VocabularyFormRepository).to receive(:new).and_return(vocabulary_form)
      allow(vocabulary_form).to receive(:is_valid?).and_return(true)
      allow(vocabulary).to receive(:blacklisted_language_properties).and_return([:id, :issued, :modified])
      allow(vocabulary).to receive(:id).and_return("test")
      allow(vocabulary).to receive(:attributes=)
      allow(vocabulary).to receive(:attributes).and_return(vocabulary_params)
      allow(vocabulary).to receive(:valid?)
      post 'create', :vocabulary => vocabulary_params
    end

    context "when blank arrays are passed in" do
      let(:vocabulary_params) do
        {
          :id => "blah",
          :label => ["test"],
          :comment => [""],
          :language => {
            :label => ["en"],
            :comment => ["en"]
          }
        }
      end
      it "should not pass them to vocabulary" do
        expect(vocabulary).to have_received(:attributes=).with({"label" => ["test"], "comment" => []})
      end
    end
    context "when check fails" do
      before do
        allow(vocabulary_form).to receive(:is_valid?).and_return(false)
        post 'create', :vocabulary => vocabulary_params
      end
      it "should render new template" do
        expect(response).to render_template("new")
      end
      it "should assign @vocabulary" do
        expect(assigns(:vocabulary)).to eq vocabulary_form
      end
    end
    context "when all goes well" do
      it "should redirect to the index" do
        expect(response).to redirect_to("/vocabularies")
      end
    end
  end
  describe "mark_reviewed" do
    let(:vocabulary) { vocabulary_mock }
    let(:vocab_id) { "blah" }
    let(:params) do
    {
      :id => vocab_id,
      :vocabulary => {
        :label => ["Test"],
        :comment => ["Comment"],
        :language => {
          :label => ["en"],
        :comment => ["en"]}}
      }
    end
    let(:save_success) { true }
    let(:vocab_form) { VocabularyForm.new(term, StandardRepository.new(nil,Vocabulary))}
    before do
      allow(vocabulary).to receive(:new_record?).and_return(true)
      allow_any_instance_of(VocabularyForm).to receive(:save).and_return(save_success)
      allow_any_instance_of(GitInterface).to receive(:reassemble).and_return(vocabulary)
      allow_any_instance_of(GitInterface).to receive(:rugged_merge)
      get :mark_reviewed, :id =>params[:id]

    end
    context "when the item has been reviewed" do
      it "will redirect to review queue if asset is saved" do
        expect(flash[:notice]).to include("blah has been saved")
        expect(response).to redirect_to("/review")
      end
    end
  end
end
