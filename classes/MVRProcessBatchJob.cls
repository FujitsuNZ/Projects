/*********************************************************************************
Name:           MVRProcessBatchJob
Author:         Digby Bartosh [Fujitsu]
Purpose:        This class is used to process the MVR table from NZTA, and add the details to the Toyota relational tables
Created Date:   29/11/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
global class MVRProcessBatchJob implements Database.Batchable<sObject>{

    public String query;
    public list<Vehicle__c> updVehicles = new list<vehicle__c>();
    public list<Plate__c> updPlates  = new list<Plate__c>();
    public list<Ownership__c> updOwnership  = new list<Ownership__c>();
    public list<Plate_History__c> updPlateH  = new list<Plate_History__c>();
    public list<Ownership_History__c> updOwnershipH  = new list<Ownership_History__c>();
    public list<Account> updAccounts  = new list<Account>();
    public list<Contact> updContacts  = new list<Contact>();    
    public list<MVR__c> updMVR  = new list<MVR__c>();    
    public string message = '';
    
    public RecordType company = [select id from RecordType where name = 'Company' and SobjectType = 'Account' limit 1];
    public RecordType individual = [select id from RecordType where name = 'Private Individual' and SobjectType = 'Account' limit 1];    
    
    // this method executes the query and returns just the unprocessed MVR records
    global Database.querylocator start(Database.BatchableContext BC){
        system.debug(query);
        return Database.getQueryLocator(query);}

    // this method is the control method, and executes each of the individual process methods ========================================================================
    global void execute(Database.BatchableContext BC, List<sObject> scope){

        // process the records according to the mapping rules   
        for(sObject s : scope){MVR__c mvdata = (MVR__c)s;   
                               
                  message='';

                  // check if there are any error messages for the record
                  string severity1 ='Ok'; string severity2='Ok'; string severity3='Ok'; mvdata.error_message_severity__c = 'Ok';    
                  if(mvdata.Message_Code_1__c != 0 || mvdata.Message_Code_2__c != 0 && mvdata.Message_Code_3__c != 0) { 
				  			severity1 = nztaErrorSeverity(mvdata.Message_Code_1__c);                                 
                      		if(mvdata.message_Code_2__c != 0) {severity2 = nztaErrorSeverity(mvdata.Message_Code_2__c); }
                      		if(mvdata.message_Code_2__c != 0) {severity3 = nztaErrorSeverity(mvdata.Message_Code_3__c); }                      
                  } 
                  
                  //  if severity is Reassign then stick it on the re-process queue and do not proceed.             
                  if(severity1 =='Unassigned' || severity2 =='Unassigned' || severity3 =='Unassigned') {            
				  			message = '[Unassigned] NZTA - ' + nztaErrorMessage(mvdata.Message_Code_1__c) + '\n';                                 
                      		if(mvdata.message_Code_2__c != 0) {message += '[Unassigned] NZTA - ' + nztaErrorMessage(mvdata.Message_Code_2__c) + '\n'; }
                      		if(mvdata.message_Code_2__c != 0) {message += '[Unassigned] NZTA - ' + nztaErrorMessage(mvdata.Message_Code_3__c) + '\n'; }
                      		mvdata.error_message_severity__c = 'Unassigned';
                  } else {
                  
                  //  if severity is error then do not proceed.             
                  if(severity1 =='Error' || severity2 =='Error' || severity3 =='Error') {            
				  			message = '[Error] NZTA - ' + nztaErrorMessage(mvdata.Message_Code_1__c) + '\n';                                 
                      		if(mvdata.message_Code_2__c != 0) {message += '[Error] NZTA - ' + nztaErrorMessage(mvdata.Message_Code_2__c) + '\n'; }
                      		if(mvdata.message_Code_2__c != 0) {message += '[Error] NZTA - ' + nztaErrorMessage(mvdata.Message_Code_3__c) + '\n'; }
                      		mvdata.error_message_severity__c = 'Error';                      
                  } else {
                      
                      // if error severity is ok or caution, then contiune,
                      if(severity1 =='Caution' || severity2 =='Caution' || severity3 =='Caution') {  
				  			message = '[Caution] NZTA - ' + nztaErrorMessage(mvdata.Message_Code_1__c) + '\n';                                 
                      		if(mvdata.message_Code_2__c != 0) {message += '[Caution] NZTA - ' + nztaErrorMessage(mvdata.Message_Code_2__c) + '\n'; }
                      		if(mvdata.message_Code_2__c != 0) {message += '[Caution] NZTA - ' + nztaErrorMessage(mvdata.Message_Code_3__c) + '\n'; }
                      		mvdata.error_message_severity__c = 'Caution';                          
                  		} 
                      
                  // check whether it is a vehicle Toyota wish to store
                  if(mvdata.vehicle_type__c != 7 && mvdata.vehicle_type__c != 8 && mvdata.vehicle_type__c != 9 && mvdata.vehicle_type__c != 10) { 
                      	   string vehicle = vehicleType(mvdata.Vehicle_Type__c); 
                           message = '[Caution] Vehicle Discarded - Vehicle Type is ' + vehicle + ' not stored in CRM database';  
                      	   mvdata.error_message_severity__c = 'Caution';   
                  } else {             
                      
                  // check whether there is either a VIN number or a Plate number    
                  if(mvdata.VIN__c != Null || mvdata.Plate_No__c != null) {
                      
                        list<Vehicle__c> listVehicle = new list<Vehicle__c>();
                      
                        if(mvdata.VIN__c != Null) {     
                  				listVehicle = [select id,name,Body_style__c,Chassis_Number__c,Date_First_Registered_in_NZ__c,Engine_Number__c,Fuel_Type__c,Last_Touch_Point_From__c,
                              				Model_Variant_Group_Name__c,Registration_Active_Plate__c,Registration_Plate_Number__c,Engine_Size__c,Odometer_Readings__c,Number_of_Seats__c,
                              				Vehicle_Colours__c,Vehicle_Make__c,Vehicle_Model__c,VIN__c,WOF_Expiry_Date__c,Year_Made__c,Last_Touch_Point_Date__c,Odometer_Reading_Date__c                  
                                            from Vehicle__c where (VIN__c = :mvdata.VIN__c)];
                        } else {
                  				listVehicle = [select id,name,Body_style__c,Chassis_Number__c,Date_First_Registered_in_NZ__c,Engine_Number__c,Fuel_Type__c,Last_Touch_Point_From__c,
                              				Model_Variant_Group_Name__c,Registration_Active_Plate__c,Registration_Plate_Number__c,Engine_Size__c,Odometer_Readings__c,Number_of_Seats__c,
                              				Vehicle_Colours__c,Vehicle_Make__c,Vehicle_Model__c,VIN__c,WOF_Expiry_Date__c,Year_Made__c,Last_Touch_Point_Date__c,Odometer_Reading_Date__c                  
                                            from Vehicle__c where (Registration_Plate_Number__c = :mvdata.Plate_No__c)];                            
                        }
                      
                        // if no vehicle record found then assume its a new vehicle
                        if(listVehicle.isEmpty()) {
                  	 		newVehicle(mvdata);        
                  		} else {
                      		existingVehicle(mvdata, listVehicle[0]);
                  		}

                  } else {
                      message = '[Error] no VIN or Plate number';
                      mvdata.error_message_severity__c = 'Error';    
                  }}}}                           
                        
                      mvdata.Load_Process_Message__c=message;
                      updMVR.add(mvdata);                                                       
        }
        
        update updVehicles;
        update updPlates;        
        upsert updPlateH;             
        update updOwnership;   
        upsert updOwnershipH;
        upsert updMVR;

        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
       
    }

    // -------------------------------------------------------------------------------------------------------- VEHICLE AND PLATE METHODS ----------------------------------------------------------------------------------------------------    
 	// Existing Vehicle - check the current details with MVR details and update
    public  void existingVehicle(MVR__c mvdata, vehicle__c currentV) {
        
		// convert DDMMCCYY to a datetime variable - assumes 11pm for overnight batch
		Date qDate = conDate(mvdata.Date_Of_Issue_For_Latest_Licence__c); 
        integer hours = integer.valueOf(mvdata.Time_Of_Issue_For_Latest_Licence__c)/100;  integer mins = integer.valueOf(mvdata.Time_Of_Issue_For_Latest_Licence__c) - (hours * 100); 
		Time qTime = Time.newInstance(hours,mins,00,00);
		Datetime qDT = datetime.newinstance(qDate,qTime); 

        vehicle__c updateV = new vehicle__c();
        if (qDT > currentV.Last_Touch_Point_Date__c) {
	
            updateV.Id=currentV.Id;
            
            // Core details - check and if different set a message that its been updated.
            if(mvdata.Chassis_No__c != null && currentV.Chassis_Number__c != mvdata.Chassis_No__c ) 	{
                	updateV.Chassis_Number__c=mvdata.Chassis_No__c; message += '[Caution] Chassis Number updated from ' + currentV.Chassis_Number__c + '\n'; mvdata.error_message_severity__c = 'Caution'; }   
            if(mvdata.Date_Of_First_Registration_In_NZ__c != null && currentV.Date_First_Registered_in_NZ__c != conDate(mvdata.Date_Of_First_Registration_In_NZ__c))  {
                	updateV.Date_First_Registered_in_NZ__c=conDate(mvdata.Date_Of_First_Registration_In_NZ__c); message += '[Caution] Date of First NZ Registration updated from ' + currentV.Date_First_Registered_in_NZ__c + '\n'; mvdata.error_message_severity__c = 'Caution'; }   
            if(mvdata.VIN__c != null && currentV.VIN__c != mvdata.VIN__c) 		{		
            		updateV.VIN__c=mvdata.VIN__c; message += '[Caution] VIN updated from ' + currentV.VIN__c + '\n'; mvdata.error_message_severity__c = 'Caution';}   
            if(mvdata.Year_Of_Manufacture__c != null && currentV.Year_Made__c != string.valueOf(integer.valueOf(mvdata.Year_Of_Manufacture__c))) 	{
                	updateV.Year_Made__c=string.valueOf(integer.valueOf(mvdata.Year_Of_Manufacture__c)); message += '[Caution] Year of Manufacture updated from ' + currentV.Year_Made__c + '\n'; mvdata.error_message_severity__c = 'Caution'; }   
            if(mvdata.Make__c != null && currentV.Vehicle_Make__c != mvdata.Make__c) 	{
                	updateV.Vehicle_Make__c=mvdata.Make__c; message += '[Caution] Make updated from ' + currentV.Vehicle_Make__c + '\n'; mvdata.error_message_severity__c = 'Caution';}   
            if(mvdata.Model__c != null && currentV.Vehicle_Model__c != mvdata.Model__c) {
                	updateV.Vehicle_Model__c=mvdata.Model__c; message += '[Caution] Model updated from ' + currentV.Vehicle_Model__c + '\n'; mvdata.error_message_severity__c = 'Caution';}   
            if(mvdata.Submodel__c != null && currentV.Model_Variant_Group_Name__c != mvdata.Submodel__c) 	{
                	updateV.Model_Variant_Group_Name__c=mvdata.Submodel__c;  message += '[Caution] Model Variant Group Name updated from ' + currentV.Model_Variant_Group_Name__c + '\n'; mvdata.error_message_severity__c = 'Caution'; }   

            // Dynamic details
            if(mvdata.Date_Of_Odometer_Reading__c != null) {
                if(conDate(mvdata.Date_Of_Odometer_Reading__c) > currentV.Odometer_Reading_Date__c) {
                        if(mvdata.Latest_Odometer_Reading__c != null) 	{updateV.Odometer_Readings__c=string.valueOf(integer.valueOf(mvdata.Latest_Odometer_Reading__c)); }   
                        updateV.Odometer_Reading_Date__c = conDate(mvdata.Date_Of_Odometer_Reading__c);                  
                }
            }
            if(mvdata.Cause_Of_Latest_Registration__c == 'N') 	{updateV.Status__c='New'; }  
            if(mvdata.Cause_Of_Latest_Registration__c == 'U') 	{updateV.Status__c='Used'; }
            if(mvdata.Cause_Of_Latest_Registration__c == 'R') 	{updateV.Status__c='Re-Registered'; }
            if(mvdata.Cause_Of_Latest_Registration__c == 'S') 	{updateV.Status__c='Scratch Built'; }
            if(mvdata.Expiry_Date_Of_Last_Successful_WOF__c != null)    {updateV.WOF_Expiry_Date__c=conDate(mvdata.Expiry_Date_Of_Last_Successful_WOF__c);}
            
            // Periphial details
            if(mvdata.Body_Style__c != null) 			{updateV.Body_Style__c=bodystyle(mvdata.Body_Style__c); }    
            if(mvdata.Main_Colour__c != null) 		{updateV.Vehicle_Colours__c=mvdata.Main_Colour__c; }  
            if(mvdata.Engine_No__c != null) 			{updateV.Engine_Number__c=mvdata.Engine_No__c; }   
            if(mvdata.CC_Rating__c != null) 			{updateV.Engine_Size__c=mvdata.CC_Rating__c; }   
            if(mvdata.Fuel_Type__c != null) 			{updateV.Fuel_Type__c=fuelType(mvdata.Fuel_Type__c); }   
            if(mvdata.No_Of_Seats__c != null) 		{updateV.Number_of_Seats__c=mvdata.No_Of_Seats__c; }   
            
            updateV.Vehicle_Type__c = vehicleType(mvdata.Vehicle_Type__c);   
            
            // check the plate - if a replacement plate then write a history record for it and then run the replacement plate number
            if(mvdata.Replacement_Plate__c != null) {
        				list<Plate__c> listP = [select id,name,Registration_Plate_Number__c,Registration_Status__c,Registration_End_Date__c,Registration_Start_Date__c,Plate_Type__c from Plate__c where (Registration_Plate_Number__c = :mvdata.Plate_No__c)];
            			if(!listP.isEmpty()) { 
                        	Plate_History__c pHistory = new Plate_History__c();
                        	pHistory.Plate__c=listP[0].Id;
                        	pHistory.Vehicle__c=currentV.Id;
                        	pHistory.Plate_Type__c=listP[0].plate_type__c;
                        	pHistory.Plate_Assignment_Changed_Date__c=conDate(mvdata.Date_Query_Processed__c);
                            updPlateH.add(pHistory);
              				message += '[ok] Plate History record created for Plate ' + mvdata.Plate_No__c + '\n';     
                        }
                        updateV.Registration_Active_Plate__c=checkPlate(mvdata, mvdata.Replacement_Plate__c);
                
            } else {
            if(mvdata.Plate_No__c != currentV.Registration_Plate_Number__c) {
                      	list<Plate__c> listP = [select id,name,Registration_Plate_Number__c,Registration_Status__c,Registration_End_Date__c,Registration_Start_Date__c,Plate_Type__c from Plate__c where (Registration_Plate_Number__c = :currentV.Registration_Plate_Number__c)];
            			if(!listP.isEmpty()) { 
                        	Plate_History__c pHistory = new Plate_History__c();
                        	pHistory.Plate__c=listP[0].Id;
                        	pHistory.Vehicle__c=currentV.Id;
                        	pHistory.Plate_Type__c=listP[0].plate_type__c;
                        	pHistory.Plate_Assignment_Changed_Date__c=conDate(mvdata.Date_Query_Processed__c);
                            updPlateH.add(pHistory);
              				message += '[ok] Plate History record created for Plate ' + mvdata.Plate_No__c + '\n';  
                        }
                		updateV.Registration_Active_Plate__c=checkPlate(mvdata, mvdata.Plate_No__c);
            }}
            
            // update vehicle record
            updateV.Last_Touch_Point_From__c='MVR';
            updateV.Last_Touch_Point_Date__c=conDate(mvdata.Date_Of_Issue_For_Latest_Licence__c);
//        	updVehicles.add(updateV);
        	update updateV;
            message += '[ok] Vehicle details updated \n';
        	}            
              
            // check if an existing ownership record exists
        	list<Ownership__c> listOwners = [select id,name,Dealer__c,Insurance_Company__c,Ownership_Start__c,Registered_Owner__c,Vehicle__c
                                             from Ownership__c where (Vehicle__c = :currentV.Id)];
            if(listOwners.isEmpty()) { 
                newOwnership(mvdata, currentV.Id); 
            } else {
                existingOwnership(mvdata, listOwners[0]); 
            }
        
        // update marketing contact
        Vehicle__c updMarketContact = [select id,Marketing_Contact__c from Vehicle__c where Id = :currentV.Id];
        list<Ownership__c> mOwner = [select id,Registered_Owner__c from Ownership__c where Vehicle__c = :currentV.Id];
        list<Account> mAcc = [select id from Account where Id = :mOwner[0].Registered_Owner__c];
        list<Contact> mCnt = [select id from Contact where (AccountId = :mAcc[0].Id and Roles__c includes ('Marketing'))];
        if(!mCnt.isEmpty()) {
        	updMarketContact.Marketing_Contact__c=mCnt[0].Id;
            update updMarketContact;
        }
    }
    
 	// New Vehicle - add a new vehicle and check the plate
    public  void newVehicle(MVR__c mvdata) {
        
        	vehicle__c updateV = new vehicle__c();
            if(mvdata.Body_Style__c != null) 			{updateV.Body_Style__c=bodystyle(mvdata.Body_Style__c); }    
            if(mvdata.Chassis_No__c != null) 			{updateV.Chassis_Number__c=mvdata.Chassis_No__c; }   
            if(mvdata.Date_Of_First_Registration_In_NZ__c != null) {updateV.Date_First_Registered_in_NZ__c=conDate(mvdata.Date_Of_First_Registration_In_NZ__c); }   
            if(mvdata.Engine_No__c != null) 			{updateV.Engine_Number__c=mvdata.Engine_No__c; }   
            if(mvdata.CC_Rating__c != null) 			{updateV.Engine_Size__c=mvdata.CC_Rating__c; }   
            if(mvdata.Fuel_Type__c != null) 			{updateV.Fuel_Type__c=fuelType(mvdata.Fuel_Type__c); }   
            if(mvdata.Submodel__c != null) 				{updateV.Model_Variant_Group_Name__c=mvdata.Submodel__c; }   
            if(mvdata.No_Of_Seats__c != null) 		{updateV.Number_of_Seats__c=mvdata.No_Of_Seats__c; }   
            if(mvdata.Latest_Odometer_Reading__c != null) 	{updateV.Odometer_Readings__c=string.valueOf(integer.valueOf(mvdata.Latest_Odometer_Reading__c)); }   
            if(mvdata.Main_Colour__c != null) 		{updateV.Vehicle_Colours__c=mvdata.Main_Colour__c; }   
            if(mvdata.Make__c != null) 					{updateV.Vehicle_Make__c=mvdata.Make__c; }   
            if(mvdata.Model__c != null) 				{updateV.Vehicle_Model__c=mvdata.Model__c; }   
            if(mvdata.VIN__c != null) 					{updateV.VIN__c=mvdata.VIN__c; }               
            if(mvdata.Expiry_Date_Of_Last_Successful_WOF__c != null)    {updateV.WOF_Expiry_Date__c=conDate(mvdata.Expiry_Date_Of_Last_Successful_WOF__c);}
            if(mvdata.Year_Of_Manufacture__c != null) 	{updateV.Year_Made__c=string.valueOf(integer.valueOf(mvdata.Year_Of_Manufacture__c)); }     
            if(mvdata.Cause_Of_Latest_Registration__c == 'N') 	{updateV.Status__c='New'; }  
            if(mvdata.Cause_Of_Latest_Registration__c == 'U') 	{updateV.Status__c='Used'; }
            if(mvdata.Cause_Of_Latest_Registration__c == 'R') 	{updateV.Status__c='Re-Registered'; }
            if(mvdata.Cause_Of_Latest_Registration__c == 'S') 	{updateV.Status__c='Scratch Built'; }
            updateV.Vehicle_Type__c = vehicleType(mvdata.Vehicle_Type__c);   
        
            // check the plate
            if(mvdata.Replacement_Plate__c != null) {
        		updateV.Registration_Active_Plate__c=checkPlate(mvdata, mvdata.Replacement_Plate__c);
            } else {
                updateV.Registration_Active_Plate__c=checkPlate(mvdata, mvdata.Plate_No__c);
            }

            updateV.Last_Touch_Point_From__c='MVR';
            updateV.Last_Touch_Point_Date__c=conDate(mvdata.Date_Of_Issue_For_Latest_Licence__c);
        	insert updateV;
            message += '[ok] Vehicle details created \n';
        
        	// search for account & contact
        	id foundAcc = searchAcc(mvdata); 
        	 
        	// if not found add account & contact(s) and create ownership
        	if(foundAcc == null) {
            	id accId = addAccount(mvdata);
                addOwnership(updateV.id, accid, mvdata);
                message += '[ok] New Ownership Record created for new Account \n'; 
            } else {

                // check details match - update if not
                addOwnership(updateV.id, foundAcc, mvdata);
              	message += '[ok] New Ownership Record created for existing Account \n';                 
            }

        // update marketing contact
        Vehicle__c updMarketContact = [select id,Marketing_Contact__c from Vehicle__c where Id = :updateV.Id];
        list<Ownership__c> mOwner = [select id,Registered_Owner__c from Ownership__c where Vehicle__c = :updateV.Id];
        list<Account> mAcc = [select id from Account where Id = :mOwner[0].Registered_Owner__c];
        list<Contact> mCnt = [select id from Contact where (AccountId = :mAcc[0].Id and Roles__c='Marketing')];
        if(!mCnt.isEmpty()) {
        	updMarketContact.Marketing_Contact__c=mCnt[0].Id;
            update updMarketContact;
        }        
                
    }

      
 	// Plate Check
    public Id checkPlate(MVR__c mvdata, string platenum) {

        	// if no current plate then add plate details and return Id
        	list<Plate__c> listPlates = [select id,name,Registration_Plate_Number__c,Registration_Status__c,Registration_End_Date__c,Registration_Start_Date__c,Plate_Type__c from Plate__c where (Registration_Plate_Number__c = :platenum)];
            if(listPlates.isEmpty()) { 
                Plate__c plate = new Plate__c();
                if(mvdata.Registration_Status__c=='A') {plate.Registration_Status__c='Active'; }
                if(mvdata.Registration_Status__c=='C') {plate.Registration_Status__c='Cancelled'; }
                if(mvdata.Registration_Status__c=='L') {plate.Registration_Status__c='Lapsed'; }                
                plate.Registration_End_Date__c=conDate(mvdata.Licence_Expiry_Date__c);
                plate.Registration_Start_Date__c=conDate(mvdata.Date_Of_Issue_For_Latest_Licence__c);
                plate.Registration_Plate_Number__c=platenum;
                if(mvdata.Plate_Type__c=='ST') {plate.Plate_Type__c='Standard';}
                if(mvdata.Plate_Type__c=='CR') {plate.Plate_Type__c='Crown';}
                if(mvdata.Plate_Type__c=='DC') {plate.Plate_Type__c='Diplomatic';}
                if(mvdata.Plate_Type__c=='TD') {plate.Plate_Type__c='Investment';}
                if(mvdata.Plate_Type__c=='PP') {plate.Plate_Type__c='Personalised';}
                if(mvdata.Plate_Type__c=='IN') {plate.Plate_Type__c='Special Issue';}
                if(mvdata.Plate_Type__c=='SI') {plate.Plate_Type__c='Trade';}
            	plate.Last_Touch_Point_From__c='MVR';
            	plate.Last_Touch_Point_Date__c=conDate(mvdata.Date_Of_Issue_For_Latest_Licence__c);                
    				insert plate;
            		message += '[ok] New Plate record created \n';                
                	return plate.Id;
            } else {
                
                                    
               // update rego info
                  Plate__c plate = new Plate__c();
                  plate.id=listPlates[0].Id;
                  if(mvdata.Registration_Status__c=='A') {plate.Registration_Status__c='Active'; }
                  if(mvdata.Registration_Status__c=='C') {plate.Registration_Status__c='Cancelled'; }
                  if(mvdata.Registration_Status__c=='L') {plate.Registration_Status__c='Lapsed'; }                
                  plate.Registration_End_Date__c=conDate(mvdata.Licence_Expiry_Date__c);
                  plate.Registration_Start_Date__c=conDate(mvdata.Date_Of_Issue_For_Latest_Licence__c); 
                  if(mvdata.Plate_Type__c=='ST') {plate.Plate_Type__c='Standard';}
                  if(mvdata.Plate_Type__c=='CR') {plate.Plate_Type__c='Crown';}
                  if(mvdata.Plate_Type__c=='DC') {plate.Plate_Type__c='Diplomatic';}
                  if(mvdata.Plate_Type__c=='TD') {plate.Plate_Type__c='Investment';}
                  if(mvdata.Plate_Type__c=='PP') {plate.Plate_Type__c='Personalised';}
                  if(mvdata.Plate_Type__c=='IN') {plate.Plate_Type__c='Special Issue';}
                  if(mvdata.Plate_Type__c=='SI') {plate.Plate_Type__c='Trade';}                
            	  plate.Last_Touch_Point_From__c='MVR';
            	  plate.Last_Touch_Point_Date__c=conDate(mvdata.Date_Of_Issue_For_Latest_Licence__c);                  
//                  updPlates.add(plate);
				  update plate;
                  message += '[ok] Exiting Plate Registration details updated \n';                
                
           		// if plate exists then check if its on another vehicle already.
           		list<vehicle__c> cplate = [select id,Registration_Active_Plate__c,VIN__c from vehicle__c where (Registration_Active_Plate__c=:listPlates[0].Id and VIN__c != :mvdata.VIN__c)];
                if(cplate.isEmpty()) {return listPlates[0].Id;
                      } else {
                          
                    	// if it is on another vehicle then remove it and write a message in the mvr table.
                    	cplate[0].Registration_Active_Plate__c=null;
                        updVehicles.add(cplate[0]);
            			message += '[Caution] Plate removed from existing vehicle, VIN = ' + cplate[0].VIN__c + ' \n';
                        if(mvdata.error_message_severity__c != 'Error') {mvdata.error_message_severity__c = 'Caution';  }
                          
                        // update plate history and return
                        Plate_History__c pHistory = new Plate_History__c();
                        pHistory.Plate__c=listPlates[0].Id;
                        pHistory.Vehicle__c=cplate[0].Id;
                        pHistory.Plate_Type__c=listPlates[0].plate_type__c;
                        pHistory.Plate_Assignment_Changed_Date__c=conDate(mvdata.Acquisition_Date__c);
              			message += '[ok] Plate History record created \n'; 
                          
                        updPlateH.add(pHistory);
                    	return listPlates[0].Id;
                }
            }      

    }
    // -------------------------------------------------------------------------------------------------------- OWNERSHIP METHODS ----------------------------------------------------------------------------------------------------    
 	// NEW Ownership - add a new ownership and check account / contact
    public  void newOwnership(MVR__c mvdata, Id vehicleId) {
                	
        	// search for account & contact
        	id foundAcc = searchAcc(mvdata); 
        	 
        	// if not found add account & contact(s) and create ownership
        	if(foundAcc == null) {
            	id accId = addAccount(mvdata);
                addOwnership(vehicleId, accid, mvdata);
              	message += '[ok] New Ownership Record created for new Account \n';                 
            } else {

                // if account found update the ownership record - and write history record.
                addOwnership(vehicleId, foundAcc, mvdata); 
              	message += '[ok] New Ownership Record created for existing Account \n';                    
            }
        
    }
    
 	// EXISTING Ownership - update ownership and check account / contact
    public  void existingOwnership(MVR__c mvdata, Ownership__c currentOwn) {
        
        // check if acquisition date is later, if so process change of ownership
        if(currentOwn.Ownership_Start__c < conDate(mvdata.Acquisition_Date__c)) {
                    changeOwnership(mvdata, currentOwn);            
            
        } else {
            
            // if the dates are the same - check that the registered owner is the same....
            if(currentOwn.Ownership_Start__c == conDate(mvdata.Acquisition_Date__c)) {
                    list<Account> curAcc = [select id,name,last_Touch_Point_date__c,billingStreet,billingCity,billingPostalCode,shippingStreet,shippingCity,shippingPostalCode,Trading_As__c from Account where Id = :currentOwn.Registered_Owner__c];
                    if(curAcc.size() > 0) {
            
                            boolean accMatch = matchAcc(mvdata, curAcc[0]);
                            if (!accMatch) {
                                
                                // change of ownership
                                changeOwnership(mvdata, currentOwn);
                            }             
                        
                    } else {
                        message += '[Caution] Account on existing Ownership record not found, Account ID = ' + currentOwn.Registered_Owner__c   + ' \n';  
                        if(mvdata.error_message_severity__c != 'Error') {mvdata.error_message_severity__c = 'Caution';  }
            
                    }
            } else {
                
                // previous ownership record - no business rules atm
                message += '[Caution] This is a previous ownership record, no updates done to ownership records'  + ' \n';  
                if(mvdata.error_message_severity__c != 'Error') {mvdata.error_message_severity__c = 'Caution';  }
                
            }

        }

    }

    
 	// ADD Ownership - add a new ownership record
    public void addOwnership(id vehicleID, id accID, MVR__c mvdata) {
        	
        	Ownership__c newOwn = new Ownership__c();
        	
        	newOwn.vehicle__c=vehicleId;
        	newOwn.Registered_Owner__c=accID;
        	newOwn.Fleet_Lease_Ownership__c=mvdata.Fleet_Lease_Ownership__c;
        	newOwn.Fleet_Lease_Owner__c=mvdata.Fleet_Lease_Owner__c;
        	newOwn.Ownership_Start__c=conDate(mvdata.Acquisition_Date__c);
            newOwn.Last_Touch_Point_From__c='MVR';
            newOwn.Last_Touch_Point_Date__c=conDate(mvdata.Date_Of_Issue_For_Latest_Licence__c);          
        	
        	if(mvdata.Ownership_Status__c == 'C') {newOwn.Ownership_Status__c='Complete';}
        	if(mvdata.Ownership_Status__c == 'U') {newOwn.Ownership_Status__c='Unconfirmed';}
        	if(mvdata.Ownership_Status__c == 'I') {newOwn.Ownership_Status__c='Incomplete';}        
        	insert newOwn;
    }
        
 	// UPDATE Ownership - add a new account to ownership record
    public void  updateOwnership(id ownerID, id accID, MVR__c mvdata) {
        	
        	Ownership__c newOwn = [select id,name from Ownership__c where Id=:ownerId];
        	
        	newOwn.Registered_Owner__c=accID;
        	newOwn.Fleet_Lease_Ownership__c=mvdata.Fleet_Lease_Ownership__c;
        	newOwn.Fleet_Lease_Owner__c=mvdata.Fleet_Lease_Owner__c;
        	newOwn.Ownership_Start__c=conDate(mvdata.Acquisition_Date__c);
            newOwn.Last_Touch_Point_From__c='MVR';
            newOwn.Last_Touch_Point_Date__c=conDate(mvdata.Date_Query_Processed__c);           
        	if(mvdata.Ownership_Status__c == 'C') {newOwn.Ownership_Status__c='Complete';}
        	if(mvdata.Ownership_Status__c == 'U') {newOwn.Ownership_Status__c='Unconfirmed';}
        	if(mvdata.Ownership_Status__c == 'I') {newOwn.Ownership_Status__c='Incomplete';}      
        
        	update newOwn;
    }
    
    
 	// CHANGE Ownership - update ownership to new account
    public void  changeOwnership(MVR__c mvdata, Ownership__c currentOwn) {

        	// search for account & contact
        	id foundAcc = searchAcc(mvdata); 
        	 
        	// if not found add account & contact(s) and create ownership
        	if(foundAcc == null) {
            	id accId = addAccount(mvdata);
//                updOwnership.add(updateOwnership(currentOwn.id, accid, mvdata));
				updateOwnership(currentOwn.id, accid, mvdata);
                message += '[ok] Change of Ownership - New Account & Ownership Record updated \n';                    
            } else {

                // if account found update the ownership record - and write history record.
//                updOwnership.add(updateOwnership(currentOwn.id, foundAcc, mvdata));     
				updateOwnership(currentOwn.id, foundAcc, mvdata);
                message += '[ok] Change of Ownership - Existing Account & Ownership Record updated \n';                      
            }
        
                Ownership_History__c oHistory = new Ownership_History__c();
                oHistory.Dealer__c=currentOwn.Dealer__c;
                oHistory.Insurance_Company__c=currentOwn.Insurance_Company__c;
                oHistory.Ownership_Finished__c=conDate(mvdata.Acquisition_Date__c);
                oHistory.Ownership_Start__c=currentOwn.Ownership_Start__c;
                oHistory.Registered_Owner__c=currentOwn.Registered_Owner__c;
                oHistory.Vehicle__c=currentOwn.Vehicle__c;
				updOwnershipH.add(oHistory);       
              	message += '[ok] Change of Ownership - Ownership History Record created \n';              
    }
    
    // -------------------------------------------------------------------------------------------------------- ACCOUNT & CONTACT METHODS ----------------------------------------------------------------------------------------------------            
 	// SEARCH for Account and Contact using the MVR details 
    public  Id searchAcc(MVR__c mvdata) {
        Id foundAcc;
        
        // first level search - use the name 
        string sName = mvdata.Registered_Person_Name__c;
        if(mvdata.Joint_Owner_Name_No_1__c != null) {sName += ' & ' + mvdata.Joint_Owner_Name_No_1__c ;}
        if(mvdata.Joint_Owner_Name_No_2__c != null) {sName += ' & ' + mvdata.Joint_Owner_Name_No_2__c ;}
        if(mvdata.Joint_Owner_Name_No_3__c != null) {sName+= ' & ' + mvdata.Joint_Owner_Name_No_3__c ;}  
        
        // name, trading as  vs registered person name
        list<account> findAcc = [select id,name,last_Touch_Point_date__c,billingStreet,billingCity,billingPostalCode,shippingStreet,shippingCity,shippingPostalCode,Trading_As__c from Account where (Name = :sName or Trading_As__c = :sName)];
        if(findAcc.size() > 0) {
            
            // have a name match but do other details match e.g. in the case of John Smith.
            // check if either address is a match....
            for(Account acc: findAcc) {
                if(acc.BillingStreet == formatMailingStreet(mvdata)) {
                    if(acc.BillingCity == mvdata.Mailing_Address_Town__c) {
                        if(acc.BillingPostalCode == mvdata.Mailing_Address_Postcode__c) {
                            message += '[ok] Search for Account - Match on Name and Mailing Address ' + acc.name + '\n';      
                            return acc.id;
                        }
                    }
                }
                
                if(acc.ShippingStreet == formatPhysicalStreet(mvdata)) {
                    if(acc.ShippingCity == mvdata.Physical_Address_Town__c) {
                        if(acc.ShippingPostalCode == mvdata.Physical_Address_Postcode__c) {
                            message += '[ok] Search for Account - Match on Name and Physical Address ' + acc.name + '\n';                  
                            return acc.id;
                        }
                    }
                }               
            
            // if match on name but addresses are different then check gender and DOB on contact record
            string cName = mvdata.Registered_Person_Name__c;
            if(mvdata.Joint_Owner_Name_No_1__c != null) {cName = mvdata.Joint_Owner_Name_No_1__c ;}
			list<Contact> findCnt = [select id,name,gender__c,Birthdate from Contact where (AccountId = :acc.Id and Name = :cName)];
                if(findCnt.size()>0) {
                    if(findCnt[0].gender__c == mvdata.Sex_Company__c && findCnt[0].birthdate == conDate(mvdata.Date_of_Birth_Of_Registered_Person__c)) {
                        message += '[ok] Search for Account - Match on Name and DOB and Gender ' + findCnt[0].name + '\n';                             
                        return acc.id;
                    }
                }    
            
        }
        }
                
        return foundAcc;
    }

            
 	// ADD Account and Contact using the MVR details 
    public  Id addAccount(MVR__c mvdata) {
        
        // check whether registered owner details should be suppressed
        if(mvdata.Make__c != 'Toyota'  &&  mvdata.Make__c != 'Lexus'  && mvdata.Make__c != 'Daihatsu' && mvdata.Sex_Company__c != 'C') {
            list<account> suppressed = [select id,name from Account where Name = 'Suppressed Owner'];
            if(suppressed.size()>0) {
                return suppressed[0].Id;
            } else {
                Account newAcc = new Account();
                newAcc.name = 'Suppressed Owner';
        		newAcc.Last_Touch_Point_Date__c=conDate(mvdata.Date_Of_Issue_For_Latest_Licence__c);
        		newAcc.Last_Touch_Point_From__c='MVR';    
                newAcc.Type='Private Individual';
                newAcc.status__c = 'Active';
                newAcc.RecordTypeId=individual.Id;
                insert newAcc;
                return newAcc.Id;
            }
        }
        
        // add Account
		Account newAcc = new Account();
        newAcc.Name = mvdata.Registered_Person_Name__c;
        if(mvdata.Joint_Owner_Name_No_1__c != null) {newAcc.Name += ' & ' + mvdata.Joint_Owner_Name_No_1__c ;}
        if(mvdata.Joint_Owner_Name_No_2__c != null) {newAcc.Name += ' & ' + mvdata.Joint_Owner_Name_No_2__c ;}
        if(mvdata.Joint_Owner_Name_No_3__c != null) {newAcc.Name += ' & ' + mvdata.Joint_Owner_Name_No_3__c ;}
		newAcc.Name=nameFormat(newAcc.Name);
        if(mvdata.Gone_No_Address__c=='Y') {newAcc.Gone_No_Address__c=true;}
        newAcc.Last_Touch_Point_Date__c=conDate(mvdata.Date_Query_Processed__c);
        newAcc.Last_Touch_Point_From__c='MVR';
        newAcc.Trading_As__c=mvdata.Trading_As_Representing__c;
        if(mvdata.sex_company__c == 'C') {newAcc.Type='Large Corporate';}
            else {if(mvdata.Joint_Owner_Indicator__c == 'Y') 
                	{newAcc.Type='Joint Owners';}   
                	else {newAcc.Type='Private Individual';}}
        newAcc.status__c = 'Active';
        
        // mailing address = billing address
        if(mvdata.Mailing_Address_Street_Name__c != null || mvdata.Mailing_Address_Box_Bag_Rd__c != null) {
        newAcc.BillingStreet=formatMailingStreet(mvdata);
        newAcc.BillingCity=mvdata.Mailing_Address_Town__c;
        newAcc.BillingPostalCode=mvdata.Mailing_Address_Postcode__c;
            newAcc.BillingCountry='New Zealand';}
        
       // physical address = shipping address
        if(mvdata.Physical_Address_Street_Name__c != null  || mvdata.Physical_Address_RD_Number__c != null) {
        newAcc.ShippingStreet=formatPhysicalStreet(mvdata);
        newAcc.ShippingCity=mvdata.Physical_Address_Town__c;
        newAcc.ShippingPostalCode=mvdata.Physical_Address_Postcode__c;
        newAcc.ShippingCountry='New Zealand';     }
        
        if(mvdata.sex_company__c == 'C') {newAcc.RecordTypeId=company.Id;} 
        	else {newAcc.RecordTypeId=individual.Id;}
        message += '[ok] New Account created - Account Name is '  + newAcc.Name  +  '\n';           
        insert newAcc;

        // add Contact(s) - multiple if joint ownership
        list<contact> newCnts = new list<contact>();
        newCnts.add(addContact(mvdata.Registered_Person_Name__c, newAcc.id, mvdata));
        if(mvdata.Joint_Owner_Name_No_1__c != null) {newCnts.add(addContact(mvdata.Joint_Owner_Name_No_1__c, newAcc.id, mvdata));}
        if(mvdata.Joint_Owner_Name_No_2__c != null) {newCnts.add(addContact(mvdata.Joint_Owner_Name_No_2__c, newAcc.id, mvdata));}
        if(mvdata.Joint_Owner_Name_No_3__c != null) {newCnts.add(addContact(mvdata.Joint_Owner_Name_No_3__c, newAcc.id, mvdata));}        
        insert newCnts;
        
        return newAcc.Id;
    }
    
        
 	// ADDCONTACT use the MVR data to add a contact record
    public  contact addContact(string conName, id newAcc, MVR__c mvdata) {      
        
        // add Contact(s)
        Contact newCnt = new Contact();
        newCnt.AccountId=newAcc;

        list<string> roles = new list<string>();
		roles.add('Marketing');
        if(conName == mvdata.Registered_Person_Name__c) {newCnt.Roles__c=cntRoles();}
        
        if(mvdata.Sex_Company__c != 'C') {
        	newCnt.FirstName=''; newCnt.LastName='';
        	string[] names = conName.Split(' ');
        	if(names.size()<=1) {
        		newCnt.LastName=nameFormat(conName);        
        	} else {
                		integer x = 1;
                		if(names.size()>=3) {
                            if(conName.Contains('VAN DE ')) {x = 3;} else {
                                if(conName.Contains('VAN DER ')) {x = 3;} else {
                                    if(conName.Contains('VAN ')) {x = 2;} else {
                                        if(conName.Contains('DE ')) {x = 2;}}}}
                        }
            	        for(integer i=0; i<names.size()-x; i++) {
            				newCnt.FirstName+=names[i] + ' ';
        				}
            	        for(integer i=names.size()-x; i<names.size(); i++) {
            				newCnt.LastName+=names[i] + ' ';
        				}  
                		newCnt.FirstName=nameFormat(newCnt.FirstName);
        				newCnt.LastName=nameFormat(newCnt.LastName);
        	}
        } else {
                newCnt.lastName=nameFormat(conName);
            }

        newCnt.Birthdate=conDate(mvdata.Date_of_Birth_Of_Registered_Person__c);
        if(mvdata.Gone_No_Address__c=='Y') {newCnt.Gone_No_Address__c=true;}    
        if(mvdata.Sex_Company__c=='F') {newCnt.Gender__c='Female';}        
        if(mvdata.Sex_Company__c=='M') {newCnt.Gender__c='Male';}                
        newCnt.Last_Touch_Point_Date__c=conDate(mvdata.Date_Of_Issue_For_Latest_Licence__c);
        newCnt.Last_Touch_Point_From__c='MVR';        
        
        // mailing address = Mailing address
        if(mvdata.Mailing_Address_Street_Name__c != null) {
        newCnt.MailingStreet=formatMailingStreet(mvdata);
        newCnt.MailingCity=mvdata.Mailing_Address_Town__c;
        newCnt.MailingPostalCode=mvdata.Mailing_Address_Postcode__c;
        newCnt.MailingCountry='New Zealand'; }
        
       // physical address = Other address
        if(mvdata.Physical_Address_Street_Name__c != null) {
        newCnt.OtherStreet=formatPhysicalStreet(mvdata);
        newCnt.OtherCity=mvdata.Physical_Address_Town__c;
        newCnt.OtherPostalCode=mvdata.Physical_Address_Postcode__c;
        newCnt.OtherCountry='New Zealand';      }
        message += '[ok] New Contact created - Contact Name is '  + newCnt.FirstName  + ' ' + newCnt.LastName +  '\n';          
        return newCnt;
    }    

    
    
 	// MATCH the MVR details with current Account Details
    public  boolean matchAcc(MVR__c mvdata, Account curAcc) {
        boolean match = false;
        
        // first level search - use the name 
        string sName = mvdata.Registered_Person_Name__c;
        if(mvdata.Joint_Owner_Name_No_1__c != null) {sName += ' & ' + mvdata.Joint_Owner_Name_No_1__c ;}
        if(mvdata.Joint_Owner_Name_No_2__c != null) {sName += ' & ' + mvdata.Joint_Owner_Name_No_2__c ;}
        if(mvdata.Joint_Owner_Name_No_3__c != null) {sName+= ' & ' + mvdata.Joint_Owner_Name_No_3__c ;}  
            
        if(sName == curAcc.Name) {
        
            if(mvdata.Sex_Company__c == 'C') {
                      message += '[ok] Match Account Details - Match found on Name for Company ' + curAcc.name + '\n';                           
                      match = true;
                      return match;
            }
            
            // have a name match but do other details match e.g. in the case of John Smith.
            // check if either address is a match....
                if(curAcc.BillingStreet == formatMailingStreet(mvdata)) {
                    if(curAcc.BillingCity == mvdata.Mailing_Address_Town__c) {
                        if(curAcc.BillingPostalCode == mvdata.Mailing_Address_Postcode__c) {
        					message += '[ok] Match Account Details - Match found on Name and Mailing Address ' + curAcc.name + '\n';                           
                            match = true;
                            return match;
                        }
                    }
                }
           
                if(curAcc.ShippingStreet == formatPhysicalStreet(mvdata)) {
                    if(curAcc.ShippingCity == mvdata.Physical_Address_Town__c) {
                        if(curAcc.ShippingPostalCode == mvdata.Physical_Address_Postcode__c) {
        					message += '[ok] Match Account Details - Match found on Name and Physical Address ' + curAcc.name + '\n';       
                            match = true;
                            return match;
                        }
                    }
                }               
            
            // if match on name but addresses are different then check gender and DOB on contact record
            string cName = mvdata.Registered_Person_Name__c;
            if(mvdata.Joint_Owner_Name_No_1__c != null) {cName = mvdata.Joint_Owner_Name_No_1__c ;}            
			list<Contact> findCnt = [select id,name,gender__c,Birthdate from Contact where (AccountId = :curAcc.Id and Name = :cName)];
                if(findCnt.size()>0) {
                    if(findCnt[0].gender__c == mvdata.Sex_Company__c && findCnt[0].birthdate == conDate(mvdata.Date_of_Birth_Of_Registered_Person__c)) {
        				message += '[ok] Match Account Details - Match found on Name and DOB & Gender ' + findCnt[0].name + '\n';     
                        match = true;
                        return match;
                    }
                }    
        }
        
        return match;
    }
       

    // -------------------------------------------------------------------------------------------------------- UTILITY METHODS ----------------------------------------------------------------------------------------------------
 	// format the mailing street address in the MVR table to a SFDC address
    public  static String formatMailingStreet(MVR__c mvdata) {
					string street ='';
                    if(mvdata.Mailing_Address_Property_Name__c != null) {street=mvdata.Mailing_Address_Property_Name__c;}
        
        			// flat / floor
        			if(mvdata.Mailing_Address_Flat_Floor_Name__c != null) {
            			if(mvdata.Mailing_Address_Flat_Floor_Name__c.isAlphaSpace()) {
                            if(street.length() > 0) {street+='\n';}
                            street+=mvdata.Mailing_Address_Street_Number__c;
                            street+=mvdata.Mailing_Address_Flat_Floor_Name__c + ' ';
                            street+=mvdata.Mailing_Address_Street_Name__c;                            
                        } else {
                            if(street.length() > 0) {street+='\n';}
                            street+=mvdata.Mailing_Address_Flat_Floor_Name__c +'/';
                            street+=mvdata.Mailing_Address_Street_Number__c + ' ';
                            street+=mvdata.Mailing_Address_Street_Name__c;
                        }
                        
                    // street address    
                    } else {
                        if(mvdata.Mailing_Address_Street_Number__c != null) {
                            if(street.length() > 0) {street+='\n';}
                            street+=mvdata.Mailing_Address_Street_Number__c + ' ';
                            street+=mvdata.Mailing_Address_Street_Name__c;
                    }} 
                    
        			// RD or Box
                    if(mvdata.Mailing_Address_Box_Bag_Rd__c != null) {
                            if(street.length() > 0) {street+='\n';}                        
                            street+=mvdata.Mailing_Address_Box_Bag_Rd__c + ' ';
                        	if(mvdata.Mailing_Address_Box_Bag_Number__c != null) 	{street+=mvdata.Mailing_Address_Box_Bag_Number__c; }
                        	if(mvdata.Mailing_Address_RD_Number__c != null)  			{street+=mvdata.Mailing_Address_RD_Number__c; }
                     }
        			if(mvdata.Mailing_Address_Suburb__c != null) {
                        if(street.length() > 0) {street+='\n';}                        
                        street+=mvdata.Mailing_Address_Suburb__c ;}
        
        			return street;
    }
    
 	// format the physical street address in the MVR table to a SFDC address
    public  static String formatPhysicalStreet(MVR__c mvdata) {
					string street ='';
                    if(mvdata.Physical_Address_Property_Name__c != null) {street=mvdata.Physical_Address_Property_Name__c;}
        
        			// flat / floor
        			if(mvdata.Physical_Address_Flat_Floor_Number__c != null) {
            			if(mvdata.Physical_Address_Flat_Floor_Number__c.isAlphaSpace()) {
                            if(street.length() > 0) {street+='\n';}                            
                            street+=mvdata.Physical_Address_Street_Number__c;
                            street+=mvdata.Physical_Address_Flat_Floor_Number__c + ' ';
                            street+=mvdata.Physical_Address_Street_Name__c;                            
                        } else {
                            if(street.length() > 0) {street+='\n';}                            
                            street+=mvdata.Physical_Address_Flat_Floor_Number__c +'/';
                            street+=mvdata.Physical_Address_Street_Number__c + ' ';
                            street+=mvdata.Physical_Address_Street_Name__c;
                        }
                        
                    // street address    
                    } else {
                        if(mvdata.Physical_Address_Street_Name__c != null) {
                            if(street.length() > 0) {street+='\n';}                            
                            street+=mvdata.Physical_Address_Street_Number__c + ' ';
                            street+=mvdata.Physical_Address_Street_Name__c;
                    }} 

        			// RD or Box
                    if(mvdata.Physical_Address_RD_Number__c != null) {
                            if(street.length() > 0) {street+='\n';}                        
                            street+='RD'+mvdata.Physical_Address_RD_Number__c + ' ';
                        	if(mvdata.Physical_Address_Street_Name__c != null) 	{street+='\n'+mvdata.Physical_Address_Street_Name__c; }
                     }
        			if(mvdata.Physical_Address_Suburb__c != null) {
                        if(street.length() > 0) {street+='\n';}                        
                        street+=mvdata.Physical_Address_Suburb__c ;}
        
        			return street;
    }

    
 	// convert the MVR dates from DDMMCCYY to a salesforce date...
    public  static Date conDate(decimal mvdate) {
                    string datevar = String.valueOf(integer.valueOf(mvdate));  date rdate;
        			if(datevar.length()==7) { rdate = date.newinstance(integer.valueOf(datevar.substring(3,7)),integer.valueOf(datevar.substring(1,3)),integer.valueOf(datevar.substring(0,1)));}
        			if(datevar.length()==8) { rdate = date.newinstance(integer.valueOf(datevar.substring(4,8)),integer.valueOf(datevar.substring(2,4)),integer.valueOf(datevar.substring(0,2)));}
        			return rdate;
    }
    
    // convert the MVR names to the correct capitalsiation...
    public static string nameFormat(String name1) {
		name1=name1.toLowerCase();
        List<String> elems = name1.split(' ');
		name1= '';
        for (String x : elems) {
    		name1 += x.substring(0,1).toUpperCase()+x.substring(1,x.length()) + ' ';
			}
		return name1;
		}

    
    // set up contact roles
       public static String cntRoles() {

        list<string> roles = new list<string>();
		roles.add('Marketing');
		return String.join(roles, ';');
    }          
    
    // convert the body style code to the desxcription as per NZTA definitions...
    public static string bodyStyle(String code) {
		string body = code;
        if (code == 'CV') {body='Convertible';}
        if (code == 'HA') {body='Hatchback';}
        if (code == 'LB') {body='Minibus';}
        if (code == 'LV') {body='Light Van';}
        if (code == 'SL') {body='Saloon';}
        if (code == 'SP') {body='Sports Car';}
        if (code == 'SW') {body='Station Wagon';}
        if (code == 'UT') {body='Utility';}
        if (code == 'FT') {body='Flat Deck Truck';}        
        if (code == 'OT') {body='Other Truck';}    
        if (code == 'SC') {body='Self Propelled Caravan';} 
            
		return body;
		}
    
    
    // convert the vehicle type code to the desxcription as per NZTA definitions...
    public static string vehicleType(decimal code) {
		string body = string.valueOf(code);
        if (code == 1) {body='Moped';}
        if (code == 2) {body='Trailer/Caravan';}
        if (code == 3) {body='Tractor';}
        if (code == 4) {body='Agricultural Machine';}
        if (code == 5) {body='Trailer Not Designed For H/Way Use';}
        if (code == 6) {body='Mobile Machine';}
        if (code == 7) {body='Passenger Car/Van';}
        if (code == 8) {body='Goods Van/Truck/Utility';}
        if (code == 9) {body='Bus';}        
        if (code == 10) {body='Motor Caravan';}    
        if (code == 11) {body='Motorcycle';}            
        if (code == 12) {body='ATV';}    
        if (code == 13) {body='Special Purpose Vehicle';}  
        
		return body;
		}    
    
    // convert the fuel type code to the desxcription as per NZTA definitions...
    public static string fuelType(decimal code) {
		string body = string.valueOf(code);
        if (code == 1) {body='Petrol';}
        if (code == 2) {body='Diesel';}
        if (code == 3) {body='CNG';}
        if (code == 4) {body='LPG';}
        if (code == 5) {body='Electric';}
        if (code == 6) {body='Other';}
        
		return body;
		}      
    
    // convert the fuel type code to the desxcription as per NZTA definitions...
    public static string nztaErrorMessage(decimal code) {
		string body = string.valueOf(code);
        if (code == 21) {body='Plate/VIN invalid';}
        if (code == 22) {body='No Information';}
        if (code == 23) {body='Apply to TRC in writing';}
        if (code == 24) {body='Registration cancelled';}
        if (code == 25) {body='VIN has never been registered';}
        if (code == 26) {body='Plate has changed';}
        if (code == 27) {body='As At Date required';}
        if (code == 28) {body='Multiple owners as at requested date';}
        if (code == 29) {body='No owner recorded for requested date';}        
        if (code == 31) {body='Not currently registered';}    
        if (code == 32) {body='Plate not attached at requested date';}            
        if (code == 41) {body='No licence found';}    
        if (code == 42) {body='As At Date must not be greater than today';}  
        if (code == 43) {body='Invalid Date';}
        if (code == 44) {body='Plate has not been used';}
        if (code == 45) {body='Unknown query type';}
        if (code == 47) {body='Motochek User Details not found';}
        if (code == 53) {body='No Plate or VIN supplied';}
        if (code == 55) {body='Invalid Cert Type';}
        if (code == 56) {body='Trade plate – not valid for MR32';}
        if (code == 58) {body='Invalid Suburb/Town combo';}
        if (code == 61) {body='More than 20 previous plates';}        
        if (code == 62) {body='Account Inactive';}    
        if (code == 63) {body='Plate was also attached to another vehicle at query date';}            
        if (code == 64) {body='Trade Plate - not registered against a vehicle';}    
        if (code == 66) {body='Invalid Date of Birth';}  
        if (code == 71) {body='Vehicle is not subject to RUC.';}
        if (code == 72) {body='No Odometer History records';}
        if (code == 73) {body='Duplicate Request';}
        if (code == 87) {body='No Vehicle Usage History found';}
        if (code == 88) {body='Registration must be active';}
        if (code == 89) {body='No RUC Licences found';}
        if (code == 90) {body='Please supply either Last Name or Organisation Name not both';}        
        if (code == 92) {body='First Name not supplied';}    
        if (code == 93) {body='Last Name or Organisation Name not supplied';}            
        if (code == 95) {body='Enter PLATE or VIN – not both';}    
        if (code == 96) {body='Trader/Plate Relationship record not found';}  
        if (code == 97) {body='Registration Cancelled/Lapsed';}  
        
		return body;
		}   
    
    // convert the fuel type code to the desxcription as per NZTA definitions...
    public static string nztaErrorSeverity(decimal code) {
		string body = 'Ok';
        if (code == 31) {body='Unassigned';}
        if (code == 32) {body='Unassigned';}
        if (code == 44) {body='Unassigned';}        
        
        if (code == 28) {body='Caution';}
        if (code == 63) {body='Caution';}
        if (code == 24) {body='Caution';}
        if (code == 26) {body='Caution';}
        if (code == 58) {body='Caution';}
        if (code == 61) {body='Caution';}
        if (code == 62) {body='Caution';}
        if (code == 66) {body='Caution';}
        if (code == 71) {body='Caution';}
        if (code == 72) {body='Caution';}
        if (code == 87) {body='Caution';}
        if (code == 88) {body='Caution';}
        if (code == 89) {body='Caution';}
        if (code == 90) {body='Caution';}
        if (code == 92) {body='Caution';}
        if (code == 93) {body='Caution';}
        if (code == 97) {body='Caution';}
        
        if (code == 21) {body='Error';}
        if (code == 22) {body='Error';}
        if (code == 23) {body='Error';}
        if (code == 25) {body='Error';}
        if (code == 41) {body='Error';}
        if (code == 45) {body='Error';}
        if (code == 47) {body='Error';}
        if (code == 53) {body='Error';}
        if (code == 55) {body='Error';}
        if (code == 56) {body='Error';}
        if (code == 64) {body='Error';}
        if (code == 95) {body='Error';}
        if (code == 96) {body='Error';}
        if (code == 73) {body='Error';}
        
		return body;
		}  
    
    // -------------------------------------------------------------------------------------------------------- FINISH METHOD ----------------------------------------------------------------------------------------------------    
    // this method is the completion process - this will send an email advising process complete 
    global void finish(Database.BatchableContext BC){
        
        
        // Send an email
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()]; 

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {a.CreatedBy.Email}; 
        mail.setToAddresses(toAddresses); 
        mail.setSubject('Annual Confidentiality Process ' ); 
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.'); 
  //      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
 
    }



}