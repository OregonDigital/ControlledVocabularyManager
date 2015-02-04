class TermsController < ApplicationController
  attr_writer :term, :vocabulary
  before_filter :load_term, :only => :show
  before_filter :vocabulary, :only => :new
  rescue_from ActiveTriples::NotFound, :with => :render_404

  def show
    respond_to do |format|
      format.html
      format.nt { render body: @term.dump(:ntriples), :content_type => Mime::NT }
      format.jsonld { render body: @term.dump(:jsonld, standard_prefixes: true), :content_type => Mime::JSONLD }
    end
  end

  def new
    @term = Term.new
  end

  def create
    TermCreator.call(params[:term], vocabulary, [CreateResponder.new(self)])
  end

  private

  class CreateResponder < SimpleDelegator

    def success(term, _)
      redirect_to term_path(term)
    end

    def failure(term, vocabulary)
      self.term = term
      self.vocabulary = vocabulary
      render "new"
    end

  end

  def load_term
    self.term = Term.find(params[:id])
  end

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", :layout => true, :status => 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def vocabulary
    @vocabulary ||= Vocabulary.find(params[:vocabulary_id])
  end
end
