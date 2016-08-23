class SetsModified < SimpleDelegator
  def set_modified
    if valid?
      self.modified = RDF::Literal::Date.new(Time.now)
    end
  end
end
