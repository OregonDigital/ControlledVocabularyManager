require 'rails_helper'

RSpec.describe "routes for Terms" do
  it "routes /ns/bla/bla to the terms controller" do
    expect(get("/ns/bla/bla")).to route_to("terms#show", :id => "bla/bla")
  end
  it "routes /ns/bla" do
    expect(get("/ns/bla")).to route_to("terms#show", :id => "bla")
  end
  it "routes PATCH /ns/bla/bla to the terms controller" do
    expect(patch("/ns/bla/bla")).to route_to("terms#update", :id => "bla/bla")
  end
  it "routes PATCH /ns/bla to the terms controller" do
    expect(patch("/ns/bla")).to route_to("terms#update", :id => "bla")
  end
  [Term, Vocabulary].each do |klass|
    context "when given a #{klass}" do
      let(:id) {"bla/bla"}
      let(:resource) do
        r = klass.new
        allow(r).to receive(:id).and_return(id)
        allow(r).to receive(:persisted?).and_return(true)
        r
      end
      it "should route to its id preserving slashes" do
        expect(term_path(resource)).to eq "/ns/bla/bla"
      end
    end

  end
end
