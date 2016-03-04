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
end

def get_term_statement_list
  Term.find('TestVocab/banana').statements.each.map{|x| x}
end

def get_vocab_statement_list
  Vocabulary.find('TestVocab').statements.each.map{|x| x}
end
