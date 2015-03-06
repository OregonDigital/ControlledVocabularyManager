# Verifies that all terms in a list are unique within the list
class TermlistHasNoDuplicates < ActiveModel::Validator
  def validate(record)
    @uris_seen = Hash.new(0)
    record.terms.each do |term|
      if seen(term) == 2
        record.errors.add(:base, "%s already exists in the list" % term_uri(term))
      end
    end
  end

  private

  def seen(term)
    @uris_seen[term_uri(term)] += 1
  end

  def term_uri(term)
    term.rdf_subject.to_s
  end
end
