require 'rails_helper'

RSpec.describe ControlledVocabulariesController do
  let(:uri) { "http://opaquenamespace.org/ns/bla" }
  let(:resource) { ControlledVocabulary.new(uri) }

  describe '#show' do
    before do
      stub_repository
    end

    context "when the resource exists" do
      before do
        resource.persist!
      end
      
      context "format html" do
        before do
          get :show, :id => resource.id
        end
        it "should render html" do
          expect(response.content_type).to eq("text/html")
        end
      end

      context "format n-triples" do
        before do
          get :show, :id => resource.id, :format => :nt
        end
        it "should render n-triples" do
          expect(response.content_type).to eq("application/n-triples")
        end
      end

      context "format json-ld" do
        before do
          get :show, :id => resource.id, :format => :jsonld
        end
        it "should render json-ld" do
          expect(response.content_type).to eq("application/ld+json")
        end
      end
    end

    context "when the resource does not exist" do
      let(:uri2) { "http://opaquenamespace.org/ns/nothing" }
      let(:resource2) { ControlledVocabulary.new(uri2) }
      before do
        get :show, :id => resource2.id
      end

      it "should return a 404" do
        expect(response.status).to eq 404
      end
    end
  end


end
