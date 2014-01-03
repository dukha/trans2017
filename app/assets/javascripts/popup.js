        //SETTING UP OUR POPUP  
    //0 means disabled; 1 means enabled;  
    //var popupStatus = 0;  
    //loading popup with jQuery magic!  
    function loadPopup(popupSelector, backgroundSelector, status){  
    //loads popup only if it is disabled  
      if(status==0){  
        $(backgroundSelector).css({  
        "opacity": "0.7"  
        });  
        console.log("loading popup");
        $(backgroundSelector).fadeIn("slow");  
        $(popupSelector).fadeIn("slow");  
        status = 1;  
      }  
      return status;
    }
    
    
    //disabling popup with jQuery magic!  
    function closePopup(popupSelector, backgroundSelector, status){  
    //disables popup only if it is enabled  
      if(status==1){  
        console.log("disabling popup");
        //$(CSE.Form.atPopupBackgroundSelector).fadeOut("slow");  
        $(backgroundSelector).fadeOut("slow");
        //$(CSE.Form.atPopupSelector).fadeOut("slow");  
        $(popupSelector).fadeOut("slow");
        status = 0;  
      } 
      return status; 
    } 
    function centrePopup(popupSelector, backgroundSelector){  
      console.log("centre popup");
    //request data for centering  
      var windowWidth = document.documentElement.clientWidth;  
      var windowHeight = document.documentElement.clientHeight;  
      var popupHeight = $(popupSelector).height();  
      var popupWidth = $(popupSelector).width();  
    //centering  
      $(popupSelector).css({  
        "position": "absolute",  
        "top": windowHeight/2-popupHeight/2,  
        "left": windowWidth/2-popupWidth/2 
      });  
      //only need force for IE6  
        
      $(backgroundSelector).css({ 
          "height": windowHeight 
      });  
      
    }
        //centering popup  
    /*function centerPopup(){  
      console.log("centre popup");
    //request data for centering  
      var windowWidth = document.documentElement.clientWidth;  
      var windowHeight = document.documentElement.clientHeight;  
      var popupHeight = $(CSE.Form.atPopupSelector).height();  
      var popupWidth = $(CSE.Form.atPopupSelector).width();  
    //centering  
      $("#at-popup").css({  
        "position": "absolute",  CSE.Form.atPopupBackgroundSelector
        "top": windowHeight/2-popupHeight/2,  
        "left": windowWidth/2-popupWidth/2  
      });  
      //only need force for IE6  
        
      $(CSE.Form.atPopupBackgroundSelector).css({  
         "height": windowHeight  
      });  
      
    } */ 
    
    //$(document).ready(function(){  
       //CLOSING POPUP  
      //Click the x event!  
      
    //}); 