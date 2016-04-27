require 'rails_helper'

RSpec.describe TermsController do
  let(:uri) { "http://opaquenamespace.org/ns/bla" }
  let(:resource) { term_mock }
  let(:injector) { TermInjector.new }
  let(:decorated_resource) { TermWithChildren.new(resource, injector.child_node_finder) }
  let(:logged_in) { true }
  before do
    allow(controller).to receive(:check_auth).and_return(true) if logged_in
  end

  describe '#show' do
    before do
      stub_repository
      allow(resource).to receive(:dump)
      full_graph = instance_double("RDF::Graph")
      allow(full_graph).to receive(:dump)
      allow(decorated_resource).to receive(:full_graph).and_return(full_graph)
      allow_any_instance_of(DecoratingRepository).to receive(:find).with("bla").and_return(decorated_resource)
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
      let(:logged_in) { false }
      it "should require login" do
        expect(get_new).to redirect_to login_path
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
    let(:term_form) { TermForm.new(SetsAttributes.new(term), Term) }
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
      let(:save_success) { true }
      let (:term_form_decorator) {DecoratorWithArguments.new(term_form, StandardRepository.new(nil, Term))}
      before do
        allow_any_instance_of(TermFormRepository).to receive(:new).and_return(term_form)
        allow(term_form).to receive(:save).and_return(save_success)
        allow(term).to receive(:id).and_return(term_id)
        allow(term).to receive(:attributes=)
        allow(term).to receive(:blacklisted_language_properties).and_return([:id, :issued, :modified])
        allow(term).to receive(:attributes).and_return(params[:vocabulary])
        allow(Vocabulary).to receive(:find)
        post :create, params
      end
      context "when logged out" do
        let(:logged_in) { false }
        it "should require login" do
          expect(response).to redirect_to login_path
        end
      end
      it "should save term form" do
        expect(term_form).to have_received(:save)
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
        it "should not pass them to Term" do
          expect(term).to have_received(:attributes=).with({"label" => []})
        end
      end
      context "when save fails" do
        let(:save_success) { false }
        it "should render new template" do
          expect(response).to render_template("new")
        end
        it "should assign @term" do
          expect(assigns(:term)).to eq term_form
        end
      end
      context "when all goes well" do
        it "should redirect to the term" do
          expect(response).to redirect_to("/ns/#{term.id}")
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
        end
        it "should return a 404" do
          expect(post(:create, params).code).to eq "404"
        end
        it "doesn't call TermForm" do
          expect(TermForm).not_to receive(:new)
          post :create, params
        end
      end
      context "when term is not utf-8 valid" do
        let(:term_id) {"R\u00E9sum\u00E9".encode!(Encoding::ISO_8859_1)}
        let(:save_success) { false }
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
        it "should show the term form again" do
          expect(response).to render_template("new")
        end
      end
      context "when term has spaces in it" do
        let(:term_id) {"bad term"}
        let(:save_success) { false }
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
        it "should show the term form again" do
          expect(response).to render_template("new")
        end
      end
    end

    describe "PATCH update" do
      let(:term) { term_mock }
      let(:term_form) { TermForm.new(SetsAttributes.new(term), Term) }
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
        allow_any_instance_of(TermFormRepository).to receive(:find).and_return(term_form)
        allow(term).to receive(:attributes=)
        allow(term).to receive(:blacklisted_language_properties).and_return([:id, :issued, :modified])
        allow(term).to receive(:attributes).and_return(params)
        allow(term).to receive(:persist!).and_return(persist_success)
        allow(term_form).to receive(:valid?).and_return(true)
        patch :update, :id => term.id, :vocabulary => params
      end

      context "when the fields are edited" do
        it "should update the properties" do
          expect(term).to have_received(:attributes=).with(params.except(:language))
        end
        it "should redirect to the updated term" do
          expect(response).to redirect_to("/ns/#{term.id}")
        end
      end

      context "when the fields are edited and the update fails" do
        before do
          allow(term).to receive(:persist!).and_return(persist_failure)
          patch :update, :id => term.id, :vocabulary => params
        end
        it "should show the edit form" do
          expect(assigns(:term)).to eq term_form
          expect(response).to render_template("edit")
        end
      end
    end
  end
