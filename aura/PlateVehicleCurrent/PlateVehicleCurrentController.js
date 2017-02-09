/*********************************************************************************
Name:          PlateVehicleCurrentController
Author:         Digby Bartosh [Fujitsu]
Purpose:        get any previous vehicles that have used this plate
Created Date:   18/01/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
({
	fetchPlateCurrentAction : function(component, event, helper) {
       
		var action =component.get("c.fetchPlateVehicleCurrent");
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