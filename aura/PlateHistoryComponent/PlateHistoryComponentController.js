({
	updateplatehistory : function(component, event, helper) {
		
        var action =component.get("c.getPlateHistories");
        var message = component.find("idMessage");
        action.setParams({"vehicalId":component.get("v.vehicalId")});
        action.setCallback( this, function(response) {
            var state = response.getState();
            
             if (state === "SUCCESS") {
                 component.set("v.vplatehistories", response.getReturnValue());
            }
            
            if(component.get("v.vplatehistories").length===0){
                $A.util.addClass(message, 'slds-show');
            }
            
        });
        $A.enqueueAction(action);
        
	}
})