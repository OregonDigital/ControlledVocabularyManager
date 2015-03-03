class IdExists < ActiveModel::Validator
  def validate(record)
    if leaf_id(record).blank?
      record.errors.add(:id, "can't be blank")
    end
  end

  private

  def leaf_id(record)
    return "" if record.rdf_subject.node?
    TermUri.new(record.rdf_subject).leaf
  end

end
