({
	clickSearch: function(component, event, helper) {
    	var createEvent = component.getEvent("searchItem");
    	createEvent.setParams({ "searchItem": component.get("v.searchQuery") });
    	createEvent.fire();
}
    
})