
  //this script does jquery ui tooltips
  
  $(function() {
    $( document ).tooltip({
      position: {
        
        // my gives the position on the TT to do the aligning
        my: "center bottom",
        // at gives the posn on the target element (eg ubtton text field)
        at: "center top + 5",
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
        return "<div class='tt'>" + $(this).attr("data-tooltip") + "</div>";
    }
    });
  });
  
