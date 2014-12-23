class VocabularyCreator
  def self.call(params, callbacks)
    new(params, callbacks).perform
  end

  attr_accessor :params, :result, :callbacks
  def initialize(params, callbacks=[])
    @params = params
    @result = false
    @callbacks = Array.wrap(callbacks)
  end

  def perform
    check_existence
    set_attributes
    persist_vocabulary
    notify_callbacks
  end

  private

  def notify_callbacks
   return notify_success if result
   notify_failure
  end

  def notify_success
    callbacks.each do |callback|
      callback.send(:success, vocabulary)
    end
  end

  def notify_failure
    callbacks.each do |callback|
      callback.send(:failure, vocabulary)
    end
  end

  def vocabulary
    @vocabulary ||= Vocabulary.new(params.delete(:id))
  end

  def result
    @result
  end

  def check_existence
    vocabulary.add_error(:id, "already exists in the repository") if Vocabulary.exists?(vocabulary.id)
  end

  def persist_vocabulary
    # This return is a hack. Checking #valid? clears out errors and re-runs
    # validations, which means the above doesn't work. Need a better way to do
    # this maybe. A decorator with validators maybe?
    return unless vocabulary.empty_errors?
    @result = vocabulary.persist!(:validate => true)
  end

  def set_attributes
    vocabulary.attributes = params
  end
end
