require 'rails_helper'

RSpec.describe "shared/_navbar.html.erb" do
  before do
    render
  end
  it "should have a link to vocabularies" do
    expect(rendered).to have_link("Vocabularies", :href => vocabularies_path)
  end
end
