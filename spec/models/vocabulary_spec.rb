require 'rails_helper'

RSpec.describe Vocabulary do
  after(:suite) do
    puts "HEY MAN ITS POST SUITE"
  end
  verify_contract(:vocabulary)
  let(:resource) { Vocabulary.new }
  let(:id) { nil }
  # This test validates the issued/modified behavior
  it "should have a configured type" do
    expect(resource.type).to eq [RDF::URI("http://purl.org/dc/dcam/VocabularyEncodingScheme")]
  end

  describe "contracts" do
    let(:resource) { Vocabulary.new("Creator") }
    context "when given Creator" do
      it "should have a good rdf_subject" do
        expect(resource.rdf_subject).to eq RDF::URI.new("http://opaquenamespace.org/ns/Creator")
      end
    end

    describe "#id" do
      it "should return the ID" do
        expect(resource.id).to eq "Creator"
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

    describe "#empty_errors?" do
      let(:error_double) { fake(:errors) { ActiveModel::Errors } }
      before do
        stub(resource).errors { error_double }
        stub(error_double).empty? { false }
      end
      it "should delegate to error_double" do
        expect(resource.empty_errors?).to eq false
        expect(error_double).to have_received(:empty?)
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
  end
end
