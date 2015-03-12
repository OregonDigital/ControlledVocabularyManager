class SubjectsToGraph
  pattr_initialize :sparql_client, :subjects

  def graph
    SolutionsToGraph.new(solutions).graph
  end

  private

  def query
    sparql_client.select.where([:s, :p, :o]).filter(filter)
  end

  def filter
    "?s IN (#{subjects_string})"
  end

  def subjects_string
    subjects.map{|x| "<#{x}>"}.join(", ")
  end

  def solutions
    query.each_solution.to_a
  end

end
