# frozen_string_literal: true

class VocabularyExists < ActiveModel::Validator
  def validate(record)
    vocabulary_id = self.vocabulary_id(record)
    unless vocabulary_id.present? && record.repository.exists?(vocabulary_id)
      record.errors.add(:id, 'is in a non existent vocabulary')
    end
  end

  def vocabulary_id(record)
    record.term_uri_vocabulary_id
  end
end
