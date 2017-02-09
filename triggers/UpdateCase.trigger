trigger UpdateCase on Case (before insert) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            for (Case c : Trigger.new) {
                /*
                c.AccountId = '0012800000qkdKm';
                c.ContactId = '0032800000ZtbHx';
                c.Vehicle__c = 'a012800000eBDEY';
                */
            }
        }
    }
}