class VocabularyCreator
  def self.call(params)
    instance = new(params)
    instance.vocabulary # Run to populate the result
    instance
  end

  attr_accessor :params, :result
  def initialize(params)
    @params = params
    @result = false
  end

  def vocabulary
    populate_vocabulary if @vocabulary.nil?
    @vocabulary
  end

  def result
    vocabulary if @vocabulary.nil?
    @result
  end

  private

  def populate_vocabulary
    @vocabulary = Vocabulary.new(params.delete(:id))
    check_existence
    set_attributes
    persist_vocabulary
  end

  def check_existence
    vocabulary.errors.add(:id, "already exists in the repository") if vocabulary.persisted?
  end

  def persist_vocabulary
    # This return is a hack. Checking #valid? clears out errors and re-runs
    # validations, which means the above doesn't work. Need a better way to do
    # this maybe. A decorator with validators maybe?
    return unless vocabulary.errors.empty?
    @result = vocabulary.persist!(:validate => true)
  end

  def set_attributes
    vocabulary.attributes = params
  end
end
