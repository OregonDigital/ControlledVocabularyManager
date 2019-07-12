# frozen_string_literal: true

class VocabularyIndexPage
  include Capybara::DSL

  def visible?
    has_content? "Vocabularies"
  end

  def click_create
    click_link "Create Vocabulary"
    VocabularyCreatePage.new
  end
end
