class SetsIssued < SimpleDelegator
  def persist!
    if valid? && new_record?
      self.issued = RDF::Literal::Date.new(Time.now)
    end
    __getobj__.persist!
  end
end
