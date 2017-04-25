require 'rails_helper'
require 'rugged'
require 'support/test_git_setup'

RSpec.describe RelationshipsController do
  include TestGitSetup
  let(:user) { User.create(:email => 'blah@blah.com', :password => "admin123",:role => "admin reviewer editor", :institution => "Oregon State University", :name => "Test")}

  before do
    sign_in(user) if user
    setup_git
  end
  after do
    FileUtils.rm_rf(ControlledVocabularyManager::Application::config.rugged_repo)
  end

  describe "Get 'new'" do
    let(:result) { get :new, :term_id => "test/bla" }
    let(:term_form) { TermForm.new(term_mock, instance_double("TermFormRepository")) }
    before do
      allow_any_instance_of(TermFormRepository).to receive(:find).and_return(term_form)
      result
    end
    it "should be successful" do
      expect(result).to be_success
    end
    it "assigns @relationship" do
      relationship = assigns(:relationship)
      term = assigns(:term)
      expect(relationship).to be_kind_of RelationshipForm
      expect(term).to be_kind_of TermForm
      expect(relationship).to be_new_record
    end
    it "renders new" do
      expect(result).to render_template("new")
    end
  end
  describe "GET 'edit'" do
    let(:relationship_form) { instance_double("RelationshipForm") }
    let(:relationship) { relationship_mock }
    before do
      allow_any_instance_of(RelationshipFormRepository).to receive(:find).and_return(relationship_form)
      allow(relationship).to receive(:attributes=)
      get 'edit', :id => relationship.id
    end
    it "should assign @term" do
      expect(assigns(:relationship)).to eq relationship_form
    end
    it "should render edit" do
      expect(response).to render_template 'edit'
    end
  end

  describe "PATCH 'update'" do
    let(:relationship) { relationship_mock }
    let(:twc) { TermWithoutChildren.new(relationship)}
    let(:rel_mod) { SetsModified.new(twc) }
    let(:relationship_form) { RelationshipForm.new(SetsAttributes.new(rel_mod), Relationship) }
    let(:relationship_params) { {:id => "blah"} }
    let(:params) do
      {
        :hier_parent => ["parent"],
        :hier_child => ["child"],
        :comment => ["Test"],
        :label => ["Test"],
        :language => {
          :label => ["en"],
          :comment => ["en"],
          :hier_child => ["en"],
          :hier_parent => ["en"]
        }
      }
    end
    let(:persist_success) { true }

    before do
      stub_repository
      allow_any_instance_of(RelationshipFormRepository).to receive(:find).and_return(relationship_form)
      allow(relationship).to receive(:blacklisted_language_properties).and_return([:id, :issued, :modified])
      full_graph = instance_double("RDF::Graph")
      allow(relationship_form).to receive(:sort_stringify).and_return("blah")
      allow(relationship_form).to receive(:single_graph).and_return(full_graph)
      allow(relationship).to receive(:attributes=)
      allow(relationship_form).to receive(:valid?).and_return(true)
      allow(relationship).to receive(:attributes).and_return(params)
      allow(relationship).to receive(:valid?)

    end

    context "when the fields are edited" do
      before do
        patch :update, :id => relationship.id, :relationship => params, :vocabulary => params
      end
      it "should update the properties" do
         expect(relationship).to have_received(:attributes=).with({:hier_parent => [RDF::Literal("parent", :language => :en)],
                                                                   :hier_child => [RDF::Literal("child", :language => :en)], 
                                                                   :comment=>[RDF::Literal("Test", :language => :en)], 
                                                                   :label=>[RDF::Literal("Test", :language => :en)]}).exactly(1).times
      end
      it "should redirect to the relationships index" do
        expect(response).to redirect_to("/relationships")
      end
      context "and there are blank fields" do
        let(:params) do
        {
          :hier_parent => ["parent"],
          :hier_child => ["child"],
          :comment => [""],
          :label => ["Test"],
          :language => {
            :label => ["en"],
            :hier_parent => ["en"],
            :hier_child => ["en"]
          }
        }
        end
        it "should ignore them" do
          expect(relationship).to have_received(:attributes=).with({:hier_parent => [RDF::Literal("parent", :language => :en)],
                                                                   :hier_child => [RDF::Literal("child", :language => :en)], 
                                                                   :label=>[RDF::Literal("Test", :language => :en)],
                                                                   :comment => []})
        end
      end
    end
    context "when index.lock exists and rugged returns false" do
      before do
        FileUtils.touch(ControlledVocabularyManager::Application::config.rugged_repo + "/.git/index.lock")
        patch :update, :id => relationship.id, :relationship => params, :vocabulary => params
      end
      after do
        File.delete(ControlledVocabularyManager::Application::config.rugged_repo + "/.git/index.lock")
      end
      it "should flash something went wrong" do
        expect(flash[:notice]).to include("Something went wrong")
      end
    end
    context "when the fields are edited and the check fails" do
      before do
        allow(relationship_form).to receive(:valid?).and_return(false)
        patch :update, :id => relationship.id, :relationship => params, :vocabulary => params
      end
      it "should show the edit form" do
        expect(assigns(:relationship)).to eq relationship_form
        expect(response).to render_template("edit")
      end
    end
  end

  describe "PATCH deprecate_only" do
    let(:relationship) { relationship_mock }
    let(:twc) {TermWithoutChildren.new(relationship) }
    let(:relationship_form) { DeprecateRelationshipForm.new(SetsAttributes.new(twc), Relationship) }
    let(:params) do
      {
        :hier_parent => ["parent"],
        :hier_child => ["child"],
        :comment => ["Test"],
        :label => ["Test"],
        :is_replaced_by => ["test"],
        :language => {
          :label => ["en"],
          :comment => ["en"]
        }
      }
    end
    let(:persist_success) { true }

    before do
      allow_any_instance_of(DeprecateRelationshipFormRepository).to receive(:find).and_return(relationship_form)
      stub_repository
      full_graph = instance_double("RDF::Graph")
      allow(relationship_form).to receive(:sort_stringify).and_return("blah")
      allow(relationship_form).to receive(:single_graph).and_return(full_graph)
      allow(relationship).to receive(:blacklisted_language_properties).and_return([:id, :issued, :modified])
      allow(relationship).to receive(:attributes=)
      allow(relationship).to receive(:is_replaced_by=)
      allow(relationship_form).to receive(:is_valid?).and_return(true)
      allow(relationship).to receive(:attributes).and_return(params)
      allow(relationship).to receive(:is_replaced_by).and_return(params[:is_replaced_by])

    end

    context "when the fields are edited" do
      before do
        patch :deprecate_only, :id => relationship.id, :relationship => params, :vocabulary => params
      end
      it "should update the is_replaced_by property" do
        expect(relationship).to have_received(:is_replaced_by=).with(params[:is_replaced_by]).exactly(1).times
      end
      it "should redirect to relationships index" do
        expect(response).to redirect_to("/relationships")
      end
    end
    context "when index.lock exists and rugged returns false" do
      before do
        FileUtils.touch(ControlledVocabularyManager::Application::config.rugged_repo + "/.git/index.lock")
        patch :deprecate_only, :id => relationship.id, :relationship => params, :vocabulary => params
      end
      after do
        File.delete(ControlledVocabularyManager::Application::config.rugged_repo + "/.git/index.lock")
      end
      it "should flash something went wrong" do
        expect(flash[:notice]).to include("Something went wrong")
      end
    end
    context "when the fields are edited and the update fails" do
      before do
        allow(relationship_form).to receive(:is_valid?).and_return(false)
        patch :deprecate_only, :id => relationship.id, :relationship => params, :vocabulary => params
      end
      it "should show the edit form" do
        expect(assigns(:relationship)).to eq relationship_form
        expect(response).to render_template("deprecate")
      end
    end
  end
  describe "GET 'index'" do
    context "when there are relationships" do
      let(:injector) { RelationshipInjector.new }
      let(:relationship) {
        p = Vocabulary.new("myrel")
        p.label = "my rel label"
        p
      }

      before do
        allow(relationship).to receive(:repository).and_return(Relationship.new.repository)
        allow(AllVocabsQuery).to receive(:call).and_return([relationship])
      end
      it "should set @relationships to all rels" do
        get :index
        expect(assigns(:relationships)).to eq [relationship]
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
    let(:term_id) {"blah"}
    let(:relationship_params) do
      {
        :term_uri => [],
        :id => term_id,
        :label => ["Test1"],
        :comment => ["Test2"],
        :language => {
          :label => ["en"],
          :comment => ["en"]
        }
      }
    end
    let(:twc) { TermWithoutChildren.new(relationship)}
    let(:rel_iss) { SetsIssued.new(twc) }
    let(:rel_mod) { SetsModified.new(rel_iss) }
    let(:rel_res) { AddResource.new(rel_mod) }
    let(:relationship) { instance_double("Relationship") }
    let(:relationship_form) { RelationshipForm.new(SetsAttributes.new(rel_res), Relationship) }

    let(:twc2) { TermWithoutChildren.new(child)}
    let(:rel_iss2) { SetsIssued.new(twc2) }
    let(:rel_mod2) { SetsModified.new(rel_iss2) }
    let(:rel_res2) { AddResource.new(rel_mod2) }
    let(:child) { instance_double("Term") }
    let(:parent_term_form) { TermForm.new(SetsAttributes.new(rel_res2), Term) }

    let(:twc3) { TermWithoutChildren.new(parent)}
    let(:rel_iss3) { SetsIssued.new(twc3) }
    let(:rel_mod3) { SetsModified.new(rel_iss3) }
    let(:rel_res3) { AddResource.new(rel_mod3) }
    let(:parent) { instance_double("Term") }
    let(:child_term_form) { TermForm.new(SetsAttributes.new(rel_res3), Term) }
    let(:term_form) { TermForm.new(term_mock, instance_double("TermFormRepository")) }


    let(:result) { post 'create', :relationship => relationship_params, :vocabulary => relationship_params }
    before do
      allow_any_instance_of(TermFormRepository).to receive(:find).and_return(term_form)
      stub_repository
      allow_any_instance_of(RelationshipFormRepository).to receive(:new).and_return(relationship_form)
      full_graph = instance_double("RDF::Graph")
      allow(relationship_form).to receive(:sort_stringify).and_return("blah")
      allow(relationship_form).to receive(:single_graph).and_return(full_graph)
      allow(relationship_form).to receive(:is_valid?).and_return(true)
      allow(relationship).to receive(:new_record?).and_return("true")
      allow(relationship).to receive(:blacklisted_language_properties).and_return([:id, :issued, :modified])
      allow(relationship).to receive(:id).and_return("test")
      allow(relationship).to receive(:attributes=)
      allow(relationship).to receive(:attributes).and_return(relationship_params)
      allow(relationship).to receive(:valid?)
    end

    context "when all goes well" do
      before do
        post 'create', :relationship => relationship_params, :vocabulary => relationship_params
      end
      it "should redirect to the index" do
        expect(response).to have_http_status 200
      end
    end
    context "when index.lock exists and rugged returns false" do
      before do
        FileUtils.touch(ControlledVocabularyManager::Application::config.rugged_repo + "/.git/index.lock")
        post 'create', :relationship => relationship_params, :vocabulary => relationship_params
      end
      after do
        File.delete(ControlledVocabularyManager::Application::config.rugged_repo + "/.git/index.lock")
      end
      it "should flash something went wrong" do
        expect(flash[:notice]).to include("You must provide a Term URI to establish a relationship.")
      end
    end
  end

  describe "mark_reviewed" do
    let(:relationship) { relationship_mock }
    let(:rel_id) { "blah" }
    let(:params) do
    {
      :relationship => {
        :id => rel_id,
      },
      :vocabulary => {
        :hier_parent => ["parent"],
        :hier_child => ["child"],
        :label => ["Test"],
        :comment => ["Comment"],
        :language => {
          :label => ["en"],
        :comment => ["en"]}}
      }
    end
    let(:save_success) { true }
    let(:rel_form) { RelationshipForm.new(term, StandardRepository.new(nil,Relationship))}
    before do
      allow(relationship).to receive(:new_record?).and_return(true)
      allow_any_instance_of(RelationshipForm).to receive(:save).and_return(save_success)
      allow_any_instance_of(GitInterface).to receive(:reassemble).and_return(relationship)
    end
    context "when the item has been reviewed" do
      before do
        allow_any_instance_of(GitInterface).to receive(:rugged_merge)
        get :mark_reviewed, :id =>params[:relationship][:id]
      end
      it "will redirect to review queue if asset is saved" do
        expect(flash[:notice]).to include("blah has been saved")
        expect(response).to redirect_to("/review")
      end
    end
    context "when an error is raised inside rugged_merge" do
      before do
        allow_any_instance_of(GitInterface).to receive(:rugged_merge).and_return(0)
        get :mark_reviewed, :id =>params[:relationship][:id]
      end
      it "should show the flash error" do
        expect(flash[:notice]).to include("Something went wrong")
      end
    end
  end
end
