require 'rails_helper'

RSpec.describe "routes for Controlled Vocabularies" do
  it "routes /ns/bla/bla to the controlled_vocabulary controller" do
    expect(get("/ns/bla/bla")).to route_to("controlled_vocabularies#show", :id => "bla/bla")
  end
  it "routes /ns/bla" do
    expect(get("/ns/bla")).to route_to("controlled_vocabularies#show", :id => "bla")
  end
  context "when given a resource" do
    let(:id) {"bla/bla"}
    let(:resource) do
      r = ControlledVocabulary.new
      allow(r).to receive(:id).and_return(id)
      allow(r).to receive(:persisted?).and_return(true)
      r
    end
    it "should route to its id preserving slashes" do
      expect(controlled_vocabulary_path(resource)).to eq "/ns/bla/bla"
    end
  end
end
