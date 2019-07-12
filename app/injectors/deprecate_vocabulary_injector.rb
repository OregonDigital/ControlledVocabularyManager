# frozen_string_literal: true

class DeprecateVocabularyInjector < Struct.new(:params)
  def deprecate_vocabulary_form_repository
    DeprecateVocabularyFormRepository.new(decorators)
  end

  def deprecate_vocabulary_repository
    @vocabulary_repository ||= StandardRepository.new(decorators, Vocabulary)
  end

  def params
    super || {}
  end

  private

  def decorators
    vocabulary_injector.decorators
  end

  def vocabulary_injector
    @vocabulary_injector ||= VocabularyInjector.new(params)
  end


end
