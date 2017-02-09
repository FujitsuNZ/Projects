/*********************************************************************************
Name:           AccountCurrentVehiclesController
Author:          Digby Bartosh [Fujitsu]
Purpose:        It gets the Current Vehicles owned by this Account
Created Date:   02/01/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
({
	fetchOwnersAction : function(component, event, helper) {
       
		var action =component.get("c.fetchCurrentVehicles");
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