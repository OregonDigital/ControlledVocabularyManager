class IdExists < ActiveModel::Validations::PresenceValidator
  def initialize(*)
    super(:attributes => :id)
  end
end
