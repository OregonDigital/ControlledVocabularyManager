require 'rails_helper'

RSpec.describe TermsController do
  let(:uri) { "http://opaquenamespace.org/ns/bla" }
  let(:resource) { fake(:term) }

  describe '#show' do
    before do
      stub_repository
      stub(Term).find(resource.id) { resource }
    end

    context "when the resource exists" do
      let(:format) {}
      before do
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
        it "should render n-triples" do
          expect(response.content_type).to eq("application/n-triples")
          expect(resource).to have_received.dump(:ntriples)
        end
      end

      context "format json-ld" do
        let(:format) {:jsonld}
        it "should render json-ld" do
          expect(response.content_type).to eq("application/ld+json")
          expect(resource).to have_received.dump(:jsonld, {:standard_prefixes => true})
        end
      end
    end

    context "when the resource does not exist" do
      before do
        stub(Term).find(resource.id) { raise ActiveTriples::NotFound }
        get :show, :id => resource.id
      end

      it "should return a 404" do
        expect(response.status).to eq 404
      end
    end
  end
  describe "GET new" do
    fake(:vocabulary)
    fake(:term)
    let(:persisted_status) { true }
    before do
      stub(Vocabulary).find(vocabulary.id) { vocabulary }
      stub(vocabulary).persisted? { persisted_status }
      # Is this useful?
      stub(Term).new() { term }
    end
    def get_new
      get :new, :vocabulary_id => vocabulary.id
    end
    context "when the vocabulary is not persisted" do
      before do
        stub(Vocabulary).find(vocabulary.id) { raise ActiveTriples::NotFound }
      end
      it "should raise a 404" do
        expect(get_new.code).to eq "404"
      end
    end
    context "when the vocabulary is persisted" do
      let(:persisted_status) { true }
      before do
        get_new
      end
      it "should assign @vocabulary" do
        expect(assigns(:vocabulary)).to eq vocabulary
      end
      it "should assign @term" do
        expect(assigns(:term)).to eq term
      end
      it "should render new" do
        expect(response).to render_template("new")
      end
    end
  end

  describe "POST create" do
    fake(:vocabulary)
    fake(:term)
    let(:params) do
      {
        "vocabulary_id" => vocabulary.id,
        :term => {
          "id" => "test",
          "comment" => ["Test"],
          "label" => ["Label"]
        }
      }
    end
    fake(:term_callback)
    before do
      stub(Vocabulary).find(vocabulary.id) { vocabulary }
      fake_class(TermCreator)
      stub(TermCreator).call(any_args) {
        controller.render :nothing => true
      }
    end
    describe "#create" do
      before do
        stub(TermsController::CreateResponder).new(controller) { term_callback }
      end
      it "should call TermCreator" do
        post :create, params
        expect(TermCreator).to have_received.call(params[:term], vocabulary, [term_callback])
      end
      context "when vocabulary isn't found" do
        before do
          stub(Vocabulary).find(vocabulary.id) { raise ActiveTriples::NotFound }
          post :create, params
        end
        it "should return a 404" do
          expect(response.code).to eq "404"
        end
        it "doesn't call TermCreator" do
          expect(TermCreator).not_to have_received.call(any_args)
        end
      end
    end
    describe "CreateResponder" do
      let(:term) { Term.new }
      let(:term_id) { "bla/bla" }
      describe "#success" do
        before do
          stub(controller).create do
            TermsController::CreateResponder.new(controller).success(term, vocabulary)
          end
          stub(term).persisted? { true }
          stub(term).id { term_id }
          post :create, params
        end
        it "should redirect to the term" do
          expect(response).to redirect_to("/ns/#{term_id}")
        end
      end
      describe "#failure" do
        before do
          stub(controller).create do
            TermsController::CreateResponder.new(controller).failure(term, vocabulary)
          end
          post :create, params
        end
        it "should render new template" do
          expect(response).to render_template("new")
        end
        it "should assign @vocabulary" do
          expect(assigns(:vocabulary)).to eq vocabulary
        end
        it "should assign @term" do
          expect(assigns(:term)).to eq term
        end
      end
    end
  end
end
