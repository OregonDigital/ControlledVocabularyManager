# Validator for an array of terms to ensure none of them have any "core"
# validation errors
class TermsAreImportable < ActiveModel::Validator
  def validate(record)
    record.terms.each do |term|
      term = decorate(term)
      unless term.valid?
        record.errors.add(:base, term_errors(term))
      end
    end
  end

  def decorate(term)
    return ImportableTerm.new(term)
  end

  def term_errors(term)
    "%s is not importable: %s" % [term.rdf_subject, term.errors.full_messages.join(", ")]
  end
end

# Decorates a term to add validations specific to importing - not quite the
# same as what we need to validate when creating a new term on its own
class ImportableTerm < SimpleDelegator
  include ActiveModel::Validations
  validates_with IdExists
  validates_with TermIsUnique

  # This hack ensures we can call .repository.exists? without error (which is
  # how TermIsUnique works), but this is REALLY not the right approach - if we
  # need the real repository, I'm not sure how we can get it.
  def repository
    Term
  end
end
