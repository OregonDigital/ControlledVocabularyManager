# frozen_string_literal: true

# Unique Term Validator
class TermIsUnique < ActiveModel::Validator
  def validate(record)
    if record.new_record? && record.id.present? && record.repository.exists?(record.id)
      record.errors.add(:id, 'already exists in the repository')
    end
  end
end
