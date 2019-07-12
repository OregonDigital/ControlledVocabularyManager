# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Vocabularies roots" do
  it "routes /vocabularies/bla/deprecate" do
    expect(get("/vocabularies/bla/deprecate")).to route_to("vocabularies#deprecate", :id => "bla")
  end
  it "routes PATCH /vocabularies/bla/deprecate_only to the terms controller" do
    expect(patch("/vocabularies/bla/deprecate_only")).to route_to("vocabularies#deprecate_only", :id => "bla")
  end
  it "should route /vocabularies to vocabularies#index" do
    expect(get("/vocabularies")).to route_to("vocabularies#index")
  end
end
