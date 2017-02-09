/*********************************************************************************
Name:           PlateQueueComponentHelper
Author:         Himanshu Verma [Fujitsu]
Purpose:        Class to Generate the plateSeries and export to csv automatically.
Created Date:   17/01/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/

({
    /**Method to Validate the Plate Queue Series form**/
    doValidatePlateSeries :function(component,event,helper){ 
         var errorFound= false;
         var startRangeText =component.find("idStartText");
         var startRangeTextValue = startRangeText.get("v.value");
         var numberOfRecords =component.find("idNumberRecords");
         var numberOfRecordsValue = numberOfRecords.get("v.value");
         startRangeText.set("v.errors", null);
         numberOfRecords.set("v.errors", null);
         
         if(!$A.util.isEmpty(startRangeTextValue)){
              startRangeTextValue =startRangeTextValue.replace(/\s/g,'');//To remove all the spaces. 
         }                                                   
         if($A.util.isEmpty(startRangeTextValue)){
              startRangeText.set("v.errors", [{message:"Value is required."}]);
              errorFound=true;  
         }else if(startRangeTextValue.length !== 6){
                  startRangeText.set("v.errors", [{message:"Please Enter 6 Characters."}]);
                  errorFound=true;  
         }
         else{
              errorFound= helper.docheckspecialCharactersandDigits(component,'idStartText');
              
              if (errorFound ===false){
                  errorFound= helper.docheckDigits(component,'idStartText');
              }
         }
        
        if (errorFound === false) {
             if($A.util.isEmpty(numberOfRecordsValue)){
                  numberOfRecords.set("v.errors", [{message:"Value is required."}]);
                  errorFound=true;  
             }
             else if(numberOfRecordsValue === 0){
                      numberOfRecords.set("v.errors", [{message:"Value can not be zero."}]);
                      errorFound=true;  
             }
             else if(numberOfRecordsValue >= 1000){
                      numberOfRecords.set("v.errors", [{message:"Value must be less than 1000"}]);
                      errorFound=true;  
             }
             else{
                   errorFound= helper.docheckTotal(component,'idStartText');
             }
        }
        if(errorFound===false){
            helper.plateSeriesProcess(component,helper,startRangeTextValue,numberOfRecordsValue);
        }
    }
       
})