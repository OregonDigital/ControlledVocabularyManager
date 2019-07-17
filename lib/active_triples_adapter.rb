# frozen_string_literal: true

module ActiveTriplesAdapter
  extend ActiveSupport::Concern
  included do
    alias_method :orig_reload, :reload
    def reload; end
  end

  module ClassMethods
    def find(uri)
      result = new(uri)
      result.orig_reload
      relevant_triples = result.statements.to_a
      if type
        relevant_triples.reject! { |x| (x.predicate == RDF.type && x.object.to_s == type.to_s) }
      end
      raise ActiveTriples::NotFound if relevant_triples.empty?

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
