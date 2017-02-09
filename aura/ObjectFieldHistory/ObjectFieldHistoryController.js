/*********************************************************************************
Name:           ObjectFieldHistoryController
Author:         Himanshu Verma [Fujitsu]
Purpose:        It Updates the Field History details in the Component on the basis of the Object Name and Record Id
Created Date:   28/12/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
({
	fetchHistory : function(component, event, helper) {
		
        var fetchHistoryaction =component.get("c.fetchFieldHistory");
       
        fetchHistoryaction.setParams({objId:component.get("v.recordId"),objectName:component.get("v.sObjectName")});
        fetchHistoryaction.setCallback( this, function(response) {
            var state = response.getState();
             
             if (state === "SUCCESS") {
                 var result = response.getReturnValue();
                 if(!$A.util.isEmpty(result) && !$A.util.isUndefined(result)){
                   component.set("v.sobjectHistoryList", response.getReturnValue());
                 }
                 else{
                     var message = component.find("idMessage");
                     $A.util.addClass(message, 'slds-show');
                 }
            }
            else{
                alert('Error in Server Side Controller')
            }
            console.log('###'+ response.getReturnValue());
            
        });
        $A.enqueueAction(fetchHistoryaction);
      
	}
})