/*********************************************************************************
Name:           VehicalPreviousOwnerShipController
Author:         Himanshu Verma [Fujitsu]
Purpose:        It Updates the OwnerShip History in the Component on the basis of RecordId 
Created Date:   29/12/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
({
	fetchOwnersAction : function(component, event, helper) {
       
		var action =component.get("c.fetchPreviousOwners");
        action.setParams({recordId:component.get("v.recordId")});
        action.setCallback( this, function(response) {
            var state = response.getState();
            
             if (state === "SUCCESS") {
                 var result = response.getReturnValue();
                 if(!$A.util.isEmpty(result) && !$A.util.isUndefined(result)){
                    component.set("v.sobjectList",result);
                 }
                 else{
                      var message = component.find("idMessage");
                      $A.util.addClass(message, 'slds-show');
                 }
            }
            else{ alert('Error in Server Side action');}
        });
        $A.enqueueAction(action);
     
	}
})