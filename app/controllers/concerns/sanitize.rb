module Sanitize
  extend ActiveSupport::Concern

  def check_validity(string)
    messages = []
    messages = check_special_characters(string, messages)
    messages = check_for_spaces(string, messages)
    format_messages(messages)
  end

  def check_special_characters(string, messages)
    if string.match(/[?\\&]+/)
      messages << "Term contains special characters"
    end
    messages
  end

  def check_for_spaces(string, messages)
    if string.include? " "
      messages << "Term contains spaces"
    end
    messages
  end

  def format_messages(messages)
    message = messages.join(". ")
    unless message.empty?
      message = message + "."
    end
    message
  end
end
