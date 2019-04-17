class LocalCollection < Term
  configure :type => RDF::URI("http://purl.org/dc/dcmitype/Collection")

  def self.option_text
    "Local Collection"
  end

  def self.uri
    self.type.to_s
  end

  def self.visible_form_fields
    %w[label alternate_name ark local date comment is_replaced_by is_defined_by same_as modified issued]
  end

  def fields
    [:label, :alternate_name, :ark, :local, :date, :comment] | super
  end
end
