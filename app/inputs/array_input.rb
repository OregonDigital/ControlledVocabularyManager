class ArrayInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    input_html_options[:type] ||= input_type

    return text_field(nil).html_safe if attributes_array.empty?
    attributes_array.map do |array_el|
      text_field(array_el)
    end.join.html_safe
  end

  def attributes_array
    @attributes_array ||= Array(object.public_send(attribute_name))
  end

  def text_field(array_el)
    @builder.text_field(nil, input_html_options.merge(value: array_el, name: "#{object_name}[#{attribute_name}][]"))
  end

  def input_type
    :text
  end
end
