class VocabularyCreatePage
  include Capybara::DSL

  def visible?
    has_content? "Create New Vocabulary"
  end

  def create
    fill_in "ID", :with => "TestVocab"
    fill_in "vocabulary_label", :with => "test"
    find(:xpath, "//input[@name = 'commit']").trigger("click")
    VocabularyShowPage.new("TestVocab")
  end
end
