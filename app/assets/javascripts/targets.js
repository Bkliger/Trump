var ready = function() {
//   var popup = new Foundation.Reveal($('#myModal'));
// popup.open();
// $(document).foundation();

  // $('#exampleModal1').foundation('open');
  $("#mail").prop(':checked', true);
    $("#mail").attr(':checked', true);
  $("input[name='target[contact_method]']").click(function() {
      if($('#email').is(':checked')) {
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
