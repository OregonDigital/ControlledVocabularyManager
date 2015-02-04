require 'rails_helper'

RSpec.describe ActiveTriplesAdapter do
  before do
    class ExampleResource < ActiveTriples::Resource
      include ActiveTriplesAdapter
      configure :repository => :default
      configure :type => RDF::URI("http://purl.org/dc/dcam/VocabularyEncodingScheme")
      configure :base_uri => "http://opaquenamespace.org/ns/"
    end
  end
  after do
    Object.send(:remove_const, "ExampleResource")
  end
  let(:resource) { ExampleResource.new(uri) }
  let(:uri) { "http://opaquenamespace.org/ns/bla" }
  let(:id) { "bla" }
  let(:repository) { ActiveTriples::Repositories.repositories[:default] }
  before do
    stub_repository
  end
  
  describe "#new" do
    context "when there's nothing in the repository" do
      it "should not be persisted" do
        expect(resource).not_to be_persisted
      end
    end
    context "when there's something in the repository" do
      before do
        repository << RDF::Statement.new(RDF::URI(uri), RDF::DC.title, "bla")
      end
      it "should not be persisted" do
        expect(resource).not_to be_persisted
      end
      it "should have no triples" do
        expect(resource.statements.to_a.length).to eq 1
      end
    end
    context "and then triples are persisted" do
      before do
        resource << RDF::Statement.new(RDF::URI(uri), RDF::DC.title, "bla")
        resource.persist!
      end
      it "should be persisted" do
        expect(resource).to be_persisted
      end
    end
  end

  describe "#find" do
    let(:resource) { ExampleResource.find(id) }
    context "when there's nothing in the repository" do
      it "should raise an exception" do
        expect{resource}.to raise_error(ActiveTriples::NotFound)
      end
    end
    context "when there's something in the repository" do
      before do
        repository << RDF::Statement.new(RDF::URI(uri), RDF::DC.title, "bla")
      end
      it "should be persisted" do
        expect(resource).to be_persisted
      end
      it "should have statements" do
        expect(resource.statements.to_a.length).not_to eq 0
      end
    end
  end
  
  describe "#exists?" do
    let(:result) { ExampleResource.exists?(id) }
    context "when there's nothing in the repository" do
      it "should return false" do
        expect(result).to eq false
      end
    end
    context "when there's something in the repository" do
      before do
        repository << RDF::Statement.new(RDF::URI(uri), RDF::DC.title, "bla")
      end
      it "should be true" do
        expect(result).to eq true
      end
    end
  end
end
