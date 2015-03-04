##
# This encapsulates whether a given ID is a vocabulary or not.
# We may want to use this in TermURI in the future, but for now it doesn't seem
# to fit.
class TermID
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def to_s
    id
  end

  def vocabulary?
    !id.include?("/")
  end
end
