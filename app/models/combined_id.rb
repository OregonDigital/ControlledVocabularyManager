class CombinedId
  attr_reader :vocab_id, :term_id
  def initialize(vocab_id, term_id)
    @vocab_id = vocab_id
    @term_id = term_id
  end

  def to_s
    [vocab_id, term_id].join("/")
  end
end
