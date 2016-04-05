// Extended addToList, recreating basic functionality, triggering a new event
// AFTER the new field was added to the list, giving reference to the new field
HydraEditor.FieldManager.prototype.addToList = function(event) {
  event.preventDefault();
  var $activeField = $(event.target).parents(this.fieldWrapperClass)

  if (this.inputIsEmpty($activeField)) {
    this.displayEmptyWarning();
  } else {
    var $listing = $(this.listClass, this.element);
    this.clearEmptyWarning();
    $listing.append(this._newField($activeField));
    // the new event
    $(document).trigger("managed_field:new_field", $listing.find("li:last"));
  }
};

// After a user adds a newly cloned value field, reset the language SELECT to be
// the original default lanuage configured for this field.
//
//
// Listen to the new managed_field:new_field event. If there is a
// language-select with a default-language set, then make sure the associated
// option is set.
$(document).ready(function() {
  $(document).on("managed_field:new_field", function(ev, el) {
    var select = $(el).find("select.language-select");
    if(select.length > 0){
      var default_language = $(select).data("default-language");
      if(default_language){
        $(select).val(default_language);
      }
    }
  });
});
