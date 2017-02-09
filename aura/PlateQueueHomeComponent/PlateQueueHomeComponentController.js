/*********************************************************************************
Name:           PlateQueueHomeComponentController
Author:         Himanshu Verma [Fujitsu]
Purpose:        HomeComponent with Navigation functionality to PlateQueueComponent
                and the View Batches
Created Date:   21/01/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/



({
	navigatetoSeriesComponent : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:PlateQueueComponent",
            componentAttributes: {}
        });
        evt.fire();
          
	},
    
    
    navigatetoViewSentBatch : function(component,event,helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:PlateQueueSentBatches",
            componentAttributes: {}
        });
        evt.fire();
   }
})