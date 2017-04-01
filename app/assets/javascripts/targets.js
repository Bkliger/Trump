var ready = function() {

// $(document).foundation();
  $(document).foundation();
  console.log($("#exampleModal1").data("notice"))
  if (($("#exampleModal1").data("notice"))) {
  $('#exampleModal1').foundation( 'open');
  }

//   var popup = new Foundation.Reveal($('#myModal'));
// popup.open();
  // if ($("#accordion").data("page") != "true"){

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
$(document).on('page:load', ready);
$(document).on('turbolinks:load', ready);
