# frozen_string_literal: true

class TermReviewShowPage < Struct.new(:vocabulary_id)
  include Capybara::DSL

  def mark
    find_link('review').click
    sleep 2
  end

  def edit
    find_link('Edit').click
    sleep 2
  end

  def id
    "#{vocabulary_id}/banana"
  end
end
