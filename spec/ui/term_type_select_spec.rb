require 'rails_helper'
require 'corporate_name'
require 'support/test_git_setup'
RSpec.feature "Using the term type SELECT", :js => true do
  include TestGitSetup
  let(:user1) { User.create(:email => 'george@blah.com', :name => 'George Jones', :password => "admin123",:role => "admin")}
  background do
    allow_any_instance_of(ApplicationController).to receive(:current_user) {user1}
    allow_any_instance_of(AdminController).to receive(:current_user) {user1}

  end

  scenario "hide fields which aren't specifically configured as visible for the model" do
    setup_git
    WebMock.allow_net_connect!

    vocabulary_create_page = VocabularyCreatePage.new
    visit "/vocabularies/new"
    sleep 2
    vocabulary_create_page.create
    sleep 2
    visit "/review/#{VocabularyCreatePage.id}"
    find_link('review').click
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
