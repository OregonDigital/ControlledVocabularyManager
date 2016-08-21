class SetsModified < SimpleDelegator
  def persist!
    set_modified
    __getobj__.persist!
  end

  def set_modified
    if valid?
      self.modified = RDF::Literal::Date.new(Time.now)
    end
  end
end
