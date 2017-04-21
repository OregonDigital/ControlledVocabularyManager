class RelationshipsController < ApplicationController
  delegate :relationship_form_repository, :all_relationships_query, :to => :injector
  delegate :deprecate_relationship_form_repository, :to => :deprecate_injector
  delegate :term_form_repository, :to => :term_injector
  skip_before_filter :require_admin, :only => [:review_update, :mark_reviewed]
  before_filter :set_form, :only => [:new, :create]

  include GitInterface
  def index
    #Grab all relationships
    @relationships = all_relationships_query.call
  end


  def create
    #Create new relationship form repository
    if params[:vocabulary]["term_uri"].empty?
      flash[:notice] = "You must provide a Term URI to establish a relationship."
      @relationship.attributes = vocabulary_params.except(:id, :term_uri, :hier_type)
      render :new
    elsif !validate_hier_exists(params[:vocabulary][:term_uri])
      flash[:notice] = "The Term URI you provided does not exist. Check the URI and try again."
      @relationship.attributes = vocabulary_params.except(:id, :term_uri, :hier_type)
      render :new
    else
      set_hier_params
      @relationship.attributes = vocabulary_params.except(:id, :term_uri, :hier_type)
      @relationship.set_languages(params[:vocabulary])
      @relationship.set_modified
      @relationship.set_issued
      if @relationship.is_valid?
        update_term(params[:vocabulary]['hier_parent'].first.to_s)
        update_term(params[:vocabulary]['hier_child'].first.to_s)
        @relationship.add_resource
        triples = @relationship.sort_stringify(@relationship.single_graph)
        check = rugged_create(params[:relationship][:id], triples, "creating")
        if check
          flash[:notice] = "#{params[:relationship][:id]} has been saved and added to the review queue."
        else
          flash[:notice] = "Something went wrong, please notify a systems administrator."
        end
        redirect_to "/relationships"
      else
        render :new
      end
    end
  end

  def edit
    @relationship = relationship_form_repository.find(params[:id])
  end

  def update
    edit_relationship_form = relationship_form_repository.find(params[:id])
    edit_relationship_form.attributes = vocabulary_params
    edit_relationship_form.set_languages(params[:vocabulary])
    edit_relationship_form.set_modified
    if edit_relationship_form.is_valid?
      triples = edit_relationship_form.sort_stringify(edit_relationship_form.single_graph)
      check = rugged_create(params[:id], triples, "updating")
      if check
        flash[:notice] = "Changes to #{params[:id]} have been saved and added to the review queue."
      else
        flash[:notice] = "Something went wrong, please notify a systems administrator."
      end
      redirect_to "/relationships"
    else
      @relationship = edit_relationship_form
      render "edit"
    end
  end

  def deprecate
    @relationship = relationship_form_repository.find(params[:id])
  end

  def deprecate_only
    edit_relationship_form = deprecate_relationship_form_repository.find(params[:id])
    edit_relationship_form.is_replaced_by = vocabulary_params[:is_replaced_by]
    if edit_relationship_form.is_valid?
      triples = edit_relationship_form.sort_stringify(edit_relationship_form.single_graph)
      check = rugged_create(params[:id], triples, "updating")
      if check
        flash[:notice] = "Changes to #{params[:id]} have been saved and added to the review queue."
      else
        flash[:notice] = "Something went wrong, please notify a systems administrator."
      end
      redirect_to "/relationships"

    else
      @relationship = edit_relationship_form
      render "deprecate"
    end
  end


  def review_update
    if Term.exists? params[:id]
      relationship_form = relationship_form_repository.find(params[:id])
      relationship_form.attributes = vocabulary_params.except(:id, :issued)
       action = "edit"
    else
      relationship_form = relationship_form_repository.new(params[:id], Relationship)
      relationship_form.attributes = vocabulary_params.except(:id, :issued)
      relationship_form.add_resource
      action = "new"
    end
    relationship_form.set_languages(params[:vocabulary])
    relationship_form.set_modified
    relationship_form.reset_issued(params[:issued])

    if relationship_form.is_valid?
      triples = relationship_form.sort_stringify(relationship_form.single_graph)
      check = rugged_create(params[:id], triples, "updating")
      if check
        flash[:notice] = "Changes to #{params[:id]} have been saved and added to the review queue."
      else
        flash[:notice] = "Something went wrong, please notify a systems administrator."
      end
      redirect_to review_queue_path
    else
      @relationship = relationship_form
      @term = relationship_form
      render action
    end
  end

  def mark_reviewed
    if Term.exists? params[:id]
      e_params = edit_params(params[:id])
      relationship_form = relationship_form_repository.find(params[:id])
      relationship_form.attributes = ParamCleaner.call(e_params[:vocabulary].reject{|k,v| k==:language})
      relationship_form.set_languages(e_params[:vocabulary])
    else
      @relationship = reassemble(params[:id] )
      relationship_form = RelationshipForm.new(@relationship, StandardRepository.new(nil, Relationship))
    end
    branch_commit = rugged_merge(params[:id])
    if branch_commit != 0
      if relationship_form.save
        expire_page controller: 'terms', action: 'show', id: params[:id], format: :html
        expire_page controller: 'terms', action: 'show', id: params[:id], format: :jsonld
        expire_page controller: 'terms', action: 'show', id: params[:id], format: :nt
        rugged_delete_branch(params[:id])
        flash[:notice] = "#{params[:id]} has been saved and is ready for use."
        redirect_to review_queue_path
      else
        rugged_rollback(branch_commit)
        flash[:notice] = "Something went wrong, and the term was not saved."
        redirect_to review_term_path(params[:id])
      end
    else
      flash[:notice] = "Something went wrong. Please notify a systems administrator."
      redirect_to review_term_path(params[:id])
    end
  end

