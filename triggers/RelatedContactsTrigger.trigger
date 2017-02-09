/*********************************************************************************
Name:           RelatedContactsTrigger
Author:         Fujitsu
Purpose:        This trigger is used to setup relationships between contacts
Created Date:   15/12/2016

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
trigger RelatedContactsTrigger on Related_Contact__c (after insert, after delete) {
        
    
    if (Trigger.isInsert){
            TriggerHelper.insertRel(Trigger.new);
        }

    if (Trigger.isDelete){
            TriggerHelper.deleteRel(Trigger.old);
        }

}