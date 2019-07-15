# frozen_string_literal: true

# Is Replaced By Validator
class IsValidIsReplacedBy < ActiveModel::Validator
  include Sanitize

  def validate(record)
    if record.is_replaced_by.blank?
      record.errors.add(:is_replaced_by, "can't be blank") if record.is_replaced_by.blank?
    else
      record.is_replaced_by.each do |value|
        record.errors.add(:is_replaced_by, 'invalid uri') unless verify_uri(value)
      end
    end
  end
end
