require 'rails_helper'

RSpec.feature "Creating a vocabulary & term" do
  background do
    allow_any_instance_of(ApplicationController).to receive(:check_auth).and_return(true)
  end
  scenario "succesfully creating a term" do
    visit "/vocabularies/new"
    page.fill_in "vocabulary_id", :with => "pebble"
    page.click_button "Create Vocabulary"
    expect(page.body).to include("pebble")
    visit "/vocabularies/pebble/new"
    page.fill_in "term_id", :with => "fruity"
    page.click_button "Create Term"
    expect(page.body).to include("fruity")
  end
end
