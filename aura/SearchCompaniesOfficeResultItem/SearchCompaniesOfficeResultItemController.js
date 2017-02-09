// update the account details with data from companies office.

({
	updateCRM : function(component, event, helper) {
		
        	var cdata = JSON.stringify(component.get("v.searchResult"));
        	var acc = component.get("v.accID");
        
    		// Create the action
    		var action = component.get("c.updAccount");
        	action.setParams({
                "cData": cdata,
                "accID": acc
            });

    		// Add callback behavior for when response is received
    		action.setCallback(this, function(response) {
        	var state = response.getState();
        	if (component.isValid() && state === "SUCCESS") {
                console.log(response.getReturnValue());
                $A.get('e.force:refreshView').fire();
                }
        	else {
            	console.log("Failed with: " + response.getError());
        		}
    		});

    	// Send action off to be executed
    	$A.enqueueAction(action);
}

})