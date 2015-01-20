
  //this script does jquery ui tooltips
  
  $(function() {
    $( document ).tooltip({
      position: {
        my: "center bottom-20",
        at: "center top",
        using: function( position, feedback ) {
          $( this ).css( position );
          $( "<div>" )
            .addClass( "arrow" )
            .addClass( feedback.vertical )
            .addClass( feedback.horizontal )
            .appendTo( this );
        }
      },
      // We need to do it this way so that we don't break the html standard of no markup in title attribute. 
      // Not sure whether markup in data-* attrib's is the same xxs vulnerability though...' 
      items: "[data-tooltip]",
      content: function () {
        return $(this).attr("data-tooltip");
    }
    });
  });
  
