/*********************************************************************************
Name:           AnnualSurveyTrigger
Author:         Fujitsu
Purpose:        This trigger is used to track field changes on Vehicle Data.
Created Date:   20/09/2016

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/

trigger VehicleTrigger on Vehicle__c (before Update) {
    
    if (Trigger.isBefore){
        if (Trigger.isUpdate){
            TriggerHelper.trackDataChanges(Trigger.oldMap, Trigger.newMap);
        }
    }

}