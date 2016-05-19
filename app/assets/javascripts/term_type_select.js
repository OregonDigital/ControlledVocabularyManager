// LABELs related to term fields have an included data-visible-for property with an array of term types
// that they (and their related input form-group collection DIVs) should be visible for. When a user changes the SELECT
// option, the form fields are hidden and then made visible for any LABEL/DIV which has the currently selected
// term_type in its data-visible-for property.
var set_field_visibility = function(selector){
  var selected_model = $(selector).val();
  var $labels = $("label.toggle-model-visibility");
  //console.log("Selected '" + selected_model + "', displaying only related LABEL and form-group DIVs.");
  $labels.hide();
  $labels.next(".form-group").hide();
  var $labels_to_show = $labels.filter(function(i, el){
    return $(el).data('visible-for').indexOf(selected_model) > -1;
  });
  $labels_to_show.each(function(i, el){
    $(el).show();
    $(el).next(".form-group").show();
  });
}

// set the initial state of the form
$(document).ready(function(){
  $("select#term_type").on("change", function(event){
    set_field_visibility("select#term_type");
  });

  // Only kick this off if the SELECT exists on the page, which it does not when
  // the page is rendered for a vocabulary (instead of a term)
  if($("select#term_type").length > 0){
    set_field_visibility($("select#term_type"));
  }
});
