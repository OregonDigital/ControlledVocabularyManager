require 'rails_helper'
require 'corporate_name'
require 'support/test_git_setup'
RSpec.feature "Using the term type SELECT", :js => true do
  include TestGitSetup
  let(:user1) { User.create(:email => 'admin@example.com', :name => 'Jane Admin', :password => "admin123",:role => "admin editor reviewer", :institution => "Oregon State University")}
  let(:user_params) { {:email => 'admin@example.com', :name => "Jane Admin", :password => 'admin123', :role => "admin editor reviewer", :institution => "Oregon State University"} }

  background do
    allow_any_instance_of(AdminController).to receive(:current_user).and_return(user1)
    allow(user1).to receive(:admin?).and_return(true)
  end

  scenario "hide fields which aren't specifically configured as visible for the model" do
    setup_git
    WebMock.allow_net_connect!
    user1
    capybara_login(user_params)
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
