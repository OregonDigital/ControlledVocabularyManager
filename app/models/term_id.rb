##
# This encapsulates whether a given ID is a vocabulary or not.
# We may want to use this in TermURI in the future, but for now it doesn't seem
# to fit.
class TermID
  attr_reader :id

  def initialize(id)
    @id = id.to_s
  end

  def to_s
    id
  end
#maybe remove this in favor of has_parent
  def vocabulary?
    !clean_id.include?("/")
  end
  def hasParent?
    clean_id.include?("/")
  end
  private

  def clean_id
    id.gsub(/.*\/ns\//, '')
  end
end
