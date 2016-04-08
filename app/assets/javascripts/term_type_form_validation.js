// Hidden term fields that have current values should be captured to display a
// confirmation dialog to the user so that they are aware that those fields will
// be scrubbed and not persisted on the backend.
var validate_term_form = function() {
  var validation_errors = [];
  var $hidden_labels = $("label.toggle-model-visibility:hidden");
  $hidden_labels.each(function(i, el) {
    var $hidden_inputs = $(el).next(".form-group").find("input");
    $hidden_inputs.each(function(j, input) {
      if ($(input).val().length > 0) {
        validation_errors.push([$(el).text(), $(input).val()]);
      }
    });
  });
  return validation_errors;
}

// Hidden term fields with input values need to have them cleared before the form is
// submitted to prevent persisting unrelated data for the type of term being
// submitted.
var scrub_invalid_fields = function() {
  var $hidden_labels = $("label.toggle-model-visibility:hidden");
  $hidden_labels.each(function(i, el) {
    var $hidden_inputs = $(el).next(".form-group").find("input");
    $hidden_inputs.each(function(j, input) {
      if ($(input).val().length > 0) {
        $(input).val('');
      }
    });
  });
}

$(document).ready(function() {
  // Only kick this off if the SELECT exists on the page, which it does not when
  // the page is rendered for a vocabulary (instead of a term)
  if ($("select#term_type").length > 0) {
    var confirmed_submit = false;
    var validation_errors = [];

    // Bind to the submit action on the form
    $(document).on('submit', 'form', function(ev) {
      //reset the validation_errors and check the form each time the form is
      //being submitted
      validation_errors = [];
      validation_errors = validate_term_form();

      // Recursive flow:
      // 1. User clicks 'Create Term'
      // 2. If the user has NOT yet confirmed the submit, and there are validation errors, pop a modal to have the user confirm.
      // 3. In the modal if the user confirms, resubmit the form.
      // 4. If the user has confirmed they are submitting the form, and the validation errors exist, then scrub_invalid_forms and resubmit the form.
      // 5. The user has confirmed, the invalid fields scrubbed, so the submit event falls through and posts the form successfully.
      if (!confirmed_submit && validation_errors.length > 0) {
        ev.preventDefault();
        $("#formValidationModal").modal('show');
      } else if (confirmed_submit && validation_errors.length > 0) {
        ev.preventDefault();
        scrub_invalid_fields();
        $("form").submit();
      }
    });

    // Modal "Submit" button clicked
    $(document).on("click", "#formValidationConfirmed", function(ev) {
      confirmed_submit = true;
      $("form").submit();
    });

    // Bootstrap event fired by the modal when it is shown.
    //
    // Fill the appropriate HTML with the current validation errors, and term
    // type information
    $("#formValidationModal").on("show.bs.modal", function(ev) {
      var $modal = $(this);
      var $ul = $modal.find("ul");
      $("#formValidationTermType").text($(
        "select#term_type option:selected").text());
      $ul.empty();
      $(validation_errors).each(function(i, e) {
        $ul.append("<li><b>" + e[0] + "</b> : " + e[1] + "</li>");
      });
    });
  }
});
