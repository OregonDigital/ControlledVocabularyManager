class VocabularyForm < SimpleDelegator
  include ActiveModel::Validations
  validate  :term_doesnt_exist
  validates :id, :presence => true

  attr_reader :repository
  def initialize(term, repository)
    @repository = repository
    __setobj__(term)
  end

  def save
    return false unless valid?
    self.persist!
  end

  private

  def term_doesnt_exist
    if id.present? && repository.exists?(id)
      errors.add(:id, "already exists in the repository")
    end
  end

  def params_id
    params[:id]
  end

end
