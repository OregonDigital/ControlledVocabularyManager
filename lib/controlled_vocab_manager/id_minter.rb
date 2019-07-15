# frozen_string_literal: true

module ControlledVocabManager
  # ID Minter
  class IdMinter
    class << self
      def mint_id
        generate_id
      end

      def generate_id
        o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
        (0...8).map { o[rand(o.length)] }.join
      end
    end
  end
end
