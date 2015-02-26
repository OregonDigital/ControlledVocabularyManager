require 'rails_helper'

RSpec.describe Term do
  let(:uri) { "http://opaquenamespace.org/ns/bla" }
  let(:resource) { Term.new(uri) }
  it "should be an AT::Resource" do
    expect(Term < ActiveTriples::Resource).to be true
  end
  it "should instantiate" do
    expect{Term.new}.not_to raise_error
  end
  it "should have the default repository configured" do
    expect(described_class.repository).to eq :default
  end
  context "when it is persisted" do
    before do
      resource.comment = "This is a comment"
      resource.persist!
    end
    it "should be retrievable" do
      expect(Term.find(uri)).not_to be_empty
    end
  end

  describe "#fields" do
    it "should return all available fields" do
      expect(resource.fields).to include(:comment, :modified, :label, :issued)
    end
  end

  describe "#editable_fields" do
    it "should return all fields except issued/modified" do
      expect(resource.editable_fields).to eq resource.fields - [:issued, :modified]
      expect(resource.editable_fields).not_to include(:issued, :modified)
    end
  end

  describe "#get_values" do
    before do
      resource.comment = "test"
    end
    it "should be able to return values" do
      expect(resource.get_values(:comment)).to eq ["test"]
    end
  end

  describe "#attributes=" do
    context "with blank arrays" do
      let(:attributes) do
        {
          :label => [],
          :comment => ["bla"]
        }
      end
      before do
        resource.attributes = attributes
      end
      it "should do nothing" do
        expect(resource.label).to eq []
        expect(resource.comment).to eq ["bla"]
      end
    end
  end

  describe "#exists?" do
    let(:result) { Term.exists?("bla") }
    let(:repository) { ActiveTriples::Repositories.repositories[:default] }
    context "when it is in the repository" do
      before do
        stub_repository
        repository << RDF::Statement.new(RDF::URI(uri), RDF::DC.title, "bla")
      end
      it "should be true" do
        expect(result).to eq true
      end
    end
  end

  describe "#vocabulary?" do
    context "when it is a term" do
      it "should not be a vocabulary" do
        expect(resource).not_to be_vocabulary
      end
    end
    context "when it has a vocabulary type" do
      before do
        resource.type = Vocabulary.type
      end
      it "should be a vocabulary" do
        expect(resource).to be_vocabulary
      end
    end
  end

  describe "validations" do
    context "when not given a uri" do
      let(:uri) { nil }
      it "should be invalid" do
        expect(resource).not_to be_valid
      end
    end
    context "when given a URI" do
      it "should be valid" do
        expect(resource).to be_valid
      end
    end
  end

  describe "#issued" do
    before do
      stub_repository
    end
    context "when it's new" do
      it "should be empty" do
        expect(resource.issued).to be_empty
      end
    end
    context "when persisted" do
      before do
        resource.persist!
      end
      it "should be set" do
        expect(resource.issued).not_to be_empty
      end
      it "should be the current day" do
        expect(resource.issued.first).to eq Date.today
      end
      context "and then re-persisted" do
        let(:reloaded) { resource.class.find(resource.rdf_subject) }
        let(:before_issued) { reloaded.issued.first }
        before do
          before_issued
          Timecop.travel(Time.current.tomorrow)
          reloaded.persist!
        end
        it "should not change" do
          expect(before_issued).to eq reloaded.issued.first
        end
      end
    end

    describe "#modified" do
      before do
        stub_repository
      end
      context "when it's persisted" do
        before do
          resource.persist!
        end
        it "should be set" do
          expect(resource.modified).not_to be_empty
        end
        it "should be the current day" do
          expect(resource.modified.first).to eq Date.today
        end
        context "and then re-persisted" do
          let(:reloaded) { resource.class.new(resource.rdf_subject) }
          let(:before_modified) { reloaded.modified.first }
          before do
            before_modified
            Timecop.travel(Time.current.tomorrow)
            reloaded.persist!
          end
          it "should change" do
            expect(before_modified).not_to eq reloaded.modified.first
            expect(reloaded.modified.first).to eq Date.today
          end
        end
      end
    end

    describe ".base_uri" do
      it "should be set to opaquenamespace.org" do
        expect(resource.class.base_uri).to eq "http://opaquenamespace.org/ns/"
      end
    end

    describe "#id" do
      context "with no id" do
        let(:resource) { Term.new }
        it "should be nil" do
          expect(resource.id).to be_nil
        end
      end
      context "with an id" do
        let(:resource) { Term.new("bla/bla") }
        before do
          resource.persist!
        end
        it "should be just the id" do
          expect(resource.id).to eq "bla/bla"
        end
      end
    end
  end
end
