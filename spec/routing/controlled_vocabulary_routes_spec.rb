require 'rails_helper'

RSpec.describe "routes for Controlled Vocabularies" do
  it "routes /ns/bla/bla to the controlled_vocabulary controller" do
    expect(get("/ns/bla/bla")).to route_to("controlled_vocabularies#show", :id => "bla/bla")
  end
  it "routes /ns/bla" do
    expect(get("/ns/bla")).to route_to("controlled_vocabularies#show", :id => "bla")
  end
end
