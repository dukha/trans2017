// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//= require jquery
// require jquery-2.0.3
// require jquery-1.8.0
// require jquery
//= require jquery_ujs
//= require jquery-ui
//= require turbolinks
//
// require jquery-ui-1.10.3.custom.js
// ujs has to be in for delete to work and for other rails ajax
// require jquery_ujs
//= require hoverIntent.js
//= require jquery.cookie.js
//= require jquery.cookies.2.2.0_1.js
//= require jquery.treeview.js
// Needed for editing a M-N relationship using listboxes (languages in calmapp new)
//= require jQuery.dualListBox-1.3.js
//= require cocoon
//Is hotkeys used?
//= require jquery.hotkeys.js
//= require jquery.selectboxes
// These 3 below are needed for editable js tables. Currently not used: using best_in_place instead
// require jquery.dataTables.js
// require jquery.jeditable.js
// require KeyTable.js
//= require unobtrusive_flash
// These below are in and required by best_in_place gem
//= require jquery.purr
//= require best_in_place
//= require best_in_place.jquery-ui
//= require popup
// utility functions like _.escape()
//= require underscore
// not working
//= jQuery.Autosize.Input.js
// require redis_databases
// require translations_uploads
//= require_self
//= require_tree .

if(UnobtrusiveFlash.flashOptions == null){
  UnobtrusiveFlash.flashOptions= {};
}
UnobtrusiveFlash.flashOptions['timeout'] = 10000;

var HELP = namespace("help");

function deleteBlanksFromSelectBox(boxId){
           $(boxId + " :empty").remove();
         }
         

/*
 * This function enables us to declare a namespace for different groups of javascirpt functions and  vars
 * Use it!
 * Example usage (from course_application.js
 *   
 *    //Define a namespace for course_application
 *    var CA = namespace("calm.course_application");
 *    //Use Index for a container object for all variables and functions used in the index
 *    CA.Index = function(){
 *      //All the functions and variables are going to be "static", so define outside the container
 *      //but as belonging to the container   
 *    };
 *     //declare a static var in the namespace for the index page
 *     CA.Index.allRows = []; 
 */
function namespace(namespaceString) {
    var parts = namespaceString.split('.'),
        parent = window,
        currentPart = '';    
        
    for(var i = 0, length = parts.length; i < length; i++) {
        currentPart = parts[i];
        parent[currentPart] = parent[currentPart] || {};
        parent = parent[currentPart];
    }
    
    return parent;
}
/*
 * Takes care of case where id is being used as a selector
 * could be 'input#myid' (valid) or myId (invalid) or #myId.
 * Makes sure case 2 is good.
 */
function id2Selector( id){
  return (id.indexOf('#')== -1 && id.indexOf('.')==-1 ?'#' : '') + id;
}

/*
 * JQuery-ui has a new Button control(in queruy-ui 1.8.23) which can be used as a checkbox, radio or pushbutton
 * When manipulating the checkbox programatically you need to display it correctly at the same time.
 * This function does that.
 * The button depends on both the label and the input. Thus we have to work on both.
 */
function jQueryCheckboxButtonActivate(inputId, labelId, active){
        $(id2Selector(inputId)).attr('checked', active);
        labelSelector= $(id2Selector(labelId));
        labelSelector.toggleClass('ui-state-active', active);
        labelSelector.toggleClass('ui-state-default', !active);
}

/*
 * iContains is a case insensitive search selector that performs and is used in the same way as
 * the jquery selector contains. (:contains) is case sensitive.
 * This selector depends on jquery >= 1.8.0
 */
