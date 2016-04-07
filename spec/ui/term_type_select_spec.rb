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

    allow(CorporateName).to receive(:visible_form_fields).and_return(%w[label date])
    visit "/vocabularies/TestVocab/new"
    within('div.term_type') do
      find("select#term_type option[value='CorporateName']").select_option
      expect(find("select#term_type option[value='CorporateName']")).to be_selected
    end
    expect(page).to have_selector("label.term_alternate_name", visible: false)
    expect(page).to have_selector("div.term_alternate_name", visible: false)
  end
end
