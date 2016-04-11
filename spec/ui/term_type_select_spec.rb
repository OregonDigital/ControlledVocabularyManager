require 'rails_helper'
require 'corporate_name'
require 'support/test_git_setup'
RSpec.feature "Using the term type SELECT", :js => true do
  include TestGitSetup
  let(:user1) { User.create(:email => 'george@blah.com', :password => "admin123",:role => "admin")}
  background do
    allow_any_instance_of(AdminController).to receive(:require_admin).and_return(true)
    allow_any_instance_of(VocabulariesController).to receive(:current_user).and_return(user1)
  end

  scenario "hide fields which aren't specifically configured as visible for the model" do
<<<<<<< 41b4a218bfec5ddae6ed8806e6106f059fcd15f3
    setup_git
=======
    WebMock.allow_net_connect!

>>>>>>> swaps Marmotta triplestore for Blazegraph and aims to make substituting
    vocabulary_create_page = VocabularyCreatePage.new
    visit "/vocabularies/new"
    vocabulary_create_page.create

    sleep 2

    allow(CorporateName).to receive(:visible_form_fields).and_return(%w[label date])
    visit "/vocabularies/#{VocabularyCreatePage.id}/new"
    within('div.term_type') do
      find("select#term_type option[value='CorporateName']").select_option
      expect(find("select#term_type option[value='CorporateName']")).to be_selected
    end
    expect(page).to have_selector("label.term_alternate_name", visible: false)
    expect(page).to have_selector("div.term_alternate_name", visible: false)
    FileUtils.rm_rf(ControlledVocabularyManager::Application::config.rugged_repo)
  end
end
