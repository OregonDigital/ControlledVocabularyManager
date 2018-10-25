class VocabularyCreatePage
  include Capybara::DSL

  def self.id
    "TestVocab"
  end

  def visible?
    has_content? "Create New Vocabulary"
  end

  def create
    fill_in "ID", :with => VocabularyCreatePage.id
    fill_in "vocabulary[label][]", :with => "test"
    find(:xpath, "//input[@name = 'commit'][@value = 'Create Vocabulary']").trigger("click")
    sleep 2
    VocabularyShowPage.new(VocabularyCreatePage.id)
  end
end
