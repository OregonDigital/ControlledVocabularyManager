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
    set_attributes
    check_term_validity
    check_vocabulary_persistence
    check_term_persistence
    check_nonempty_id
    persist_term
    notify_callbacks
  end

  private

  def term
    @term ||= Term.new("#{vocabulary.id}/#{term_id}")
  end

  def set_attributes
    term.attributes = params
  end

  def term_id
    @term_id ||= params.delete(:id)
  end

  def check_term_validity
    term.valid?
  end

  def persist_term
    term.persist!(:validate => true) if term.empty_errors?
  end

  def check_nonempty_id
    term.add_error(:id, "can not be blank") unless term_id.present?
  end

  def check_vocabulary_persistence
    term.add_error(:id, "is in a non-existent vocabulary") unless vocabulary.persisted?
  end

  def check_term_persistence
    term.add_error(:id, "already exists in the repository") if Term.exists?(term.id)
  end

  def notify_callbacks
    callbacks.each do |callback|
      if term.empty_errors?
        callback.success(term, vocabulary)
      else
        callback.failure(term, vocabulary)
      end
    end
  end
end
