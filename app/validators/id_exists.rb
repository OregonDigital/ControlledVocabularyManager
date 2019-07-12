# frozen_string_literal: true

class IdExists < ActiveModel::Validator
  def validate(record)
    if leaf_id(record).blank?
      record.errors.add(:id, "can't be blank")
    end
  end

  private

  def leaf_id(record)
    record.term_uri_leaf
  end

end
