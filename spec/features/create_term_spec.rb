require 'rails_helper'

RSpec.feature "Creating a vocabulary & term" do
  background do
    allow_any_instance_of(ApplicationController).to receive(:check_auth).and_return(true)
    #vocabulary = Vocabulary.new("test")
    #vocabulary.label = "yo"
    #vocabulary.persist!
    #@term_page = TermCreatePage.new(vocabulary.id)
    @vocabulary_page = VocabularyIndexPage.new
    visit vocabularies_path
  end
  scenario "succesfully creating a term" do
    expect(@vocabulary_page).to be_visible
    vocabulary_create_page = @vocabulary_page.click_create

    expect(vocabulary_create_page).to be_visible
    vocabulary_show_page = vocabulary_create_page.create

    expect(vocabulary_show_page).to be_visible
    term_create_page = vocabulary_show_page.click_create_term

    expect(term_create_page).to be_visible
    term_show_page = term_create_page.create

    expect(term_show_page).to be_visible

  end
end
