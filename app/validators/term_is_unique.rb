class TermIsUnique < ActiveModel::Validator
  def validate(record)
    if record.id.present? && record.repository.exists?(record.id)
      record.errors.add(:id, "already exists in the repository")
    end
  end
end
