jQuery(function() {
  // Initialize lunr with the fields to be searched, plus the boost.
  if($('.lunr_search').length > 0){

    var idx = lunr.Index.load(JSON.parse(window.data))

    // Event when the form is submitted
    $("#site_search").submit(function(event){
        event.preventDefault();
        var query = $("#search_box").val(); // Get the value for the text field
        var results = idx.search(query); // Get lunr to perform a search
        display_search_results(results); // Hand the results off to be displayed
    });

    function display_search_results(results) {
      var $search_results = $("#search_results");
        // Are there any results?
        if (results.length) {
          $search_results.empty(); // Clear any old results

          // Iterate over the results
          results.forEach(function(result) {
            var item = result.ref;

            // Build a snippet of HTML for this result
            var appendString = '<li>' + item + '</li>';

            // Add the snippet to the collection of results.
            $search_results.append(appendString);
          });
        } else {
          // If there are no results, let the user know.
          $search_results.html('<li>No results found.<br/>Please check spelling, spacing, yada...</li>');
        }
    }
  }
});