# frozen_string_literal: true

class TermShowPage
  include Capybara::DSL

  attr_reader :id
  def initialize(id)
    @id = id
  end

  def visible?
    has_content?(id) && has_content?(rdf_subject)
  end

  private

  def rdf_subject
    Term.base_uri + id.to_s
  end
end
