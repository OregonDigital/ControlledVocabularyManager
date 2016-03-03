jQuery ->
  $(".multi-value-field").manage_fields()
  $(".multi-value-field").on("managed_field:remove", (event, removed) ->
    removed = $(removed)
    id_field = removed.find("input[name$='[id]']")
    if(id_field.length > 0) 
      destroy_field = $("<input type='hidden'>")
      destroy_field.attr("name", id_field.attr("name").replace(/\[id\]/,"[_destroy]"))
      destroy_field.val(true)
      destroy_field.insertAfter(id_field)
      removed.hide()
      removed.appendTo($(this))
  )
  $(".multi-value-field").on("managed_field:add", (event) ->
    # Not added to DOM yet, have to add a short cooldown.
    window.setTimeout(->
      target = $(event.target)
      last_child = target.find(".field-wrapper").last()
      last_child.find("div[class$='_id']").remove()
      inputs = last_child.find('input')
      firstChild = inputs.first()
      matches_array = firstChild.attr("name").match(/\[(.*)\]\[(.*)\]\[(.*)\]/)
      if matches_array?
        id = parseInt(matches_array[2])
        html = last_child.html()
        html = html.replace(new RegExp("\\["+id+"\\]", 'g'),'['+(id+1)+']')
        html = html.replace(new RegExp('_'+id+'_', 'g'), '_'+(id+1)+'_')
        last_child.html(html)
    , 15)
  )
