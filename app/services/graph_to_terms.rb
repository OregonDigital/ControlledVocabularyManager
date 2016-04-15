class GraphToTerms < Struct.new(:resource_factory, :graph)
  attr_reader :klass

  def run
    graph.each_statement.group_by(&:subject).map do |subject, triples|
      type_of_graph(triples)
      build_term(subject, triples)
    end
  end

  def type_of_graph(triples)
    # iterate through the objects of each of the triples to determine what
    # type of vocabulary, predicate, or term this graph is representing so
    # that the proper type of repository can be persisted
    @klass = nil
    triples.each do |t|
      if @klass.nil?
        case t.object
        when Vocabulary.type
          @klass = Vocabulary
        when Predicate.type
          @klass = Predicate
        when Concept.type
          @klass = Concept
        when CorporateName.type
          @klass = CorporateName
        when Geographic.type
          @klass = Geographic
        when PersonalName.type
          @klass = PersonalName
        when Title.type
          @klass = Title
        when Topic.type
          @klass = Topic
        else
          @klass = Term
        end
      end
    end
  end

  private

  def build_term(subject, triples)
    # sets the class that the PolymorphicTermRepository will use to determine
    # how to persist the data to the triplestore
    resource_factory.repository_type = klass
    t = resource_factory.new(subject)
    t.insert(*triples)
    t
  end
end
