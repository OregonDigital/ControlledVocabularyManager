class TermCreator

  def self.call(params, vocabulary, callbacks)
    new(params, vocabulary, callbacks).perform
  end

  attr_accessor :params, :vocabulary, :callbacks
  def initialize(params, vocabulary, callbacks)
    @params = params
    @vocabulary = vocabulary
    @callbacks = Array.wrap(callbacks)
  end

  def perform
    check_term_validity
    check_vocabulary_persistence
    check_term_persistence
    persist_term
    notify_callbacks
  end

  private

  def term
    @term ||= Term.new("#{vocabulary.id}/#{params.delete(:id)}")
  end

  def check_term_validity
    term.valid?
  end

  def persist_term
    term.persist!(:validate => true) if term.errors.empty?
  end

  def check_vocabulary_persistence
    term.errors.add(:id, "is in a non-existent vocabulary") unless vocabulary.persisted?
  end

  def check_term_persistence
    term.errors.add(:id, "already exists in the repository") if term.persisted?
  end

  def notify_callbacks
    callbacks.each do |callback|
      if term.errors.empty?
        callback.success(term)
      else
        callback.failure(term)
      end
    end
  end
end
