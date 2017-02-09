/*********************************************************************************
Name:          PlateVehiclehistoryController
Author:         Digby Bartosh [Fujitsu]
Purpose:        get any previous vehicles that have used this plate
Created Date:   02/01/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
({
	fetchPlateHistoryAction : function(component, event, helper) {
       
		var action =component.get("c.fetchPlateVehicleHistory");
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