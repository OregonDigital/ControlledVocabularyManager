jQuery ->
  $(document).on('click', 'input[type="text"]', (event) ->
    if $(this).parents('.form-group').find('.date').length > 0
      bind_all_datepickers()
      $(this).datepicker('show')
      return
  )

  bind_all_datepickers = () ->
    $('.date')
      .parents(".form-group")
      .find("input[type=text]")
      .each((i) ->
        $(this).removeClass('hasDatepicker')
          .removeData('datepicker')
          .unbind()
          .attr('id', 'datepicker_' + i)
          .datepicker({dateFormat: 'yy-mm-dd'})
      )
    return

