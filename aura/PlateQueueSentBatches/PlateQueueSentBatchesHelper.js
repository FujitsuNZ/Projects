/*********************************************************************************
Name:           PlateQueueSentBatchesHelper
Author:         Himanshu Verma [Fujitsu]
Purpose:        Class to Load the PlateQueueSentBatches  and to Generate the csv
Created Date:   23/01/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
({
	/*This method will populate the sentBatches records in component*/
     loadBathces : function(component,next,prev,offset) {
        var action = component.get("c.getPlateQueueBathces");
        action.setParams({"next":next,"prev":prev,"off":offset}); 
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.queueBatches",result.plateQueueBatchList);
                component.set("v.offset",result.offst);
                component.set("v.next",result.hasnext);
                component.set("v.prev",result.hasprev);
            }else{
                console.log("Failed with state: " + state);
            }
        }); 
        $A.enqueueAction(action);
     },
    
    /**Method to check the Child PlateQueueRecords and then process it for the CSV Downloading*/
    exportToCSV : function(recordId,component,helper){
        var action =component.get("c.getPlateQueueData");
        action.setParams({"plateQueueBatchId":recordId}); 
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (!$A.util.isEmpty(result)){
                     helper.downloadToCsv(result);
                }else{
                     var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({"title": "Success!","message":"No Records Found to export",
                                         "type":"error"});
                     toastEvent.fire();
                }
               
            }else{
                console.log("Failed with state: " + state);
            }
        }); 
        $A.enqueueAction(action);
    },
    
    /*This method will create the csv and file will be downloaded automatically  */
    downloadToCsv : function(recordsToExport){       
        var recordsToDownload =recordsToExport;
        console.log('#####'+recordsToDownload);
        var csvHeader=[];
        var finalStringTocombine =[]; 
        /*
        csvHeader.push('Name');
        csvHeader.push('Id');
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
            record.push(recordsToExport[i].Name);
            record.push(recordsToExport[i].Id);
            record.push(recordsToExport[i].Date_Sent__c);
            record.push(recordsToExport[i].Date_Received__c);
            record.push(recordsToExport[i].Status__c);
            record.push(recordsToExport[i].VIN__c);
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