/*********************************************************************************
Name:           PlateQueueSentBatchesController
Author:         Himanshu Verma [Fujitsu]
Purpose:        Class to Load the PlateQueueSentBatches  and to Generate the csv
Created Date:   23/01/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/


({
	doInit : function(component, event, helper) {
        var next = false;
        var prev = false;
        var offset =0; 
        helper.loadBathces(component,next,prev,offset);
	},
    
    next :function(component,event,helper){
        var next = true;
        var prev = false;
        var offset = component.get("v.offset");
        helper.loadBathces(component,next,prev,offset);
    },
    
    previous:function(component,event,helper){
        var next = false;
        var prev = true;
        var offset = component.get("v.offset");
        helper.loadBathces(component,next,prev,offset);
    },
    
    processCsv:function(component,event,helper){
        var recordToProcess=event.target.id;
        helper.exportToCSV(recordToProcess,component,helper);
    } 
    
    
     
})