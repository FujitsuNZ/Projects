({
	clickSearch: function(component, event, helper) {
    	var createEvent = component.getEvent("searchWECClaimEvent");
    	createEvent.setParams({ "searchWECClaimsEvent": component.get("v.searchQuery") });
    	createEvent.fire();
}
    
})