# frozen_string_literal: true

# Decorates set_modified
class SetsModified < SimpleDelegator
  def persist!
    set_modified
    __getobj__.persist!
  end

  def set_modified
    self.modified = RDF::Literal::Date.new(Time.now) if valid?
  end
end
