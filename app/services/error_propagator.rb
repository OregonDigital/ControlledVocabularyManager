class ErrorPropagator
  class << self
    def call(object, errors, limit = Float::INFINITY)
      unless object.valid?
        propagate(errors, truncated_messages(object, limit))
      end
    end

    private

    def propagate(errors, messages)
      messages.each do |message|
        errors.add(:base, message)
      end
    end

    def truncated_messages(object, limit)
      messages = object.errors.full_messages
      if messages.count <= limit
        return messages
      end
      messages[0..limit - 1] + ["Further errors exist but were suppressed"]
    end
  end
end
