var ready = function() {
  $("#mail").prop('checked', true);
  $("input[name='contact_method']").click(function() {
      if($('#contact_method_1').is(':checked')) {
        $( "#email_input" ).removeClass( "hidden" );
        $( "#text_input" ).addClass( "hidden" );
      }
      else {
        $( "#text_input" ).removeClass( "hidden" );
        $( "#email_input" ).addClass( "hidden" );
        $("#mail").prop('checked', false);
      }
  });
};

$(document).ready(ready);
$(document).on('page:change', ready);
