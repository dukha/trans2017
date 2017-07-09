//console.log("RDB defined here xx");
var RDB = namespace("translator.redis_database");


//console.log($("input.translator_publishing"));

/*
 * redisdbalter() ensures that only 1 db can be declared as translator publishing to production 
 * and only 1 db can be declared as translator publishing to test
 */ 
function redisdbalter(){
	
  translatorCheckboxesClassSelector = "input.translator_publishing"; 
  productionCheckboxesClassSelector = "input.production_publishing";
  $("div#rdb-table").on( "change", translatorCheckboxesClassSelector ,function(){  
    console.log("in tcbs");
    clickedDom = this;
    parents = $(clickedDom).parents("div#rdb-table");
    tcbs = $(parents[0]).find(translatorCheckboxesClassSelector);
    $.each(tcbs, function(index, value){
      if(value == clickedDom){
        //continues to the next iteration
        if(value.checked == true){	
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
    }); //each
    });//on
    
    $("div#rdb-table").on( "change", productionCheckboxesClassSelector ,function(){  
    console.log("in pcbs");
    clickedDom = this;
    parents = $(clickedDom).parents("div#rdb-table");
    pcbs = $(parents[0]).find(productionCheckboxesClassSelector);
    $.each(pcbs, function(index, value){
      if(value == clickedDom){
        //continues to the next iteration
        //if( $(value).prop("checked") == true){
        if(value.checked == true){ 	
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
    }); //each
    });//on
    
}; //fn redisdbalter
