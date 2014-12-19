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

  let(:uri) { "http://opaquenamespace.org/ns/bla" }
  let(:resource) { Vocabulary.new(uri) }

  describe '#show' do
    before do
      stub_repository
      allow(resource).to receive(:dump)
      allow(Vocabulary).to receive(:new).and_return(resource)
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
end
