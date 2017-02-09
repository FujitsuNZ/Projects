/*********************************************************************************
Name:           AccountActivityTrigger
Author:          DIgby Bartosh [Fujitsu]
Purpose:        This trigger is used to track field changes on Account.
Created Date:   24/10/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
trigger AccountActivityTrigger on Account (before insert, before Update) {

    AccountActivityLog.recordFieldChanges(Trigger.oldMap, Trigger.newMap, trigger.isInsert, trigger.isUpdate);

}