require 'rails_helper'

RSpec.describe "Vocabularies roots" do
  it "should route /vocabularies to vocabularies#index" do
    expect(get("/vocabularies")).to route_to("vocabularies#index")
  end
end
