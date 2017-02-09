/*********************************************************************************
Name:           AccountActivityLog
Author:         Digby Bartosh [Fujitsu]
Purpose:        This class is used to track field history on the Account Records.
Created Date:   24/10/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public class AccountActivityLog {
   
        public static void recordFieldChanges(Map<ID,SObject> oldRecordMap, Map<ID,SObject> newRecordMap, Boolean rcdInsert, Boolean rcdUpdate){
        system.debug(newRecordMap);
        string[] objectName = new string[]{string.valueOf(oldRecordMap.getSObjectType())};
        List<ActivityLog__c> fieldChanges = new List<ActivityLog__c>();
         
        for(ID recordID:newRecordMap.keySet()){
            SObject myNewRecord = newRecordMap.get(recordID);
            SObject myOldRecord = oldRecordMap.get(recordID);
            ActivityLog__c  afh = new ActivityLog__c ();

            if (rcdInsert) afh.Name = 'Account Created';
            if (rcdUpdate) afh.Name = 'Account Updated';
            if(myNewRecord.get('Name') != myOldRecord.get('Name')) afh.Account_Name__c = String.valueOf(myNewRecord.get('Name'));
            if(myNewRecord.get('Type') != myOldRecord.get('Type')) afh.Account_Type__c = String.valueOf(myNewRecord.get('Type'));
            if(myNewRecord.get('Phone') != myOldRecord.get('Phone')) afh.Account_Phone__c = String.valueOf(myNewRecord.get('Phone'));
            if(myNewRecord.get('Industry') != myOldRecord.get('Industry')) afh.Account_Industry__c = String.valueOf(myNewRecord.get('Industry'));
            if(myNewRecord.get('BillingAddress') != myOldRecord.get('BillingAddress')) afh.Account_Address__c = String.valueOf(myNewRecord.get('BillingAddress'));
            afh.History_Object__c='Account';
            afh.Account__c = recordID;
            afh.Modified_Date__c = Datetime.now();
			afh.Modified_By__c = UserInfo.getUserId();
 			fieldChanges.add(afh);
        }
       insert fieldChanges;
 
    }

}