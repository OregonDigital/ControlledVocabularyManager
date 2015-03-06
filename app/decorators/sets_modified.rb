class SetsModified < SimpleDelegator
  def persist!
    if valid?
      self.modified = RDF::Literal::Date.new(Time.now)
    end
    __getobj__.persist!
  end
end
