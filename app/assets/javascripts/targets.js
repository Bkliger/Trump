var ready = function() {
  console.log("ready")
  $("#mail").prop(':checked', true);
    $("#mail").attr(':checked', true);
  console.log($("#mail").prop(':checked'))
    console.log($("#mail").attr(':checked'))
  console.log("checked")
  $("input[name='target[contact_method]']").click(function() {
    console.log("clicked")
      if($('#email').is(':checked')) {
        console.log("email is checked")
        $( "#email_input" ).removeClass( "hidden" );
        $( "#text_input" ).addClass( "hidden" );
      }
      else {
        console.log("else")
        $( "#text_input" ).removeClass( "hidden" );
        $( "#email_input" ).addClass( "hidden" );
        $("#mail").prop('checked', false);
      }
  });
};

$(document).ready(ready);
$(document).on('page:change', ready);
