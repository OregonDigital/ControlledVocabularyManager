class TermIsSanitary < ActiveModel::Validator
  include Sanitize

  def validate(record)
    #TODO:inspect the term type, check validity of more fields, assigning errors
    #to each by symbol?
    error_messages = check_validity(leaf_id(record))
    unless error_messages.blank?
      record.errors.add(:id, error_messages)
    end
  end

  private

  def leaf_id(record)
    record.term_uri_leaf
  end

end
