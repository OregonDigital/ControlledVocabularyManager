class ReviewController < AdminController
include GitInterface
  
  def index
    @terms = review_list
  end

  def show
    @term = reassemble(params[:id])
    @term.commit_history = get_history(@term.id, @term.id + "_review")
  end

  def edit
    #@disable lets edit_form know whether or not to enable term type selector
    @disable = Term.exists? params[:id]
    if !params[:id].include? "/"
      @term = reassemble(params[:id])
    else
      @term = reassemble(params[:id])
    end
  end

end


