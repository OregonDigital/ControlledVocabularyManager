require 'rails_helper'
require 'support/test_git_setup'
RSpec.feature "Creating a vocabulary & term", :js => true, :type => :feature do
  include TestGitSetup
  given(:user) { User.create(:email => 'admin@example.com', :password => 'admin123', :role => "admin") }
  background do
    allow_any_instance_of(ApplicationController).to receive(:current_user) {user}
  end
  scenario "succesfully creating a term" do
    setup_git
    vocabulary_create_page = VocabularyCreatePage.new
    visit "/vocabularies/new"

    expect(vocabulary_create_page).to be_visible
    vocabulary_show_page = vocabulary_create_page.create

    expect(get_vocab_statement_list[3].object.language).to eq :en
    expect(vocabulary_show_page).to be_visible

    term_create_page = TermCreatePage.new("TestVocab")
    visit "/vocabularies/TestVocab/new"

    expect(term_create_page).to be_visible
    term_show_page = term_create_page.create

    expect(get_term_statement_list[3].object.language).to eq :en
    expect(term_show_page).to be_visible
    FileUtils.rm_rf(ControlledVocabularyManager::Application::config.rugged_repo)
  end

  scenario "succesfully creating a term with multiple labels and languages" do
    when_creating_new_vocabulary
    expect(get_vocab_statement_list[3].object.value).to eq "Hello world"
    expect(get_vocab_statement_list[3].object.language).to eq :en
    expect(get_vocab_statement_list[4].object.value).to eq "Hola mundo"
    expect(get_vocab_statement_list[4].object.language).to eq :es
  end

  scenario "successfully updating a term with multiple labels and languages" do
    when_creating_new_vocabulary
    visit "/vocabularies/TestVocab/edit"
    within('.edit_vocabulary > .multi-value-field ul.listing li:first-child') do
      click_button("Remove", :match => :first)
    end
    expect(page).not_to have_xpath("//input[@value='Hello world']")
  end

  def when_creating_new_vocabulary
    setup_git
    visit "/vocabularies/new"
    fill_in('ID', with: 'TestVocab')
    fill_in "vocabulary[label][]", :with => "Hello world"
    within('.vocabulary_label') do
      click_button("Add", :match => :first)
    end
    within('.vocabulary_label ul.listing li:nth-child(2)') do
      fill_in "vocabulary[label][]", :with => "Hola mundo"
      find(".language-select").find("option[value='es']").select_option
    end
    find_button('Create Vocabulary').trigger('click')
    sleep 1
    if Dir.exists? ControlledVocabularyManager::Application::config.rugged_repo
      FileUtils.rm_rf(ControlledVocabularyManager::Application::config.rugged_repo)
    end
  end

end

def get_term_statement_list
  Term.find('TestVocab/banana').statements.each.map{|x| x}
end

def get_vocab_statement_list
  Vocabulary.find('TestVocab').statements.each.map{|x| x}
end
def capybara_login(user)
  visit new_user_registration_path
  page.fill_in 'user_email', :with => user.email
  page.fill_in 'user_password', :with => user.password
  page.fill_in 'user_password_confirmation', :with => user.password
  sleep(5)
  page.click_button "Sign up"
  expect(current_path).to eq root_path
end
