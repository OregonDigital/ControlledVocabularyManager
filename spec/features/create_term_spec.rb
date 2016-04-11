require 'rails_helper'
require 'support/test_git_setup'

RSpec.feature "Create and update a Term", :js => true, :type => :feature do
  include TestGitSetup

  given(:user) { User.create(:email => 'admin@example.com', :password => 'admin123', :role => "admin") }
  background do
    allow_any_instance_of(ApplicationController).to receive(:current_user) {user}
    allow_any_instance_of(AdminController).to receive(:current_user) {user}
  end

  let(:datetime_now) { DateTime.now.strftime('%Y%m%dT%H%M%S') }
  let(:vocabulary_id) { VocabularyCreatePage.id + datetime_now }

  scenario "adds a new term to a vocabulary" do
    WebMock.allow_net_connect!
    setup_git

    visit "/vocabularies/new"
    fill_in('ID', with: vocabulary_id)
    find_button('Create Vocabulary').trigger('click')
    sleep 2

    visit "/vocabularies/#{vocabulary_id}/new"
    fill_in "ID", :with => TermCreatePage.id
    fill_in "vocabulary[label][]", :with => "Test label"
    fill_in "vocabulary[comment][]", :with => "Test comment"
    find_button('Create Term').trigger('click')
    sleep 2

    term_statement_list = Term.find("#{vocabulary_id}/#{TermCreatePage.id}").statements.each.map { |x| x }
    expect(term_statement_list[2].object.value).to eq "Test comment"
    expect(term_statement_list[2].object.language).to eq :en
    expect(term_statement_list[3].object.value).to eq "Test label"
    expect(term_statement_list[3].object.language).to eq :en

    if Dir.exists? ControlledVocabularyManager::Application::config.rugged_repo
      FileUtils.rm_rf(ControlledVocabularyManager::Application::config.rugged_repo)
    end
  end
end
