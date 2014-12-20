require 'rails_helper'

RSpec.describe "vocabularies/index.html.erb" do
  before do
    render
  end
  it "should display a link to create a new vocabulary" do
    expect(rendered).to have_link "Create Vocabulary", :href => "/vocabularies/new"
  end
end
