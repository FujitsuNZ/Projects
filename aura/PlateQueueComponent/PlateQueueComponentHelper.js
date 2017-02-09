/*********************************************************************************
Name:           PlateQueueComponentHelper
Author:         Himanshu Verma [Fujitsu]
Purpose:        HelperClass to Generate Plate Series queues and download csv.
Created Date:   17/01/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/

({  
    /*This method is to Generate Plate Queue Series .*/
    plateSeriesProcess: function(component,helper,matchedTextVar,startRangeVar) {
        var action = component.get("c.doInsertPlateSeries");
        action.setParams({startChar:matchedTextVar,numberOfRecords:startRangeVar});
        action.setCallback(this, function(response){
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                if ($A.util.isEmpty(result.exceptionMessage)){
                     toastEvent.setParams({"title": "Success!","message":"Series has been created.",
                                           "type":"success","duration":"5000"});
                     toastEvent.fire();
                     helper.downloadToCsv(result.plateQueueRecords);
                }else{
                     toastEvent.setParams({"title": "Error!","message":result.exceptionMessage,
                                           "type":"error","duration":"10000"});
                     toastEvent.fire();
                }
                        
            }else{
                  alert("Error in Server Side.");
            }
        }); 
        $A.enqueueAction(action);
    },
    
    /*This method is to check the special character*/
    docheckSpecialCharacters :function(component,componentId){
         var comp = component.find(componentId);
         var compValue = comp.get("v.value");
         var spclChars = "!@#$%^&*()";
         var errorFound =false;
         for (var i = 0; i <compValue.length; i++){ 
            if (spclChars.indexOf(compValue.charAt(i)) !== -1){ 
                comp.set("v.errors", [{message:"Special Characters Not allowed."}]);
                errorFound=true;
                break;
            }else{
                comp.set("v.errors", null);
            }  
        }
        return errorFound;
     },
    
    /*Method to check specialCharaters and Digits in value*/
    docheckspecialCharactersandDigits: function(component,componentId){
        var errorFound =false;
        var comp = component.find(componentId);
        var compValue = comp.get("v.value");
        var compFirstThreeChar =compValue.substr(0,3);
        var re = /^[A-Za-z]+$/;
        if(!re.test(compFirstThreeChar)){
             comp.set("v.errors", [{message:"Only Letters are allowed in First three Characters."}]);
             errorFound=true;
             //alert('digits found');
        }
        else{
            comp.set("v.errors", null);
        }
        return errorFound;
    },
    
    /*Method to check Digits in value*/
    docheckDigits: function(component,componentId){
        var errorFound =false;
        var comp = component.find(componentId);
        var compValue = comp.get("v.value");
        var lastThreeChar =compValue.substr(3,6);
        var re = /^[0-9]+$/;
        if(!re.test(lastThreeChar)){
            comp.set("v.errors", [{message:"Only digits are allowed in Last three charaters."}]);
            errorFound=true;
        }
        else{
            comp.set("v.errors", null);
        }
        return errorFound;
    },
    
    
    docheckTotal :function(component,componentId){
        var errorFound =false;
        var comp = component.find(componentId);
        var compValue = comp.get("v.value");
        var lastThreeChar =compValue.substr(3,6);
        lastThreeChar = parseInt(lastThreeChar);
        var numberOfRecords = component.get("v.numberOfRecords");
        var totalSeriesLength =lastThreeChar+numberOfRecords;
        if (totalSeriesLength>=1000){
            comp.set("v.errors", [{message:"Sum of start series and number of records should be less than 1000."}]);
            errorFound= true;
        }
        return errorFound;
    },
    
     /*This method will create the csv and file will be downloaded automatically  */
    downloadToCsv : function(recordsToExport){       
        var recordsToDownload =recordsToExport;
        console.log('#####'+recordsToDownload);
        var csvHeader=[];
        var finalStringTocombine =[];
        /*
        csvHeader.push('Id');
        csvHeader.push('Plate Number');
        csvHeader.push('Date Sent');
        csvHeader.push('Date Received');
        csvHeader.push('STATUS');
        csvHeader.push('Send to NZTA'); 
        */
        csvHeader.push('Plate Number');
        csvHeader.push('VIN');
        
        var headerstring=csvHeader.join(',');
        finalStringTocombine.push(headerstring);
        
        for(var i=0;i<recordsToExport.length;i++){
            var record =[];
            /*
            record.push(recordsToExport[i].Id);
            record.push(recordsToExport[i].Date_Sent__c);
            record.push(recordsToExport[i].Date_Received__c);
            record.push(recordsToExport[i].Status__c);
            record.push(recordsToExport[i].Send_to_NZTA__c);
            */
            record.push(recordsToExport[i].Plate_Number__c);
            record.push(recordsToExport[i].VIN__c);
            
            var finalString = record.join(',');
            finalStringTocombine.push(finalString);
            
        }
        
        var csvfinalcomment=finalStringTocombine.join('\n');
        var uri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvfinalcomment);
        var fileName = 'PlateQueue.csv';
        var link = document.createElement("a");
        link.setAttribute('download',fileName);
        link.href = uri;
        link.style = "visibility:hidden";
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
})