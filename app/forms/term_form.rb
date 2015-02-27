class TermForm < VocabularyForm
  validate :vocabulary_exists

  private

  def term
    @term ||= term_factory.new([vocabulary_id,params_id].join("/"))
  end

  def vocabulary_exists
    unless term_factory.exists?(vocabulary_id)
      errors.add(:id, "is in a non existent vocabulary")
    end
  end

  def vocabulary_id
    params[:vocabulary_id]
  end

end
