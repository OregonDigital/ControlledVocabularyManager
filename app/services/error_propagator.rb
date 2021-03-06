# frozen_string_literal: true

# Error Propogator
class ErrorPropagator < Struct.new(:object, :errors, :limit)
  def run
    return if object.valid?

    truncated_messages.each do |message|
      errors.add(:base, message)
    end
  end

  def messages
    @messages ||= object.errors.full_messages
  end

  private

  def truncated_messages
    if exceeds_limit(messages.count)
      messages[0..limit - 1] + ['Further errors exist but were suppressed']
    else
      messages
    end
  end

  def exceeds_limit(value)
    return false unless limit

    value > limit
  end
end
