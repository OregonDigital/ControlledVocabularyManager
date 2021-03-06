# frozen_string_literal: true

# Decorates set_issued and reset_issued
class SetsIssued < SimpleDelegator
  def persist!
    set_issued
    __getobj__.persist!
  end

  def set_issued
    self.issued = RDF::Literal::Date.new(Time.now) if valid? && new_record?
  end

  def reset_issued(strdate)
    return if strdate.blank?

    if valid?
      arr = strdate.split('-')
      date = Time.new(arr[0].to_i, arr[1].to_i, arr[2].to_i)
      self.issued = RDF::Literal::Date.new(date)
    end
  end
end
