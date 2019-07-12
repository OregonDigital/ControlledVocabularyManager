# frozen_string_literal: true

class ErrorPropagator < Struct.new(:object, :errors, :limit)
  def run
    if object.valid?
      return
    end

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
      messages[0..limit - 1] + ["Further errors exist but were suppressed"]
    else
      messages
    end
  end

  def exceeds_limit(value)
    if !limit
      return false
    end

    value > limit
  end
end
