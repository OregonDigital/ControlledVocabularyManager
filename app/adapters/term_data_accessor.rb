class TermDataAccessor < Sunspot::Adapters::DataAccessor
  def load(id)
    @clazz.where(id: id.to_i)
  end

  def load_all(ids)
    @clazz.includes(:thing)
  end
end
