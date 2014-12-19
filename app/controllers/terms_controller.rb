require 'json/ld'

class TermsController < ApplicationController
  before_filter :load_term, :only => :show

  def show
    respond_to do |format|
      format.html
      format.nt { render body: @term.dump(:ntriples), :content_type => Mime::NT }
      format.jsonld { render body: @term.dump(:jsonld, standard_prefixes: true), :content_type => Mime::JSONLD }
    end
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
end
