require 'rails_helper'

RSpec.feature "Creating a vocabulary & term", :js => true do
  background do
    allow_any_instance_of(ApplicationController).to receive(:check_auth).and_return(true)
  end
  scenario "succesfully creating a term" do
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

    expect(get_term_statement_list[2].object.language).to eq :en
    expect(term_show_page).to be_visible

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
    visit "/vocabularies/new"
    fill_in('ID', with: 'TestVocab')
    fill_in "vocabulary[label][]", :with => "Hello world"
    within('.vocabulary_label') do
      click_button("Add", :match => :first)
    end
    within('.vocabulary_label ul.listing li:nth-child(2)') do
      fill_in "vocabulary[label][]", :with => "Hola mundo"
      find(:xpath, ".//select[contains(@name, 'vocabulary[language][label][]')]").find(:xpath, 'option[148]').select_option
    end
    find_button('Create Vocabulary').trigger('click')
    sleep 1
  end

end

def get_term_statement_list
  Term.find('TestVocab/banana').statements.each.map{|x| x}
end

def get_vocab_statement_list
  Vocabulary.find('TestVocab').statements.each.map{|x| x}
end
