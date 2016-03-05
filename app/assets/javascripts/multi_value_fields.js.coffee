jQuery ->
  $(".multi-value-field").manage_fields()
  remover  = $("<button type=\"button\" class=\"btn btn-danger remove\"><i class=\"icon-white glyphicon-minus\"></i><span>Remove</span></button>")
  $('.field-wrapper:nth-child(n+2):last-child .field-controls').append(remover)
  $(".multi-value-field").on("managed_field:remove", (event, removed) ->
      items = $(event.target).find("li")
      if(items.length == 1)
        $(event.target).find("button.remove").hide()
   )

