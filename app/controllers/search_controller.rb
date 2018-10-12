class SearchController < ApplicationController
  def index
  end

  def search_results
    Vocabulary.search{ fulltext params[:search_value]}
  end
end
