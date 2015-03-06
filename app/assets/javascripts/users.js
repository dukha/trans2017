/*
 * If the user is a translator then we want to show the possible jobs (versions + languages)
 * If not then we want to remove all jobs from that user
 */
 var showTranslationJobs = function(){
   $('li#translation-jobs-list'). show();
 };
 
  var showDevelopmentJobs = function(){
   $('li#development-jobs-list'). show();
 };
 
 var removeTranslationJobsFromUser = function(){
   $('li#translation-jobs-list'). hide();
   jQuery.each($('li#translation-jobs-list').find("input[type='checkbox']"), function(index, value){
     $(value).prop('checked', false);
   });
 };
 
 var removeDevelopmentJobsFromUser = function(){
   $('li#development-jobs-list'). hide();
   jQuery.each($('li#development-jobs-list').find("input[type='checkbox']"), function(index, value){
     $(value).prop('checked', false);
   });
 };
 
 var toggleTranslationJobs = function(){
    me = $('input#translator1') ;
    if(me.prop('checked')==true){
      showTranslationJobs();
    }else{
      removeTranslationJobsFromUser();
    }
  };
  
  var toggleDevelopmentJobs = function(){
    me = $('input#developer1') ;
    if(me.prop('checked')==true){
      showDevelopmentJobs();
    }else{
      removeDevelopmentJobsFromUser();
    }
  };