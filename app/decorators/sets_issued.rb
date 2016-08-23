class SetsIssued < SimpleDelegator
  def set_issued
    if valid? && new_record?
      self.issued = RDF::Literal::Date.new(Time.now)
    end
  end

  def reset_issued(strdate)
    return if strdate.blank?
    if valid?
      arr = strdate.split("-")
      date = Time.new(arr[0].to_i, arr[1].to_i, arr[2].to_i)
      self.issued = RDF::Literal::Date.new(date)
    end
  end

end
