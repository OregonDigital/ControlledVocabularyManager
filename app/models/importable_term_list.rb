# frozen_string_literal: true

# Composition to let an array of terms act slightly more like a typical Railsy
# model, specifically for terms which are being imported in bulk
class ImportableTermList < Struct.new(:terms)
  include ActiveModel::Validations
  validates_with TermsAreImportable
  validates_with TermlistHasNoDuplicates

  # Stores all terms
  def save
    return false unless valid?

    terms.each(&:persist!)
    true
  end
end
