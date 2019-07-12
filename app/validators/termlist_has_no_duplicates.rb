# frozen_string_literal: true

# Verifies that all terms in a list are unique within the list
class TermlistHasNoDuplicates < ActiveModel::Validator
  def validate(record)
    duplicate_subjects(record).each do |subject|
      record.errors.add(:base, "%s already exists in the list" % subject)
    end
  end

  private

  def duplicate_subjects(record)
    record.terms.group_by(&:rdf_subject).select{|k, v| v.length > 1}.keys
  end
end
