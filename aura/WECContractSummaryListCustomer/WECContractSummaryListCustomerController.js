/*********************************************************************************
Name:           WECContractSummaryListCustomer
Author:         Digby Bartosh [Fujitsu]
Purpose:        Get the contracts from WEC for the customer
Created Date:   04/02/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
({
	fetchOwnersAction : function(component, event, helper) {
       
		var action =component.get("c.startCSearch");
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
    sortByRego: function(component, event, helper) {
        helper.sortBy(component, "Registration");
    },
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