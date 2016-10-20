class ReviewController < AdminController
include GitInterface
  before_filter :require_admin

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
    else
      @term.commit_history = get_history(@term.id, params[:id] + "_review")
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

end


