module Sanitize
  extend ActiveSupport::Concern

  def check_validity(string)
    messages = []
    messages = check_utf8(string, messages)
    messages = check_for_spaces(string, messages)
    format_messages(messages)
  end

  def check_utf8(string, messages)
    unless string.force_encoding("UTF-8").valid_encoding?
      messages << "Term is not valid UTF-8"
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
    message = messages.join("; ")
    unless message.empty?
      message = message + "."
    end
    message
  end

end

