require 'rails_helper'
require 'rugged'
require 'support/test_git_setup'

RSpec.describe TermsController do
  include TestGitSetup

  let(:uri) { "http://opaquenamespace.org/ns/test/bla" }
  let(:resource) { term_mock }
  let(:injector) { TermInjector.new }
  let(:decorated_resource) { TermWithChildren.new(resource, injector.child_node_finder) }
  let(:user) { User.create(:email => 'blah@blah.com', :password => "admin123",:role => "admin reviewer editor", :institution => "Oregon State University", :name => "Test")}

  before do
    sign_in(user) if user
    setup_git
  end
  after do
    FileUtils.rm_rf(ControlledVocabularyManager::Application::config.rugged_repo)
  end

  describe '#show' do
    before do
      stub_repository
      allow(resource).to receive(:dump)
      full_graph = instance_double("RDF::Graph")
      allow(full_graph).to receive(:dump)
      allow(decorated_resource).to receive(:full_graph).and_return(full_graph)
      allow(resource).to receive(:commit_history=)
      allow(resource).to receive(:attributes).and_return({:relationships => ["blahblah"]})
      allow_any_instance_of(DecoratingRepository).to receive(:find).with("test/bla").and_return(decorated_resource)
    end

    context "when the resource exists" do
      let(:format) {}
      before do
        allow(resource).to receive(:persisted?).and_return(true)
        get :show, :id => resource.id, :format => format
      end

      it "should render the show template" do
        expect(response).to render_template("show")
      end

      context "format html" do
        it "should render html" do
          expect(response.content_type).to eq("text/html")
        end
      end

      context "format n-triples" do
        let(:format) {:nt}
        it "should render n-triples of the full graph" do
          expect(response.content_type).to eq("application/n-triples")
          expect(decorated_resource.full_graph).to have_received(:dump).with(:ntriples)
        end
      end

      context "format json-ld" do
        let(:format) {:jsonld}
        it "should render json-ld" do
          expect(response.content_type).to eq("application/ld+json")
          expect(decorated_resource.full_graph).to have_received(:dump).with(:jsonld, {:standard_prefixes => true})
        end
      end
    end

    context "when the resource does not exist" do
      before do
        allow_any_instance_of(DecoratingRepository).to receive(:find).with("nothing").and_raise ActiveTriples::NotFound
        get :show, :id => "nothing"
      end

      it "should return a 404" do
        expect(response.status).to eq 404
      end
    end
  end
  describe "GET new" do
    let(:term_form) { instance_double("TermForm") }
    let(:vocabulary_id) { "test" }
    before do
      allow(TermForm).to receive(:new).and_return(term_form)
    end
    def get_new
      get :new, :vocabulary_id => vocabulary_id
    end
    context "when logged out" do
      let(:user) { }
      it "should require login" do
        get_new
        expect(response.body).to have_content("Only a user with proper permissions can access")
      end
    end
    context "when the vocabulary is not persisted" do
      before do
        expect(Term).to receive(:find).with(vocabulary_id).and_raise ActiveTriples::NotFound
      end
      it "should raise a 404" do
        expect(get_new.code).to eq "404"
      end
    end
    context "when the vocabulary is persisted" do
      let(:vocabulary) { vocabulary_mock }
      before do
        allow(Term).to receive(:find).with(vocabulary_id).and_return(vocabulary)
        get_new
      end
      it "should assign @term" do
        expect(assigns(:term)).to eq term_form
        expect(assigns(:vocabulary)).to eq vocabulary
      end
      it "should render new" do
        expect(response).to render_template("new")
      end
    end
  end

  describe "POST create" do
    let(:injector) { TermInjector.new }
    let(:term_form) { TermForm.new(SetsAttributes.new(term_res), Term) }
    let(:term_res) { AddResource.new(term_iss) }
    let(:term_iss) { SetsIssued.new(term_mod) }
    let(:term_mod) { SetsModified.new(twc) }
    let(:twc) { TermWithChildren.new(term, injector.child_node_finder)}
    let(:term) { instance_double("Term") }
    let(:term_id) { "blah" }
    let(:params) do
      {
        :term => {
          :id => term_id
        },
        :vocabulary_id => "test",
        :term_type => "Term",
        :vocabulary => {
          :id => "testing",
          :label => ["Test"],
          :comment => ["Comment"],
          :language => {
            :label => ["en"],
          :comment => ["en"]}}
        }
      end

      let (:term_form_decorator) {DecoratorWithArguments.new(term_form, StandardRepository.new(nil, Term))}
      before do
        stub_repository
        allow_any_instance_of(TermFormRepository).to receive(:new).and_return(term_form)
        full_graph = instance_double("RDF::Graph")
        allow(term_form).to receive(:full_graph).and_return(full_graph)
        allow(term_form).to receive(:sort_stringify).and_return("blah")
        allow(term).to receive(:term_uri_leaf).and_return(term_id)
        allow(term).to receive(:term_uri_vocabulary_id).and_return("test")
        allow(term).to receive(:id).and_return(term_id)
        allow(term).to receive(:new_record?).and_return("true")
        allow(term).to receive(:attributes=)
        allow(term).to receive(:blacklisted_language_properties).and_return([:id, :issued, :modified])
        allow(term).to receive(:attributes).and_return(params[:vocabulary])
        allow(term).to receive(:valid?)
        allow(Vocabulary).to receive(:find)
      end
      context "when logged out" do
        let(:user) { }
        before do
          post :create, params
        end
        it "should require login" do
          expect(response.body).to have_content("Only a user with proper permissions can access")
        end
      end
      context "when blank arrays are passed in" do
        let(:term_id) { "blah" }
        let(:params) do
          {
            :term => {
              :id => term_id
            },
            :vocabulary_id => "test",
            :term_type => "Term",
            :vocabulary => {
              :id => "test",
              :label => [""],
              :language => {
                :label => ["en"],
              }
            }
          }
        end
        before do
          post :create, params
        end
        it "should not pass them to Term" do
          expect(term).to have_received(:attributes=).with({"label" => []})
        end
      end
      context "when all goes well" do
        before do
          allow(term_form).to receive(:is_valid?).and_return(true)
          post :create, params
        end
        it "should redirect to the vocab page" do
          expect(response).to redirect_to("/ns/test")
        end
      end
      context "when index.lock exists and rugged returns false" do
        before do
          FileUtils.touch(ControlledVocabularyManager::Application::config.rugged_repo + "/.git/index.lock")
          allow(term_form).to receive(:is_valid?).and_return(true)
          post :create, params
        end
        after do
          File.delete(ControlledVocabularyManager::Application::config.rugged_repo + "/.git/index.lock")
        end
        it "should flash something went wrong" do
          expect(flash[:notice]).to include("Something went wrong")
        end
      end
      context "when vocabulary isn't found" do
        let(:params) do
          {
            :term => {
              :id => term_id
            },
            :vocabulary_id => "error404",
            :term_type => "Term",
            :vocabulary => {
              :id => "error404",
              :label => [""],
              :language => {
                :label => ["en"],
              }
            }
          }
        end
        before do
          allow(Vocabulary).to receive(:find).and_raise ActiveTriples::NotFound
          post :create, params
        end
        it "should return a 404" do
          expect(post(:create, params).code).to eq "404"
        end
        it "doesn't call TermForm" do
          expect(TermForm).not_to receive(:new)

        end
      end
      context "when term has special chars" do
        let(:term_id) {"test/howsitgoin?"}
        let(:params) do
          {
            :term => {
              :id => term_id
            },
            :vocabulary_id => "test",
            :term_type => "Term",
            :vocabulary => {
              :id => "test",
              :label => [""],
              :language => {
                :label => ["en"],
              }
            }
          }
        end
        before do
          post :create, params
        end
        it "should show the term form again" do
          expect(response).to render_template("new")
        end
      end
      context "when term has spaces in it" do
        let(:term_id) {"bad term"}
        let(:params) do
          {
            :term => {
              :id => term_id
            },
            :vocabulary_id => "test",
            :term_type => "Term",
            :vocabulary => {
              :id => "test",
              :label => [""],
              :language => {
                :label => ["en"],
              }
            }
          }
        end
        before do
          post :create, params
        end
        it "should show the term form again" do
          expect(response).to render_template("new")
        end
      end
    end

    describe "PATCH update" do
      let(:term) { term_mock }
      let(:injector) { TermInjector.new }
      let(:twc) { TermWithChildren.new(term, injector.child_node_finder)}
      let(:term_form) { TermForm.new(SetsAttributes.new(term_mod), Term) }
      let(:term_mod) { SetsModified.new(twc) }
      let(:params) do
        {
          :label => ["Test"],
          :comment => ["Comment"],
          :language => {
            :label => ["en"],
          :comment => ["en"]}
        }
      end
      let(:persist_success) { true }
      let(:persist_failure) { false }

      before do
        stub_repository
        allow_any_instance_of(TermFormRepository).to receive(:find).and_return(term_form)
        full_graph = instance_double("RDF::Graph")
        allow(term_form).to receive(:sort_stringify).and_return("blah")
        allow(term_form).to receive(:full_graph).and_return(full_graph)
        allow(term).to receive(:attributes=)
        allow(term).to receive(:blacklisted_language_properties).and_return([:id, :issued, :modified])
        allow(term).to receive(:attributes).and_return(params)
        allow(term).to receive(:valid?)
      end
      context "when the fields are edited" do
        before do
          allow(term_form).to receive(:valid?).and_return(true)
          patch :update, :id => term.id, :vocabulary => params
        end
        it "should update the properties" do
          expect(term).to have_received(:attributes=).with(params.except(:language))
        end
        it "should redirect to the vocab" do
          expect(response).to redirect_to("/ns/test")
        end
      end
      context "when index.lock exists and rugged returns false" do
        before do
          FileUtils.touch(ControlledVocabularyManager::Application::config.rugged_repo + "/.git/index.lock")
          allow(term_form).to receive(:is_valid?).and_return(true)
          patch :update, :id => term.id, :vocabulary => params
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
          allow(term_form).to receive(:valid?).and_return(false)
          patch :update, :id => term.id, :vocabulary => params
        end
        it "should show the edit form" do
          expect(assigns(:term)).to eq term_form
          expect(response).to render_template("edit")
        end
      end
    end

    describe "mark_reviewed" do
      let(:term) { term_mock }
      let(:term_id) { "blah" }
      let(:params) do
      {
        :id => "test/" + term_id,
        :vocabulary_id => "test",
        :term_type => "Term",
        :vocabulary => {
          :id => "testing",
          :label => ["Test"],
          :comment => ["Comment"],
          :language => {
            :label => ["en"],
          :comment => ["en"]}}
        }
      end
      let(:save_success) { true }
      let(:term_form) { TermForm.new(term, StandardRepository.new(nil,Term))}
      before do
        allow(term).to receive(:new_record?).and_return(true)
        allow(term).to receive(:type).and_return(nil)
        allow(term).to receive(:term_id).and_return(TermID.new(term_id))
        allow_any_instance_of(TermForm).to receive(:save).and_return(save_success)
        allow_any_instance_of(GitInterface).to receive(:reassemble).and_return(term)
        allow(term).to receive(:term_uri_leaf).and_return(term_id)
        allow(term).to receive(:term_uri_vocabulary_id).and_return("test")
      end
      context "when the item has been reviewed" do
        before do
          allow_any_instance_of(GitInterface).to receive(:rugged_merge)
          get :mark_reviewed, :id =>params[:id]
        end
        it "will redirect to review queue if asset is saved" do
          expect(flash[:notice]).to include("test/blah has been saved")
          expect(response).to redirect_to("/review")
        end
      end
      context "when an error is raised inside rugged_merge" do
        before do
          allow_any_instance_of(GitInterface).to receive(:rugged_merge).and_return(0)
          get :mark_reviewed, :id =>params[:id]
        end
        it "should show the flash error" do
          expect(flash[:notice]).to include("Something went wrong")
        end
      end

    end

    describe "PATCH deprecate_only" do
      let(:term) { term_mock }
      let(:term_form) { DeprecateTermForm.new(SetsAttributes.new(twc), Term) }
      let(:injector) { TermInjector.new }
      let(:twc) { TermWithChildren.new(term, injector.child_node_finder)}
      let(:term_form) { TermForm.new(SetsAttributes.new(twc), Term) }
      let(:params) do
        {
          :id => "test/blah",
          :label => ["Test"],
          :comment => ["Comment"],
          :is_replaced_by => ["test"],
          :language => {
            :label => ["en"],
            :comment => ["en"]}
        }
      end
      let(:persist_success) { true }
      let(:persist_failure) { false }

      before do

        allow_any_instance_of(DeprecateTermFormRepository).to receive(:find).and_return(term_form)

        stub_repository
        full_graph = instance_double("RDF::Graph")
        allow(term_form).to receive(:sort_stringify).and_return("blah")
        allow(term_form).to receive(:full_graph).and_return(full_graph)
        allow(term).to receive(:attributes=)
        allow(term).to receive(:is_replaced_by=)
        allow(term).to receive(:blacklisted_language_properties).and_return([:id, :issued, :modified])
        allow(term).to receive(:attributes).and_return(params)
        allow(term).to receive(:is_replaced_by).and_return(params[:is_replaced_by])
        allow(term).to receive(:persist!).and_return(persist_success)
        allow(term_form).to receive(:valid?).and_return(true)
        patch :deprecate_only, :id => term.id, :vocabulary => params
      end

      context "when the fields are edited" do
        it "should update the is_replaced_by property" do
          expect(term).to have_received(:is_replaced_by=).with(params[:is_replaced_by])
        end
        it "should redirect to the vocab" do
          parts = term.id.split("/")
          expect(response).to redirect_to("/ns/#{parts[0]}")
        end
      end
      context "when index.lock exists and rugged returns false" do
        before do
          FileUtils.touch(ControlledVocabularyManager::Application::config.rugged_repo + "/.git/index.lock")
          allow(term_form).to receive(:is_valid?).and_return(true)
          patch :deprecate_only, :id => term.id, :vocabulary => params
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
          allow(term_form).to receive(:is_valid?).and_return(false)
          patch :deprecate_only, :id => term.id, :vocabulary => params
        end
        it "should show the edit form" do
          expect(assigns(:term)).to eq term_form
          expect(response).to render_template("deprecate")
        end
      end
    end
end
