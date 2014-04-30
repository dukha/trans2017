$().ready(function(){
  $("button.ok").click(function(){
    tr = $(this).parents('tr.dataodd', 'tr.dataeven');
  });
});