private

  def set_hier_params
    if params[:vocabulary]['hier_type'].downcase == 'parent'
      params[:vocabulary]['hier_child'] = [params[:relationship][:originating_term_uri]]
      params[:vocabulary]['hier_parent'] = [params[:vocabulary][:term_uri]]
    else
      params[:vocabulary]['hier_child'] = [params[:vocabulary][:term_uri]]
      params[:vocabulary]['hier_parent'] = [params[:relationship][:originating_term_uri]]
    end
  end

  def parse_term_uri(uri)
    parts = uri.split('/')
    "#{parts.slice(-2)}/#{parts.slice(-1)}"
  end


  def validate_hier_exists(term_uri)
    term_form_repository.exists?(parse_term_uri(term_uri))
  end

  def update_term(uri)
    term_id = parse_term_uri(uri)
    edit_term_form = term_form_repository.find(term_id)
    edit_term_form.attributes["relationships"] << params[:relationship][:id]
    edit_term_form.set_modified
    if edit_term_form.is_valid?
      triples = edit_term_form.sort_stringify(edit_term_form.full_graph)
      check = rugged_create(term_id, triples, "updating")
      if check
        flash[:notice] = "#{term_id} has been saved and added to the review queue."
      else
        flash[:notice] = "Something went wrong, please notify a systems administrator."
      end
    else
      #TODO what do you do when the form is not valid.
    end
  end

  def relationship_params
    ParamCleaner.call(params[:vocabulary])
  end

  def vocabulary_params
    ParamCleaner.call(params[:vocabulary])
  end

  def injector
    @injector ||= RelationshipInjector.new(params)
  end

  def term_injector
    @term_injector ||= TermInjector.new(params)
  end

  def deprecate_injector
    @injector ||= DeprecateRelationshipInjector.new(params)
  end

  def set_form
    if params[:relationship]
      @relationship = relationship_form_repository.new(params[:relationship][:id])
      @term = term_form_repository.find(params[:relationship][:term_id])
    else
      @relationship = relationship_form_repository.new
      @term = term_form_repository.find(params[:term_id])
    end
  end
end
