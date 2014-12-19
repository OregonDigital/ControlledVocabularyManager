require 'json/ld'

class TermsController < ApplicationController
  before_filter :load_term, :only => :show
  before_filter :find_vocabulary, :only => :new

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

  private

  def load_term
    @term = Term.new(params[:id])
    @term.persisted? or render_404
  end

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", :layout => true, :status => 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def find_vocabulary
    raise ActionController::RoutingError.new("Term not found") unless vocabulary.persisted?
  end
  
  def vocabulary
    @vocabulary ||= Vocabulary.new(params[:vocabulary_id])
  end
end
