# frozen_string_literal: true

module Sanitize
  extend ActiveSupport::Concern

  def check_validity(string)
    messages = []
    messages = check_special_characters(string, messages)
    messages = check_for_spaces(string, messages)
    format_messages(messages)
  end

  def check_special_characters(string, messages)
    messages << 'Term contains special characters' if string.match(/[?\\&]+/)
    messages
  end

  def check_for_spaces(string, messages)
    messages << 'Term contains spaces' if string.include? ' '
    messages
  end

  def format_messages(messages)
    message = messages.join('. ')
    message += '.' unless message.empty?
    message
  end

  def verify_uri(string)
    begin
      uri = URI.parse(string)
      resp = uri.is_a?(URI::HTTP)
    rescue URI::InvalidURIError
      resp = false
    end
    resp
  end
end
