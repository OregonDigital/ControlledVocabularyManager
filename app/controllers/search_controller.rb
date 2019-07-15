# frozen_string_literal: true

# Search Controller
class SearchController < ApplicationController
  def search_results
    @search_query = params[:query] || session[:query]
    session[:query] = @search_query if @search_query
    page_number = params[:page] || 1
    search = Sunspot.search(Term) do |query|
      query.keywords @search_query, highlight: true
      query.paginate page: page_number, per_page: 10
      query.order_by :score, :desc
    end
    @hits = search.hits
  end
end
