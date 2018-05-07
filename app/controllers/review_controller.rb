class ReviewController < AdminController
  include GitInterface
  before_filter :require_editor
  skip_before_filter :require_admin

  def index
    @terms = review_list
    if @terms.nil?
      flash[:error] = "Something went wrong, please notify a system administrator."
      @terms = []
    end
    @terms
  end

  def show
    @term = reassemble(params[:id])
    if @term.blank?
      flash[:alert] = "#{params[:id]} could not be found in items for review."
      redirect_to review_queue_path
    else
      #@term.commit_history = get_history(@term.id, params[:id] + "_review")
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
      flash[:alert] = "#{params[:id]} could not be found in items for review."
      redirect_to review_queue_path
    end
  end

  def discard
    success = rugged_delete_branch(params[:id])
    if !success
      flash[:error] = "Something went wrong, please alert a system administrator"
    else
      message = Term.exists?(params[:id]) ? "Changes to #{params[:id]} have been discarded." : "#{params[:id]} has been discarded."
      flash[:notice] = message
    end
    redirect_to review_queue_path
  end

end
