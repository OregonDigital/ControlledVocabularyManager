# frozen_string_literal: true

# ID Exists Validator
class IdExists < ActiveModel::Validator
  def validate(record)
    record.errors.add(:id, "can't be blank") if leaf_id(record).blank?
  end

  private

  def leaf_id(record)
    record.term_uri_leaf
  end
end
