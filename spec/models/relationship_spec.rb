require 'rails_helper'

RSpec.describe Relationship do
  let(:uri) { "http://opaquenamespace.org/ns/bla" }
  let(:resource) { Relationship.new(uri) }

  let(:id) { nil }

  it "should be an AT::Resource" do
    expect(Relationship < ActiveTriples::Resource).to be true
  end

  it "should instantiate" do
    expect{Relationship.new}.not_to raise_error
  end

  context "when it is persisted" do
    before do
      resource.comment = "This is a comment"
      resource.persist!
    end
    it "should be retrievable" do
      expect(Relationship.find(uri)).not_to be_empty
    end
  end


  it "should have a configured type" do
    expect(resource.type).to eq [RDF::URI("http://vivoweb.org/ontology/core#Relationship")]
  end

  it "should have visible form fields" do
    expect(Relationship.visible_form_fields).to eq %w[hier_parent hier_child date comment]
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
          :comment => ["bla"]
        }
      end
      before do
        resource.attributes = attributes
      end
      it "should do nothing" do
        expect(resource.comment).to eq ["bla"]
      end
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



  it "should have additional fields" do
    expect(resource.fields).to include :hier_parent
    expect(resource.fields).to include :hier_child
    expect(resource.fields).to include :date
    expect(resource.fields).to include :comment
  end
end
