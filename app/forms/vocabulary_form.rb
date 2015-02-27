class VocabularyForm
  include ActiveModel::Model
  validate  :term_doesnt_exist
  validates :id, :presence => true
  delegate :editable_fields, :id, :to => :term

  attr_accessor :term_factory, :params
  def initialize(term_factory, params)
    @term_factory = term_factory
    @params = params
    term.attributes = term_params
    define_factory_methods
  end

  def save
    return false unless valid?
    term.persist!
  end

  def id
    params[:id]
  end

  def term_id
    term.id
  end

  private

  def define_factory_methods
    singleton_class.__send__(:attr_accessor, *term.fields)
  end


  def term_params
    params.except(:id, :vocabulary_id)
  end
  
  def term_doesnt_exist
    if id.present? && term_factory.exists?(term.id)
      errors.add(:id, "already exists in the repository")
    end
  end

  def term
    @term ||= term_factory.new(params_id)
  end

  def params_id
    params[:id]
  end

end
