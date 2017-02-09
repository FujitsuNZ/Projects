/*********************************************************************************
Name:           VMSVehicleRecallListController
Author:         Digby Bartosh [Fujitsu]
Purpose:        Get the Recalls from WEC
Created Date:   02/02/2017

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
    
    setup : function(component, event, helper) {
       console.log("got here");
        
		$("myTable").colResizable({liveDrag:true});
        
	},
    
    
    // perform sorting of columns
    sortByRego: function(component, event, helper) {
        helper.sortBy(component, "Registration");
    }, 
    sortByCampaign: function(component, event, helper) {
        helper.sortBy(component, "campaigndescription");
    },
    sortByStatus: function(component, event, helper) {
        helper.sortBy(component, "campaignstatus");
    },    
    sortByBulletin: function(component, event, helper) {
        helper.sortBy(component, "bulletingreference");
    },  
     sortByDate: function(component, event, helper) {
        helper.sortBy(component, "campaignstartdate");
    },  
    sortByCause: function(component, event, helper) {
        helper.sortBy(component, "cause");
    },  
    sortByCondition: function(component, event, helper) {
        helper.sortBy(component, "condition");
    },
        sortByRemedy: function(component, event, helper) {
        helper.sortBy(component, "remedy");
    }   

    
})