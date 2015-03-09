class PaginatableTerms
  include Enumerable
  include Kaminari::PageScopeMethods
  include Kaminari::ConfigurationMethods::ClassMethods
  delegate :each, :to => :paged_query_result
  attr_reader :limit_value
  
  def initialize(query, options={})
    @query = query
    @page_value = options[:page]
    @limit_value = options[:limit]
    @options = options
  end

  def page(page)
    self.class.new(query, options.merge(:page => page))
  end

  def per(per)
    self.class.new(query, options.merge(:limit => per))
  end

  def offset_value
    limit_value*(page_value-1)
  end

  def total_count
    @total_count ||= query.subjects.length
  end

  def entry_name
    "term"
  end

  private

  attr_reader :query, :page_value, :options

  def paged_query
    @paged_query ||= query.limit(limit_value).offset(offset_value)
  end

  def paged_query_result
    @paged_query_result ||= paged_query.all
  end
end
