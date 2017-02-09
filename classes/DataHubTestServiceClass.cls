/*********************************************************************************
Name:          DataHubTestServiceClass
Author:         Digby Bartosh [Fujitsu]
Purpose:        This class is used to access VehicleInformation from Toyota's DataHub
Created Date:   12/11/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public class DataHubTestServiceClass {
    
    	 id vID;
    
    	// ------------------------------------------------------------------------------------------------------ callout methods -----------------------------------------------------------------------------------------------------------------------------------------------------            
    	// fetch the data based on Plate
        public  void fetchDataHubPlate(string plate){

            // call datahub and get vehicle details
            VMSgetVehicleInfoInterface.wrapperClass wc = new VMSgetVehicleInfoInterface.wrapperClass();
            VMSgetVehicleInfoInterface run = new VMSgetVehicleInfoInterface();
			wc=run.getCallout(plate);
            
            // call datahub and get the vehicle photo
            VMSgetVehiclePhotoInterface.wrapperClass wcp = new VMSgetVehiclePhotoInterface.wrapperClass();	
            if(!wc.Error && wc.VMSGUID != null) {
				VMSgetVehiclePhotoInterface runp = new VMSgetVehiclePhotoInterface();
                wcp=runp.getCallout(wc.VMSGUID);      
            }   
            
            // call datahub and get the vehicle recalls
            list<VMSVehicleRecallInterface.wrapperClass> wcr = new list<VMSVehicleRecallInterface.wrapperClass>();	
            if(!wc.Error && wc.VIN != null) {
				VMSVehicleRecallInterface runr = new VMSVehicleRecallInterface();
                wcr=runr.getCallout(wc.VIN);      
            }   
            
            // update vehicle table based on responses from datahub
            if(!wc.Error) {updateVehicleData(wc);}
            if(!wcp.Error) {updateVehiclePHOTO(wcp);}            
            if(!wcr[0].Error) {updateVehicleRecalls(wcr);}    
    		}
        
    	// fetch the data based on VIN
        public  void fetchDataHubVIN(string vin){

            // call datahub and get vehicle details
            VMSgetVehicleInfoInterface.wrapperClass wc = new VMSgetVehicleInfoInterface.wrapperClass();
            VMSgetVehicleInfoInterface run = new VMSgetVehicleInfoInterface();
			wc=run.getCalloutVIN(vin);
            
            // call datahub and get the vehicle photo
            VMSgetVehiclePhotoInterface.wrapperClass wcp = new VMSgetVehiclePhotoInterface.wrapperClass();	
            if(!wc.Error && wc.VMSGUID != null) {
				VMSgetVehiclePhotoInterface runp = new VMSgetVehiclePhotoInterface();
                wcp=runp.getCallout(wc.VMSGUID);      
            }   
            
            // call datahub and get the vehicle recalls
            list<VMSVehicleRecallInterface.wrapperClass> wcr = new list<VMSVehicleRecallInterface.wrapperClass>();	
            if(!wc.Error && wc.VIN != null) {
				VMSVehicleRecallInterface runr = new VMSVehicleRecallInterface();
                wcr=runr.getCallout(wc.VIN);      
            }   
            
            // update vehicle table based on responses from datahub
            if(!wc.Error) {updateVehicleData(wc);}
            if(!wcp.Error) {updateVehiclePHOTO(wcp);}            
            if(!wcr[0].Error) {updateVehicleRecalls(wcr);}    
    		}
    
    
    	// ------------------------------------------------------------------------------------------------------  process responses -----------------------------------------------------------------------------------------------------------------------------------------------------                
    	// check the vehicle table and update the data based on datahub
    	public void updateVehicleData(VMSgetVehicleInfoInterface.wrapperClass datahubData) {
        
            date odoreading = Date.newInstance(1,1,1);
            
            // get any existing vehicle record and update if it exists
            Vehicle__c newVehicle = new Vehicle__c();
            id vehicleID = null;
        	list<Vehicle__c> listVecs = [select id,name,VIN__c,Odometer_Reading_Date__c  from Vehicle__c where Vin__c = :datahubData.VIN];
            if(!listVecs.isEmpty()) { 
                vehicleID = listVecs[0].Id; 
                odoreading = listVecs[0].Odometer_Reading_Date__c; 
            }
            
            // check plate record and add one if it doesnt exist.
        	list<Plate__c> listPlates = [select id,name,Registration_Plate_Number__c from Plate__c where (Registration_Plate_Number__c = :datahubData.Registration)];
            if(!listPlates.isEmpty()) { newVehicle.Registration_Active_Plate__c = listPlates[0].Id; }       
            if(listPlates.isEmpty()) { 
                Plate__c plate = new Plate__c(Registration_Plate_Number__c=datahubData.Registration, Registration_Status__c = 'Active');
    				insert plate;
                	newVehicle.Registration_Active_Plate__c = plate.Id;
            }            

            // map data from datahub to vehicle table.
            newVehicle.ID = vehicleID;
            
            // Core details - check and if different set a message that its been updated.
            if(datahubdata.VIN != null) {newVehicle.VIN__c=datahubData.VIN;  }
            if(datahubdata.FrameID != null) {newVehicle.Chassis_Number__c=datahubData.FrameID; }
            if(datahubdata.DateFirstRegisteredinNZ != null) {newVehicle.Date_First_Registered_in_NZ__c = datahubData.DateFirstRegisteredinNZ;   }         
            if(datahubdata.YearMade != null) {newVehicle.Year_Made__c = datahubData.YearMade;        }            
            if(datahubdata.product != null) {newVehicle.Product_Code__c=datahubData.product; }
            if(datahubdata.subproduct != null) {newVehicle.Product_SubCode__c=datahubData.subproduct;       }
            if(datahubdata.MarqueName != null) {newVehicle.Vehicle_Make__c=datahubData.MarqueName; }
            if(datahubdata.ModelRangeName != null) {newVehicle.Vehicle_Model__c=datahubData.ModelRangeName; }
            if(datahubdata.ModelVariantGroupName != null) {newVehicle.Model_Variant_Group_Name__c=datahubData.ModelVariantGroupName; }
            if(datahubdata.ModelVariantName != null) {newVehicle.Model_Variant_Name__c=datahubData.ModelVariantName; }
            if(datahubdata.ModelCode != null) {newVehicle.Model_Code__c=datahubData.ModelCode;  }
            
            // Dynamic details
            if(datahubdata.ReadingDate != null) {
                if(datahubdata.ReadingDate > odoreading) {
                        if(datahubdata.odometerReading != null) {newVehicle.Odometer_Readings__c = datahubData.odometerReading; }
                        newVehicle.Odometer_Reading_Date__c = datahubData.ReadingDate;               
                }
            }
            
            // Periphial details
            if(datahubdata.VMSGUID != null) {newVehicle.VMS_GUID__c = datahubData.VMSGUID;  }
            if(datahubdata.ManualAutoIndicator != null) {newVehicle.Transmission__c=datahubData.ManualAutoIndicator; }
            if(datahubdata.NumberofGears != null) {newVehicle.Number_of_Gears__c=datahubData.NumberofGears; }
            if(datahubdata.NumberofDoors != null) {newVehicle.Number_of_Doors__c=datahubData.NumberofDoors; }               
            if(datahubdata.NumberofSeats != null) {newVehicle.Number_of_Seats__c=datahubData.NumberofSeats; }
            if(datahubdata.BodyShape != null) {newVehicle.Body_Style__c=datahubData.BodyShape; }            
            if(datahubdata.ColourName != null) {newVehicle.Vehicle_Colours__c=datahubData.ColourName; }            
            if(datahubdata.Fuel != null) {newVehicle.Fuel_Type__c=datahubData.Fuel; }            
            if(datahubdata.EngineCapacity != null) {newVehicle.Engine_Size__c=datahubData.EngineCapacity; }
            if(datahubdata.EngineNumber != null) {newVehicle.Engine_Number__c=datahubData.EngineNumber; }
            if(datahubdata.KeyNumber != null) {newVehicle.Key_Number_Codes__c=datahubData.KeyNumber; }
            if(datahubdata.UnitNumber != null) {newVehicle.Unit_Number__c=datahubData.UnitNumber;  }

            newVehicle.Last_Touch_Point_Date__c=Datetime.now();
            newVehicle.Last_Touch_Point_From__c='VMS';
            upsert newVehicle;
            vID = newVehicle.Id;

    }
    
        
    	// check the vehicle table with the photoo from datahub
    	public void updateVehiclePHOTO(VMSgetVehiclePhotoInterface.wrapperClass pic) {
    
            // get any existing vehicle record and update if it exists
            Vehicle__c newVehicle = new Vehicle__c();
        	list<Vehicle__c> listVecs = [select id,name,VIN__c,thumbId__c from Vehicle__c where Id = :vID];
            for(Vehicle__c vDets: listVecs) {
            
            Attachment newPhoto = new Attachment();
            try {newPhoto.Name = pic.imagetypename + ' - ' + pic.filename; }  catch(Exception e) {}
            if(pic.data != null) {newPhoto.body =  encodingUtil.base64Decode(pic.data);}
            if(pic.format != null) {newPhoto.ContentType=pic.format;}
            newPhoto.ParentId=vID;
                
            list<Attachment> aPhoto = [select id from Attachment where (ParentID=:vID and Name = :newPhoto.Name)];
            if(!aPhoto.isEmpty()) { newPhoto.Id = aPhoto[0].Id; }  
            upsert newPhoto;
                
            If(pic.imagetypename == 'FULL') {vDets.thumbId__c = newPhoto.Id;}
            If(pic.imagetypename == 'Full') {vDets.Full_Photo_ID__c = newPhoto.Id;}                  
     		upsert vDets;              
            }

        }
        
    	// update the recall campaigns table with data from datahub
    	public void updateVehicleRecalls(list<VMSVehicleRecallInterface.wrapperClass> recalls) {

            list<Recall_Campaign__c> newRecalls = new list<Recall_Campaign__c>();
            
            // get any existing recall record and update if it exists
            for(VMSVehicleRecallInterface.wrapperClass recall: recalls) {
            	
                Recall_Campaign__c newRecall = new Recall_Campaign__c();     
                if(recall.campaignprefix != null) {newRecall.Campaign_Prefix__c = recall.campaignprefix;}
                if(recall.campaignreference != null) {newRecall.Campaign_Reference__c = recall.campaignreference;}
                if(recall.campaigndescription != null) {newRecall.Campaign_Description__c = recall.campaigndescription;}
                if(recall.campaignstatus != null) {newRecall.Campaign_Status__c = recall.campaignstatus;}
                if(recall.bulletinlink != null) {newRecall.Bulletin_Link__c = EncodingUtil.urlDecode(recall.bulletinlink, 'UTF-8'); }
                if(recall.bulletingreference != null) {newRecall.Bulletin_Reference__c = recall.bulletingreference;}
                if(recall.campaignstartdate != null) {newRecall.Campaign_Start_Date__c = recall.campaignstartdate;}
                if(recall.cause != null) {newRecall.Cause__c = recall.cause;}
                if(recall.condition != null) {newRecall.Condition__c = recall.condition;}
                if(recall.remedy != null) {newRecall.Remedy__c = recall.remedy;}
                if(recall.coveringletterreference != null) {newRecall.Covering_Letter_Reference__c = recall.coveringletterreference;}
				newRecall.Recall_Vehicle__c = vId;
                
                list<Recall_Campaign__c> rDets = [select id from Recall_Campaign__c where (Recall_Vehicle__c = :vId and Campaign_Prefix__c = :recall.campaignprefix and Campaign_Reference__c = :recall.campaignreference) limit 1];
                    if(!rDets.isEmpty()) {newRecall.Id = rDets[0].Id; }
                
     			newRecalls.add(newRecall);              
            }  
			upsert newRecalls; 
        }
    
}