/*********************************************************************************
Name:          MVRProcessBatchSubmit
Author:         Digby Bartosh [Fujitsu]
Purpose:        This class is used to submit the Job to process the MVR table
Created Date:   29/11/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public class MVRProcessBatchSubmit {

        // this method is called from somewhere (TBD)
    @AuraEnabled	
    public static void submit(){ 
      
      		// this process sets up the query and submits the batch apex process
        	MVRProcessBatchJob mvrdata = new MVRProcessBatchJob();
        	mvrdata.query = 'SELECT Id,Name,Load_Process_Date__c,Load_Process_Message__c,Registered_Person_Name__c,Gone_No_Address__c,Date_Query_Processed__c,Trading_As_Representing__c,' +
                'Date_of_Birth_Of_Registered_Person__c,Joint_Owner_Indicator__c,Record_Type__c,Message_Code_1__c,Message_Code_2__c,Message_Code_3__c,' +
                'Ticket_Number__c,Query_Date_For_Owner_As_AT__c,Physical_Address_Property_Name__c,Physical_Address_Flat_Floor_Number__c,Physical_Address_Street_Number__c,' +                
                'Physical_Address_Street_Name__c,Physical_Address_RD_Number__c,Physical_Address_Suburb__c,Physical_Address_Town__c,Physical_Address_Postcode__c,' +     
                'Mailing_Address_Property_Name__c,Mailing_Address_Flat_Floor_Name__c,Mailing_Address_Street_Number__c,Mailing_Address_Street_Name__c,Mailing_Address_Box_Bag_RD__c,' +   
                'Mailing_Address_Box_Bag_Number__c,Mailing_Address_RD_Number__c,Mailing_Address_Suburb__c,Mailing_Address_Town__c,Mailing_Address_Postcode__c,' +   
                'Sex_Company__c,Joint_Owner_Name_No_1__c,Joint_Owner_Name_No_2__c,Joint_Owner_Name_No_3__c,Acquisition_Date__c,Ownership_Status__c,Fleet_Lease_Owner__c,' +   
                'Fleet_Lease_Ownership__c,Registration_Status__c,Licence_Expiry_Date__c,Plate_No__c,Replacement_Plate__c,Date_Of_Issue_For_Latest_Licence__c,' +                   
                'Body_Style__c,Chassis_No__c,Date_Of_First_Registration_In_NZ__c,Engine_No__c,CC_Rating__c,Fuel_Type__c,Submodel__c,No_Of_Seats__c,Latest_Odometer_Reading__c,' +    
                'Date_Of_Odometer_Reading__c,Main_Colour__c,Make__c,Model__c,VIN__c,Expiry_Date_Of_Last_Successful_WOF__c,Year_Of_Manufacture__c,Plate_Type__c,Cause_Of_Latest_Registration__c,' +
                'Vehicle_Type__c,Time_Of_Issue_For_Latest_Licence__c ' +
                'FROM MVR__c WHERE (Load_Process_Date__c=null)';
        	ID batchprocessid = Database.executeBatch(mvrdata,20);
        
    }
    
}