# frozen_string_literal: true

class SetsTermType < SimpleDelegator
  def persist!
    if valid?
      set_term_type unless vocabulary? || predicate? || new_record?
    end
    __getobj__.persist!
  end
end
