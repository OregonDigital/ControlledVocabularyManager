# frozen_string_literal: true

# Review Index Page
class TermReviewIndexPage < Struct.new(:vocabulary_id)
  include Capybara::DSL

  def select
    first(:xpath, "//a[@href='/review/#{vocabulary_id}']").trigger('click')
    sleep 2
    TermReviewShowPage.new(id)
  end

  def id
    vocabulary_id.to_s
  end
end
