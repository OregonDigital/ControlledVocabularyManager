class TermInstanceAdapter < Sunspot::Adapters::InstanceAdapter
  def id
    @instance.id
  end
end
