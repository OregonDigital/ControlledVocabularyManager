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

    def exists?(uri)
      begin
        find(uri)
      rescue ActiveTriples::NotFound
        return false
      end
      true
    end
  end

end
