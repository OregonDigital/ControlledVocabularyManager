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
    @child_term_labels = []
    @child_term_ids = []
    @child_dates = []
    @parent_term_labels = []
    @parent_term_ids = []
    @parent_dates = []
    if @term.attributes["relationships"]
      @term.attributes["relationships"].each do |rel_id|
        @rel = find_relationship(rel_id)
        if @rel.hier_parent.include?(@term.id) 
          @t = find_related_term(@rel.hier_child.first)
          @child_term_labels << @t.label
          @child_term_ids << @t.id
          @child_dates << @rel.date
        elsif @rel.hier_child.include?(@term.id)
          @t = find_related_term(@rel.hier_child.first)
          @parent_term_labels << @t.label
          @parent_term_ids << @t.id
          @parent_dates << @rel.date
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

  def find_related_term(related_id)
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


