// Find the submit type button, with the has-button-spinner class, prepend the
// button_spinner and disable the button. If a second form submit is fired,
// don't inject another spinner.
$(document).ready(function() {
  $submit_button = $("button[type='submit'].has-button-spinner");
  $(document).on('submit', 'form', function(event) {
    if ($submit_button.find("span.spinning").length == 0) {
      // Bootstrapified spinner for injecting into submit style BUTTON elements
      var button_spinner = document.createElement('span');
      button_spinner.className = "glyphicon glyphicon-refresh spinning";
      $submit_button.prepend(button_spinner).attr('disabled', 'disabled');
    }
  });
});
