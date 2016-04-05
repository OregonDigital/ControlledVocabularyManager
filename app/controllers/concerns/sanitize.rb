module Sanitize 
  extend ActiveSupport::Concern

  def check_validity(string)
    string.force_encoding("UTF-8").valid_encoding?
  end

end