jQuery.expr[":"].iContains = jQuery.expr.createPseudo(function(arg) {
      return function( elem ) {
            //txt = ((jQuery(elem).text() == undefined) ? '' : jQuery(elem).text());
            arg = ((arg == undefined) ? '' : arg);
            return jQuery(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0;
                               };
});
/*
 * This implements a quick search function for a searh on a standard calm html table
 * @param searchFieldSelector is the selector for the field where the criterion is typed eg. #search
 * @param tableToSearchSelector is the table where you want to search
 * 
 * This function uses a combination of jquery selectors and jquery filters, (like .parent(), .not()
 * It also uses our custom case insensitive selector, :iContains()
 * NB this searches all columns in the page, whether hidden or not: for example if email is hidden and the criterion matches the email
 * then the row will be shown, even though the reason is not seen by the user
 */
showHideRowsViaUserCriterion = function(searchFieldSelector, tableToSearchSelector){
  searchFieldSelector = id2Selector(searchFieldSelector);
  tableToSearchSelector = id2Selector(tableToSearchSelector);
  sel0 = tableToSearchSelector + ' tbody tr:gt(0)';
  sel1 = sel0 + '>td:not(td.link)';
  sel2 = ':iContains(' + $(searchFieldSelector).val() +')'; 
  selector = sel1 + sel2 ;
  //console.log('sel = ' + selector);
  //console.log($(selector));
  dom = $(selector);
  parentDom = dom.parent();
  //This sel find the right one but it is overwritten b y a bad notsel
  //console.log('sel parent :');
  //console.log(parentDom);
  parentDom.show();
  negativeDom = $(sel0).not( $(selector).parent());
  //console.log( negativeDom);
  negativeDom.hide(); 
}
//Generalised defaults for jquery ui timepicker

//calmLocale = "< %=I18n.locale.to_s%>";

/*
 * This is called on Close of a timepicker to set the new formatted date according to the I18n settings
 * Not that 2 extra has keys are assumed here: localTimeSeparator and localShowPeriod. These are put into the hash
 * on the server (ruby code). Make sure that you use internationalisation_for_timepicker() or internationalisation_for_datepicker() to setup your picker. 
 * 
 */  
var timepickerOnSelect = function(time, instance){
  // 0-23
      hrs= instance.hours;
      mins=instance.minutes;
      mins= mins<10?"0"+mins:mins; 
      formattingSeparator = instance.settings.localTimeSeparator
      ampm = instance.settings.amPmText;
      if(instance.settings.localShowPeriod){
        if(hrs==0){
          newHour=12;
          suffix = ampm[0];
        }else if(hrs == 12){
          newHour = 12;
          suffix = ampm[1];
        }else{  
          newHour = hrs%12;
          suffix = hrs<12?ampm[0] : ampm[1];
        } //end hrs  
      }else{
        //We are in 24hour territory
        newHour=hrs<10?'0'+hrs:hrs;
        suffix='';
      }//end localshowperiod
      return newHour + formattingSeparator + mins + " " + suffix;
};//end timepickerOnSelect


 //This function is necesary to remove a blank that formtastic leaves in the first listbox of a dual listbox setup (For a M-N relation.).
 function deleteBlanksFromSelectBox(boxId){
           $(boxId + " :empty").remove();
 }
 
 var concatenateRowSelectionButton = function(htmlIdPrefix, atDbId ){
   html ="<button id='" + htmlIdPrefix + atDbId.toString() + "' class='select'>" + selectTranslation + "</button>";
  return html;
  }; 
 /*
  * Takes the list of responsibilites and puts them into a select control
  */ 
 var responsibilityTypesList2Select = function(htmlIdPrefix, atId, blank, selectedValue){//, responsibilityTypesList ){
     html = "<select id='" + htmlIdPrefix + atId.toString() +"' class='" + htmlIdPrefix + "'>";
     if(blank){
       html= html + "<option value = ''></option>";
     };
     
     selectBoxContent= gon.atResponsibilityTypesTranslationsList;//responsibilityTypesList;
     //The map function is equivalent to each()
     selectBoxContent.map(function(responsibility_type){
       if(selectedValue){
         selectedAttr = ((selectedValue==responsibility_type['at_responsibility_type']['translation_code'])?" selected='selected' ":"");
       }else{
         selectedAttr ='';
       }
     html = html + "<option id= '" + htmlIdPrefix + atId + "' "+ selectedAttr +
                           " value = '" + responsibility_type['at_responsibility_type']['translation_code'].toString() + "'>" + 
                           responsibility_type['at_responsibility_type']['translation'] + 
                           "</option>";    
     });//end map()
     html= html + "</select>";
     return html;
 };  
  /*
   * Concatenates a control into a td link class. 
   */
  var concatenateLinkCellWithSelectControl = function( selectControlHtml){
   html =  "<td class='link'>" + selectControlHtml + "</td>";
   return html;
 };
  htmlIdFromDbid = function(prefix, dbId){
    return "row"+dbId;
  };
  
/*
   * As each row is selected it is removed from the searchresults table
   * This comment is not for this function???
   */
  removeSearchResults = function(tableSelector, hasHeader){
    //$(CSE.Form.atSearchResultsSelector + " " + 'tr:not(:first)').remove();
    //$(CSE.Form.atSearchResultsSelector + " " + (hasTableheader ? 'tr:not(:first)' : 'tr')).remove();
    //console.log(hasTableHeader(tableSelector));
    //console.log(((hasTableHeader(tableSelector)) ? ('tr:not(:first)') : 'tr'));
    selector = tableSelector + " " + ((hasTableHeader(tableSelector)) ? ('tr:not(:first)') : 'tr');
    //console.log("qqq " + selector);
    $(selector).remove();
  };
  
  hasTableHeader= function(tableSelector){
    return $(tableSelector).find("th").length != 0;
  }  ; 