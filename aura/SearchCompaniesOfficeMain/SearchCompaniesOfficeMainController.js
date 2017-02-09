({
    
    // perform initialisation
	doInit: function(component, event, helper) {


	},
    
    // Perform search on the server
	handleSearch: function(component, event, helper) {

            var newSearch = event.getParam("searchCompanyName");
        
    		// Create the action
    		var action = component.get("c.startSearch");
    		action.setParams({"searchQuery": newSearch});
        
    		// Add callback behavior for when response is received
    		action.setCallback(this, function(response) {
        	var state = response.getState();
        	if (component.isValid() && state === "SUCCESS") {
            	component.set("v.searchResults", response.getReturnValue());
                console.log(response.getReturnValue());
                }
        	else {
            	console.log("Failed with state: " + state);
        		}
    		});

    	// Send action off to be executed
    	$A.enqueueAction(action);
}
    
    
})