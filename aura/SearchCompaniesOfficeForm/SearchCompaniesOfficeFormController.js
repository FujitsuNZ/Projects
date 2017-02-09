({
	clickSearch: function(component, event, helper) {
    	var createEvent = component.getEvent("searchCompanyEvent");
    	createEvent.setParams({ "searchCompanyName": component.get("v.searchQuery") });
    	createEvent.fire();
}
    
})