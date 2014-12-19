require 'rails_helper'

RSpec.describe "routes for Vocabularies" do
  it "routes /ns/bla/bla to the vocabulary controller" do
    expect(get("/ns/bla/bla")).to route_to("vocabularies#show", :id => "bla/bla")
  end
  it "routes /ns/bla" do
    expect(get("/ns/bla")).to route_to("vocabularies#show", :id => "bla")
  end
  [Vocabulary].each do |klass|
    context "when given a #{klass}" do
      let(:id) {"bla/bla"}
      let(:resource) do
        r = klass.new
        allow(r).to receive(:id).and_return(id)
        allow(r).to receive(:persisted?).and_return(true)
        r
      end
      it "should route to its id preserving slashes" do
        expect(vocabulary_path(resource)).to eq "/ns/bla/bla"
      end
    end

  end
end
