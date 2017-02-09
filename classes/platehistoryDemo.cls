public class platehistoryDemo{

   @AuraEnabled
   
   public static list<Plate_History__c> getPlateHistories(string vehicalId){
   
          list<Plate_History__c> platehistory=[select id,createddate,name,Plate__c,
                                               Plate_Type__c,Registration_Plate__c,Vehicle__c
                                               from Plate_History__c where Vehicle__c=:vehicalId];
                                               
          return  platehistory;
   }




}