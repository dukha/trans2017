//console.log("RDB defined here xx");
var RDB = namespace("translator.redis_database");


//console.log($("input.translator_publishing"));
function redisdbalter(){
  checkboxesClassSelector = "input.translator_publishing"; 
  $("div#rdb-table").on( "change", checkboxesClassSelector ,function(){  
    console.log("in cbs");
    clickedDom = this;
    parents = $(clickedDom).parents("div#rdb-table");
    cbs = $(parents[0]).find(checkboxesClassSelector);
    $.each(cbs, function(index, value){
      if(value == clickedDom){
        //continues to the next iteration
        if( $(value).prop("checked") == true){
          value.value = "1";
          return true;
        }else{
          value.value = "0";
          // terminate method
          return false;
        }  
      }else{
        value.value ="0";
        $(value).prop("checked",false);  
      }
    });
    });
    
};