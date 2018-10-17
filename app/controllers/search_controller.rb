class SearchController < ApplicationController
  def index
  end

  def search_results
    search = Vocabulary.search{ fulltext params[:search_value]}
    puts search.results
    @results = search.results
  end
end
