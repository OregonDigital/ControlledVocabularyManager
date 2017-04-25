class ReviewController < AdminController
  include GitInterface
  before_filter :require_editor
  skip_before_filter :require_admin
  delegate :relationship_repository, :to => :relationship_injector
  delegate :term_repository, :to => :injector

  def index
    @terms = review_list
    if @terms.nil?
      flash[:notice] = "Something went wrong, please notify a system administrator."
      @terms = []
    end
    @terms
  end

  def show
    @term = reassemble(params[:id])
    if @term.blank?
      flash[:notice] = "#{params[:id]} could not be found in items for review."
      redirect_to review_queue_path
      return
    else
      @term.commit_history = get_history(@term.id, params[:id] + "_review")
    end
    @related_terms = {}
    if @term.attributes["relationships"]
      @term.attributes["relationships"].each do |rel_id|
        rel = find_relationship(rel_id)
        if rel.hier_parent.any? { |t| t.include? @term.id }
          t = find_related_term(rel.hier_child.first)
          @related_terms.merge!({"#{t.id}": { type: 'Child', date: rel.date, label: t.label}})
        elsif rel.hier_child.any? { |t| t.include? @term.id }
          t = find_related_term(rel.hier_parent.first)
          @related_terms.merge!({"#{t.id}": { type: 'Parent', date: rel.date, label: t.label}})
        end
      end
    end
  end

  def edit
    #@disable lets edit_form know whether or not to enable term type selector
    @disable = Term.exists? params[:id]
    if !params[:id].include? "/"
      @term = reassemble(params[:id])
    else
      @term = reassemble(params[:id])
    end
    if @term.blank?
      flash[:notice] = "#{params[:id]} could not be found in items for review."
      redirect_to review_queue_path
    end
  end

  private

  def parse_term_uri(uri)
    parts = uri.split('/')
    "#{parts.slice(-2)}/#{parts.slice(-1)}"
  end

  def find_related_term(related_uri)
    related_id = parse_term_uri(related_uri)
    term_repository.find(related_id)
  end

  def find_relationship(relationship_id)
    relationship_repository.find(relationship_id)
  end

  def injector
    @injector ||= TermInjector.new(params)
  end

  def relationship_injector
    @relationship_injector ||= RelationshipInjector.new(params)
  end

end


