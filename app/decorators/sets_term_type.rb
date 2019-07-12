# frozen_string_literal: true

class SetsTermType < SimpleDelegator
  def persist!
    if valid?
      unless self.vocabulary? || self.predicate? || new_record?
        self.set_term_type
      end
    end
    __getobj__.persist!
  end
end
