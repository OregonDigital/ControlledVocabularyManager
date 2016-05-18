class TermsController < AdminController
  delegate :term_form_repository, :term_repository, :vocabulary_repository, :to => :injector
  delegate :deprecate_term_form_repository, :to => :deprecate_injector
  rescue_from ActiveTriples::NotFound, :with => :render_404
  skip_before_filter :check_auth, :only => [:show]
  include GitInterface
  def show
    @term = find_term
    @term.commit_history = get_history(@term.id)
    respond_to do |format|
      format.html
      format.nt { render body: @term.full_graph.dump(:ntriples), :content_type => Mime::NT }
      format.jsonld { render body: @term.full_graph.dump(:jsonld, standard_prefixes: true), :content_type => Mime::JSONLD }
    end
  end

  def new
    @term = term_form_repository.new
    @vocabulary = find_vocabulary
  end

  def create
    @vocabulary = find_vocabulary
    combined_id = CombinedId.new(params[:vocabulary_id], term_params[:id])
    term_form = term_form_repository.new(combined_id, params[:term_type].constantize)
    term_form.attributes = vocab_params.except(:id)
    term_form.set_languages(params[:vocabulary])
    if term_form.save
      triples = stringify(term_form.full_graph)
      rugged_create(combined_id.to_s, triples, "creating")
      rugged_merge(combined_id.to_s)
      redirect_to term_path(:id => term_form.id)
    else
      @term = term_form
      render "new"
    end
  end

  def edit
    @term = term_form_repository.find(params[:id])
  end

  def update
    edit_term_form = term_form_repository.find(params[:id])
    edit_term_form.attributes = vocab_params
    edit_term_form.set_languages(params[:vocabulary])
    if edit_term_form.save
      triples = stringify(edit_term_form.full_graph)
      rugged_create(params[:id], triples, "updating")
      rugged_merge(params[:id])
      redirect_to term_path(:id => params[:id])
    else
      @term = edit_term_form
      render "edit"
    end
  end

  def deprecate_only
    edit_term_form = deprecate_term_form_repository.find(params[:id])
    edit_term_form.is_replaced_by = vocab_params[:is_replaced_by]
    if edit_term_form.save
      triples = stringify(edit_term_form.full_graph)
      rugged_create(params[:id], triples, "updating")
      rugged_merge(params[:id])
      redirect_to term_path(:id => params[:id])
    else
      @term = edit_term_form
      render "deprecate"
    end
  end

  def deprecate
    @term = term_form_repository.find(params[:id])
  end

  def stringify (graph)
    graph.statements.to_a.sort_by{|x| x.predicate}.inject{|collector, element| collector.to_s + " " + element.to_s}
  end

  private

  def term_params
    ParamCleaner.call(params[:term])
  end

  def vocab_params
    ParamCleaner.call(params[:vocabulary])
  end

  def injector
    @injector ||= TermInjector.new(params)
  end

  def deprecate_injector
    @injector ||= DeprecateTermInjector.new(params)
  end

  def find_term
    term_repository.find(params[:id])
  end

  def find_vocabulary
    vocabulary_repository.find(params[:vocabulary_id])
  end

  def render_404
    respond_to do |format|
      format.html { render "terms/404", :status => 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def vocabulary
    @vocabulary ||= Vocabulary.find(params[:vocabulary_id])
  end

end
