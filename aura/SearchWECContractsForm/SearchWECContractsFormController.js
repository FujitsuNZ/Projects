({
	clickSearch: function(component, event, helper) {
    	var createEvent = component.getEvent("searchWECContractEvent");
    	createEvent.setParams({ "searchWECContractsEvent": component.get("v.searchQuery") });
    	createEvent.fire();
}
    
})