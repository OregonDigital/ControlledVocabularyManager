# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "term routes" do
  describe "NEW route" do
    it "routes /vocabularies/bla/bla/new to TermsController#new" do
      expect(get("/vocabularies/bla/bla/new")).to route_to("terms#new", :vocabulary_id => "bla/bla")
    end
  end
end
