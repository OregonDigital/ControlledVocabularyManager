require 'rails_helper'

RSpec.describe TermsController do
  let(:uri) { "http://opaquenamespace.org/ns/bla" }
  let(:resource) { Term.new(uri) }

  describe '#show' do
    before do
      stub_repository
      allow(resource).to receive(:dump)
      allow(Term).to receive(:new).and_return(resource)
    end

    context "when the resource exists" do
      let(:format) {}
      before do
        resource.persist!
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
          expect(resource).to have_received(:dump).with(:ntriples)
        end
      end

      context "format json-ld" do
        let(:format) {:jsonld}
        it "should render json-ld" do
          expect(response.content_type).to eq("application/ld+json")
          expect(resource).to have_received(:dump).with(:jsonld, {:standard_prefixes => true})
        end
      end
    end

    context "when the resource does not exist" do
      before do
        get :show, :id => "nothing"
      end

      it "should return a 404" do
        expect(response.status).to eq 404
      end
    end
  end
  describe "GET new" do
    let(:vocabulary_id) { "bla/bla" }
    let(:vocabulary) { instance_double("Vocabulary") }
    let(:term) { instance_double("Term") }
    let(:persisted_status) { true }
    before do
      allow(Vocabulary).to receive(:new).with(vocabulary_id).and_return(vocabulary)
      allow(vocabulary).to receive(:persisted?).and_return(persisted_status)
      allow(Term).to receive(:new).with(no_args).and_return(term)
    end
    def get_new
      get :new, :vocabulary_id => vocabulary_id
    end
    context "when the vocabulary is not persisted" do
      let(:persisted_status) { false }
      it "should raise a routing error" do
        expect{ get_new }.to raise_error ActionController::RoutingError, "Term not found"
      end
    end
    context "when the vocabulary is persisted" do
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
end
