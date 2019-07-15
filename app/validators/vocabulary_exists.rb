# frozen_string_literal: true

# Vocabulary Exists Validator
class VocabularyExists < ActiveModel::Validator
  def validate(record)
    vocabulary_id = self.vocabulary_id(record)
    record.errors.add(:id, 'is in a non existent vocabulary') unless vocabulary_id.present? && record.repository.exists?(vocabulary_id)
  end

  def vocabulary_id(record)
    record.term_uri_vocabulary_id
  end
end
