# frozen_string_literal: true

class VocabularyShowPage < Struct.new(:id)
  include Capybara::DSL

  def visible?
    has_content?(id) && has_content?(rdf_subject)
  end

  def click_create_term
    click_link "Create Term"
    TermCreatePage.new(id)
  end

  private

  def rdf_subject
    Vocabulary.base_uri + id.to_s
  end
end
