/*********************************************************************************
Name:           WECContractSummaryListController
Author:         Digby Bartosh [Fujitsu]
Purpose:        Get the contacts for an Account
Created Date:   02/02/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
({
	fetchOwnersAction : function(component, event, helper) {
       
		var action =component.get("c.startVSearch");
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
            else{ 
                var errors = response.getError();                     
                if (errors) {
                    if (errors[0] && errors[0].message) {
            				console.log(errors[0].message);    
                    }
                }
                alert('Error in Server Side action');}
        });
        $A.enqueueAction(action);
     
	},
    
    // perform sorting of columns
    sortByContract: function(component, event, helper) {
        helper.sortBy(component, "ContractID");
    },
    sortByStatus: function(component, event, helper) {
        helper.sortBy(component, "ContractStatus");
    },    
    sortByAgent: function(component, event, helper) {
        helper.sortBy(component, "SellingRetailAgentCode");
    },  
     sortByDate: function(component, event, helper) {
        helper.sortBy(component, "StartDate");
    },  
    sortByPrice: function(component, event, helper) {
        helper.sortBy(component, "ProductPrice");
    },  
    sortByProduct: function(component, event, helper) {
        helper.sortBy(component, "ProductName");
    },
        sortByCampaign: function(component, event, helper) {
        helper.sortBy(component, "CampaignName");
    }       

    
})