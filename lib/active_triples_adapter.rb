module ActiveTriplesAdapter
  extend ActiveSupport::Concern
  included do
    alias_method :orig_reload, :reload
    def reload
    end
  end


  module ClassMethods
    def find(uri)
      result = new(uri)
      result.orig_reload
      raise ActiveTriples::NotFound if result.statements.to_a.length == 0
      result
    end
  end

end
