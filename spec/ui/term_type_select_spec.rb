require 'rails_helper'
require 'corporate_name'

RSpec.feature "Using the term type SELECT", :js => true do
  background do
    allow_any_instance_of(ApplicationController).to receive(:check_auth).and_return(true)
  end

  scenario "hide fields which aren't specifically configured as visible for the model" do
    vocabulary_create_page = VocabularyCreatePage.new
    visit "/vocabularies/new"
    vocabulary_create_page.create

    # Configure CorporateName to hide most fields, so we can check that the form
    # is hiding them by default
    allow(CorporateName).to receive(:visible_form_fields).and_return(%w[label date])
    visit "/vocabularies/TestVocab/new"
    within('div.term_type') do
      find("select#term_type option[value='CorporateName']").select_option
      expect(find("select#term_type option[value='CorporateName']")).to be_selected
    end
    expect(page).to have_selector("label.term_alternate_name", visible: false)
    expect(page).to have_selector("div.term_alternate_name", visible: false)

    # Fill out the value of a hidden field to verify that the form validation
    # modal is going to pop up and alert the user when they try to submit the
    # form to the server
    find("div.term_alternate_name", visible: false).find("input", visible: false).set("some invalid text for this term type")
    find("input[type='submit']").click
    expect(page).to have_selector("#formValidationModal", visible: true)
  end
end
