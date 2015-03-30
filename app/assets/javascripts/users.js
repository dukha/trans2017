/*
 * If the user is a translator then we want to show the possible jobs (versions + languages)
 * If not then we want to remove all jobs from that user
 */
/*var showTranslationJobs = function(){
  $('li#translation-jobs-list').show();
};
 
var showDevelopmentJobs = function(){
  $('li#development-jobs-list').show();
};
var showAdministrationJobs = function(){
  $('li#administration-jobs-list').show();
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
 
var removeAdministrationJobsFromUser = function(){
  $('li#administration-jobs-list'). hide();
  jQuery.each($('li#administration-jobs-list').find("input[type='checkbox']"), function(index, value){
    $(value).prop('checked', false);
  });
};
*/ 
// var toggleTranslationJobs = function(){
function toggleTranslationJobs(){
  toggleJobs('translation', 'translator');
/*  me = $('input#translator1') ;
  if(me.prop('checked')===true){
    showTranslationJobs();
  }else{
    removeTranslationJobsFromUser();
  };
  */
};


  
//  var toggleDevelopmentJobs = function(){
  function toggleDevelopmentJobs(){
    toggleJobs("development", 'developer');
    /*me = $('input#developer1') ;
    if(me.prop('checked')===true){
      showDevelopmentJobs();
    }else{
      removeDevelopmentJobsFromUser();
    };*/
  };
  
//  var toggleAdministrationJobs = function(){
  function toggleAdministrationJobs(){
    toggleJobs("administration", 'administrator');
    /*me = $('input#administrator1') ;
    if(me.prop('checked')===true){
      showAdministrationJobs();
    }else{
      removeAdministrationJobsFromUser();
    };*/
  };
  
  var toggleJobs = function(jobName, roleName){
     me = $('input#' + roleName + '1') ;
    if(me.prop('checked')===true){
      showJobs(jobName);
    }else{
      removeJobsFromUser(jobName);
    };
  };
  
  var showJobs = function(jobName){
   $('li#' +jobName + '-jobs-list'). show();
 };
 
 var removeJobsFromUser = function(jobName){
   li = $('li#' + jobName + '-jobs-list');
   li. hide();
   jQuery.each(li.find("input[type='checkbox']"), function(index, value){
     $(value).prop('checked', false);
   });
  
 };
 
$(document).ready(function(){
  toggleTranslationJobs();
  toggleDevelopmentJobs();
  toggleAdministrationJobs();
  $('input#translator1').click( function(){  
    toggleTranslationJobs();
    });
    
  $('input#developer1').click(function(){
    toggleDevelopmentJobs();
    });  
  $('input#administrator1').click( function(){
    toggleAdministrationJobs();
    });   
});
