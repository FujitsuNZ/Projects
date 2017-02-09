/*********************************************************************************
Name:          WECContractSummaryCtrl
Author:         Digby Bartosh [Fujitsu]
Purpose:        This class is used to control the search of WEC Contracts function on the server
Created Date:   22/01/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public with sharing class WECContractSummaryCtrl {

	@AuraEnabled
	public static list<wrapperClass> startSearch(String searchQuery) {
		system.debug(searchQuery);
        
		list<wrapperClass> rwc = new list<wrapperClass>();
        list<WECContractSummaryInterface.wrapperClass> iwc = new list<WECContractSummaryInterface.wrapperClass>();
        WECContractSummaryInterface job = new WECContractSummaryInterface();
        iwc = job.getCallout(searchQuery);
        system.debug(iwc);
        
        for(WECContractSummaryInterface.wrapperClass results: iwc) {
                wrapperClass wc = new wrapperClass();
                wc = copyData(results);
                rwc.add(wc);
        }
        
        system.debug(rwc);
        return rwc;
	}

    
    // ssearch WEC contracts based on vehicle record ID
	@AuraEnabled
	public static list<wrapperClass> startVSearch(String recordId) {
		system.debug(recordId);
        
        list<wrapperClass> rwc = new list<wrapperClass>();
        vehicle__c vDet = [select id,VMS_GUID__c from Vehicle__c where Id = :recordId];
        if(vDet.VMS_GUID__c != null) {

                list<WECContractSummaryInterface.wrapperClass> iwc = new list<WECContractSummaryInterface.wrapperClass>();
                WECContractSummaryInterface job = new WECContractSummaryInterface();
                iwc = job.getCallout(vDet.VMS_GUID__c);
                system.debug(iwc);
                
                for(WECContractSummaryInterface.wrapperClass results: iwc) {
                        wrapperClass wc = new wrapperClass();
                        wc = copyData(results);
                        rwc.add(wc);
                }}
        
        system.debug(rwc);
        return rwc;
	}

    
    // ssearch WEC contracts based on customer record ID
	@AuraEnabled
	public static list<wrapperClass> startCSearch(String recordId) {
		system.debug(recordId);
        
        list<wrapperClass> rwc = new list<wrapperClass>();
        list<Ownership__c> oDet = [select id,Vehicle__c from Ownership__c where Registered_Owner__c = :recordId];
        for(Ownership__c own: oDet) {
                
               vehicle__c vDet = [select id,VMS_GUID__c,Registration_Plate_Number__c from Vehicle__c where Id = :own.Vehicle__c];
     		   if(vDet.VMS_GUID__c != null) {            
            
                list<WECContractSummaryInterface.wrapperClass> iwc = new list<WECContractSummaryInterface.wrapperClass>();
                WECContractSummaryInterface job = new WECContractSummaryInterface();
                iwc = job.getCallout(vDet.VMS_GUID__c);
                system.debug(iwc);
                
                for(WECContractSummaryInterface.wrapperClass results: iwc) {
                        wrapperClass wc = new wrapperClass();
                        wc = copyData(results);
                        wc.Registration = vDet.Registration_Plate_Number__c;    
                        rwc.add(wc);
                }}
        }
        
        system.debug(rwc);
        return rwc;
	}    
    
    // copy the data to the aura wrapper class
 	public static wrapperClass copyData(WECContractSummaryInterface.wrapperClass results) {   

                    wrapperClass wc = new wrapperClass();
                    try {wc.ContractID = results.ContractID;   } catch(Exception e) {}
                    try {wc.TNZVehicleGUID = results.TNZVehicleGUID;  } catch(Exception e) {}
                    try {wc.ContractStatus = results.ContractStatus;  } catch(Exception e) {}
                    try {wc.StartDate = results.StartDate;  } catch(Exception e) {}
                    try {wc.SellingRetailAgentCode = results.SellingRetailAgentCode;  } catch(Exception e) {}
                    try {wc.ProductPrice = Decimal.valueOf(results.ProductPrice);  } catch(Exception e) {}
                    try {wc.ProductName = results.ProductName;  } catch(Exception e) {}
                    try {wc.CampaignID = results.CampaignID;  } catch(Exception e) {}
                    try {wc.CampaignName = results.CampaignName;  } catch(Exception e) {}
                    try {wc.Error = results.Error;  } catch(Exception e) {}
                    try {wc.ErrorMsg = results.ErrorMsg;  } catch(Exception e) {}            
        
        			return wc;
    }    
    
    
    
    public class wrapperClass{

        @AuraEnabled public String ContractID;
        @AuraEnabled public String TNZVehicleGUID;
        @AuraEnabled public String Registration;
        @AuraEnabled public String ContractStatus;
        @AuraEnabled public Date StartDate;
        @AuraEnabled public String SellingRetailAgentCode;
        @AuraEnabled public Decimal ProductPrice;
        @AuraEnabled public String ProductName;
        @AuraEnabled public String CampaignID;
        @AuraEnabled public String CampaignName;
        @AuraEnabled public boolean Error;
        @AuraEnabled public String ErrorMsg;
    }
  
    
}