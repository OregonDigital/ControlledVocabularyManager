class ControlledVocabulariesController < ApplicationController
  before_filter :load_vocab, :only => :show
  require 'json/ld'

  def show
    respond_to do |format|
      format.html
      format.nt { render body: @vocab.dump(:ntriples), :content_type => Mime::NT }
      format.jsonld { render body: @vocab.dump(:jsonld, standard_prefixes: true), :content_type => Mime::JSONLD }
    end
  end

  private

  def load_vocab
    @vocab = ControlledVocabulary.new(params[:id])
    @vocab.persisted? or render_404
  end

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", :layout => true, :status => 404 }
      format.all { render nothing: true, status: 404 }
    end
  end
end
