# frozen_string_literal: true

# Vocabulary Index Page
class VocabularyIndexPage
  include Capybara::DSL

  def visible?
    has_content? 'Vocabularies'
  end

  def click_create
    click_link 'Create Vocabulary'
    VocabularyCreatePage.new
  end
end
