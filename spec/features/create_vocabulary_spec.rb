require 'rails_helper'

RSpec.feature "Create and update a Vocabulary", :js => true, :type => :feature do
  include TestGitSetup

  given(:user) { User.create(:email => 'admin@example.com', :name => "Jane Admin", :password => 'admin123', :role => "admin") }
  background do
    allow_any_instance_of(ApplicationController).to receive(:current_user) {user}
    allow_any_instance_of(AdminController).to receive(:current_user) {user}
  end

  let(:datetime_now) { DateTime.now.strftime('%Y%m%dT%H%M%S') }
  let(:vocabulary_id) { VocabularyCreatePage.id + datetime_now }

  it "should create and update a vocabulary" do
    WebMock.allow_net_connect!
    setup_git

    visit "/vocabularies/new"
    fill_in('ID', with: vocabulary_id)
    fill_in "vocabulary[label][]", :with => "Hello world"
    within('.vocabulary_label') do
      click_button("Add", :match => :first)
    end
    within('.vocabulary_label ul.listing li:nth-child(2)') do
      fill_in "vocabulary[label][]", :with => "Hola mundo"
      find(".language-select").find("option[value='es']").select_option
    end
    find_button('Create Vocabulary').trigger('click')
    sleep 2

    expect(page).to have_content("http://opaquenamespace.org/ns/#{vocabulary_id}")

    vocab_statement_list = Vocabulary.find(vocabulary_id).statements.each.map { |x| x }
    expect(vocab_statement_list[2].object.value).to eq "Hello world"
    expect(vocab_statement_list[2].object.language).to eq :en
    expect(vocab_statement_list[3].object.value).to eq "Hola mundo"
    expect(vocab_statement_list[3].object.language).to eq :es

    visit "/vocabularies/#{vocabulary_id}/edit"
    within('.edit_vocabulary > .multi-value-field ul.listing li:first-child') do
      click_button("Remove", :match => :first)
    end
    expect(page).not_to have_xpath("//input[@value='Hello world']")

    if Dir.exists? ControlledVocabularyManager::Application::config.rugged_repo
      FileUtils.rm_rf(ControlledVocabularyManager::Application::config.rugged_repo)
    end
  end
end
