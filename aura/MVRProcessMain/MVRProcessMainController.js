({
    
    // perform initialisation
	doInit: function(component, event, helper) {


	},
    
    // submit the MVR pre-processes
	submitPreProcess: function(component, event, helper) {
        
    		// Create the action
    		var action = component.get("c.submit");
        
    		// Add callback behavior for when response is received
    		action.setCallback(this, function(response) {
        	var state = response.getState();
        	if (component.isValid() && state === "SUCCESS") {
                alert("Pre-Processes completed successfully");
                }
        	else {
            	console.log("Failed with state: " + state);
        		}
    		});

    	// Send action off to be executed
   // 	$A.enqueueAction(action);
},
    
    // submit the MVR processes to update the CRM system
	submitCRMProcess: function(component, event, helper) {
        
    		// Create the action
    		var action = component.get("c.submit");
        
    		// Add callback behavior for when response is received
    		action.setCallback(this, function(response) {
        	var state = response.getState();
        	if (component.isValid() && state === "SUCCESS") {
                alert("CRM update processes submitted successfully");
                }
        	else {
            	console.log("Failed with state: " + state);
        		}
    		});

    	// Send action off to be executed
    	$A.enqueueAction(action);
}    
    
})