class VocabularyCreatePage
  include Capybara::DSL

  def visible?
    has_content? "Create New Vocabulary"
  end

  def create
    fill_in "ID", :with => "TestVocab"
    fill_in "vocabulary[label][]", :with => "test"
    find(:xpath, "//input[@name = 'commit']").trigger("click")
    sleep 1
    VocabularyShowPage.new("TestVocab")
  end
end
