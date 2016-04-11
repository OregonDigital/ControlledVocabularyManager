require 'rails_helper'

RSpec.feature "Using a language SELECT with a default language set", :js => true do
  background do
    allow_any_instance_of(ApplicationController).to receive(:check_auth).and_return(true)
  end

  scenario "adding another label defaults language select to english" do
    visit "/vocabularies/new"
    within('.vocabulary_label') do
      find(".language-select option[value='es']").select_option
      expect(find(".language-select option[value='es']")).to be_selected
      click_button("Add")
    end
    within('.vocabulary_label ul.listing li:nth-child(2)') do
      expect(find(".language-select option[value='en']")).to be_selected
    end
  end
end
