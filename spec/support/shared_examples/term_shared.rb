require 'rails_helper'

RSpec.shared_examples "a term" do
  let(:resource) { resource_class.new(id) }
  let(:id) { "Creator" }
  context "when given Creator" do
    it "should have a good rdf_subject" do
      expect(resource.rdf_subject).to eq RDF::URI.new("http://opaquenamespace.org/ns/Creator")
    end
  end

  describe "#id" do
    %w{Creator bla}.each do |example_value|
      let(:id) { example_value }
      it "should return the ID" do
        expect(resource.id).to eq id
      end
    end
    context "with a trailing slash" do
      let(:id) { "Creator/" }
      it "should not use it" do
        expect(resource.id).to eq "Creator"
      end
      it "should not mess with #rdf_subject" do
        expect(resource.rdf_subject.to_s).to eq "http://opaquenamespace.org/ns/Creator"
      end
    end
    context "with a deep ID" do
      let(:id) { "Creator/testing" }
      it "should return it" do
        expect(resource.id).to eq id
      end
    end
  end

  describe "#dump" do
    before do
      resource << RDF::Statement.new(resource.rdf_subject, RDF::DC.creator, "bla")
    end
    describe ":ntriples" do
      let(:result) { resource.dump(:ntriples).split("\n").last }
      it "should have creator" do
        expect(result).to eq "<http://opaquenamespace.org/ns/Creator> <http://purl.org/dc/terms/creator> \"bla\" ."
      end
    end
    describe ":jsonld" do
      let(:result) { JSON.parse(resource.dump(:jsonld, {:standard_prefixes => true})) }
      it "should work" do
        expect(result["dc:creator"]).to eq "bla"
      end
    end
  end

  describe "#valid?" do
    context "when no errors" do
      it "should be valid" do
        expect(resource).to be_valid
      end
    end
  end

  it "should have empty errors" do
    expect(resource.empty_errors?).to eq true
  end

  context "when errors are added" do
    before do
      resource.add_error(:id, "test")
    end
    it "should not be empty" do
      expect(resource.empty_errors?).not_to eq true
    end
  end

  describe "#persisted?" do
    let(:repository) { ActiveTriples::Repositories.repositories[:default] }
    context "when it's in the repository" do
      before do
        stub_repository
        repository << RDF::Statement.new(RDF::URI(resource.rdf_subject.to_s), RDF::DC.title, "bla")
      end
      context "and it's persisted" do
        before do
          resource.persist!
        end
        it "should be persisted" do
          expect(resource).to be_persisted
        end
      end
    end
  end

  describe "#persist!" do
    before do
      stub_repository
    end
    context "when verify is true" do
      context "when there are no errors" do
        it "should return true" do
          expect(resource.persist!(:validate => true)).to eq true
        end
      end
    end
  end

  describe "#attributes=" do
    context "when attributes are passed" do
      let(:params) do
        {
          :label => ["Test Label"],
          :comment => ["Test Comment"]
        }
      end
      before do
        resource.attributes = params
      end
      it "should set them" do
        expect(resource.label).to eq params[:label]
        expect(resource.comment).to eq params[:comment]
      end
    end
  end

  describe "#add_error" do
    let(:error_double) { fake(:errors) { ActiveModel::Errors } }
    before do
      stub(resource).errors { error_double }
      resource.add_error(:id, "test")
    end
    it "should call #add on errors" do
      expect(error_double).to have_received.add(:id, "test")
    end
  end

  describe "#valid" do
    context "when nothing is wrong" do
      it "should be valid" do
        expect(resource).to be_valid
      end
    end
  end

  describe "#errors" do
    it "should be ActiveModel::Errors" do
      expect(resource.errors).to be_kind_of ActiveModel::Errors
    end
  end

  describe "#persisted?" do
    context "when there are no triples" do
      it "should not be persisted" do
        expect(resource).not_to be_persisted
      end
    end
  end

  describe "#issued" do
    before do
      Timecop.travel(Time.new(2012,1,1))
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
        expect(resource.issued).to eq [Date.new(2012,1,1)]
      end
      context "and then re-persisted" do
        let(:reloaded) { resource.class.find(resource.rdf_subject) }
        let(:before_issued) { reloaded.issued}
        before do
          before_issued
          Timecop.travel(Time.new(2012,1,2))
          reloaded.persist!
        end
        it "should not change" do
          expect(before_issued).to eq reloaded.issued
        end
      end
    end

    describe ".base_uri" do
      it "should be set to opaquenamespace.org" do
        expect(resource.class.base_uri).to eq "http://opaquenamespace.org/ns/"
      end
    end

    describe "#base_uri" do
      it "should be set to opaquenamespace.org" do
        expect(resource.base_uri).to eq "http://opaquenamespace.org/ns/"
      end
    end


    describe "#modified" do
      before do
        Timecop.travel(Time.new(2012,1,1))
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
          expect(resource.modified).to eq [Date.new(2012,1,1)]
        end
        context "and then re-persisted" do
          let(:reloaded) { resource.class.new(resource.rdf_subject) }
          let(:before_modified) { reloaded.modified.first }
          before do
            before_modified
            Timecop.travel(Time.new(2012,1,2))
            resource.persist!
          end
          it "should change" do
            expect(before_modified).not_to eq resource.modified.first
            expect(resource.modified).to eq [Date.new(2012,1,2)]
          end
        end
      end
    end
  end
end
