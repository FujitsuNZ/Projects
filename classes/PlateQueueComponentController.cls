/*********************************************************************************
Name:       PlateQueueComponentController
Author:     Himanshu Verma [Fujitsu]
Purpose:    To Generate The Plate Queue Series from lightning component.Methods
            for handling pagination.
Created Date:   29/12/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public class PlateQueueComponentController{
    
    
    @AuraEnabled
    public integer offst;
      
    @AuraEnabled 
    public List<PlateQueueWrapper> plateQueueData; 
    
    @AuraEnabled 
    public List<Plate_Queue_Batch__c> plateQueueBatchList;       
      
    @AuraEnabled
    public boolean hasprev;
      
    @AuraEnabled
    public boolean hasnext;
    
    @AuraEnabled
    public string exceptionMessage;
    
    @AuraEnabled
    public List<PlateQueue__c> plateQueueRecords;
    
    private static integer pagesize=10;
    private static integer offset;
    
    
    /*Method to Return PlateQueue data on the basis of queueBatchId.*/
    @AuraEnabled 
    public static list<PlateQueue__c>  getPlateQueueData(String plateQueueBatchId){
           
          string query = FieldsUtility.fetchAllFields('PlateQueue__c');
          query +=' where Plate_Queue_Batch__c= \''+plateQueueBatchId+'\'';
          list<PlateQueue__c> plateQueueData =(List<PlateQueue__c>)Database.query(query);
          return plateQueueData;
    }
    
    /*Method to return the plateQueue Batch Records with the Pagination**/
    @AuraEnabled 
    public static PlateQueueComponentController  getPlateQueueBathces(boolean next,boolean prev,decimal off){
           
           offset = (integer)off;
           string query = 'Select Id,Name,Start_Plate__c,Date_Sent__c,Records__c,CreatedBy.Name,CreatedById from Plate_Queue_Batch__c';
           
           integer listlength = [Select count() from Plate_Queue_Batch__c];
           if (next==false && prev==false){
               query += ' ORDER BY CreatedDate DESC LIMIT '+pagesize+' OFFSET '+offset;
           }else if (next==true && (offset+pagesize)<=listlength){
                     offset = offset+pagesize;
                     query += ' ORDER BY CreatedDate DESC LIMIT '+pagesize+' OFFSET '+offset;
           }else if (prev==true && offset>0){
                     offset = offset-pagesize;
                     query += ' ORDER BY CreatedDate DESC LIMIT '+pagesize+' OFFSET '+offset;
           }
            
          
          list<Plate_Queue_Batch__c> plateBatchdata =(List<Plate_Queue_Batch__c>)Database.query(query);
         
          
          PlateQueueComponentController clasObj = new PlateQueueComponentController();
          clasObj.plateQueueBatchList=plateBatchdata; 
          clasObj.offst = offset;
          clasObj.hasprev = hasprev(offset);   
          clasObj.hasnext = hasnxt(offset,listlength,pagesize);
          return clasObj;
          
    }
    
    
    /***Method to Insert the Plate Queue Records on the basis of start Series 
    ****and Number of Records****/
    
    @AuraEnabled
    public static PlateQueueComponentController doInsertPlateSeries(string startChar,
                                               integer numberOfRecords){
                                       
        try{
            string startCharacters= startChar.trim();  
            integer startValue =Integer.valueOf(startCharacters.substring(3,6));
            integer totalReordsToCreate= startValue +Integer.valueOf(numberOfRecords);
            PlateQueueComponentController clasObj = new PlateQueueComponentController();
            List<PlateQueue__c> plateSeries = new List<PlateQueue__c>();
            for (Integer i=startValue;i<totalReordsToCreate;i++){
                    PlateQueue__c  plateQueueObj = new PlateQueue__c();
                    string valuetoReplace ='';
                    if(string.valueof(i).length()==1){
                        valuetoReplace ='00'+i;
                    }
                    if(string.valueof(i).length()==2){
                        valuetoReplace ='0'+i;
                    }
                    if(string.valueof(i).length()==3){
                        valuetoReplace =string.valueof(i);
                    }
                    plateQueueObj.Plate_Number__c= startCharacters.substring(0,3) + valuetoReplace;
                    plateQueueObj.Date_Sent__c= system.today();
                    plateQueueObj.Send_to_NZTA__c=True;     
                    plateSeries.add(plateQueueObj);
            }
            
            if (plateSeries.size()>0){
                  insert plateSeries;
                  Plate_Queue_Batch__c queueBatchObj = new Plate_Queue_Batch__c();
                  queueBatchObj.Records__c=plateSeries.size();
                  queueBatchObj.Date_Sent__c=system.today();
                  queueBatchObj.Start_Plate__c=startCharacters;
                  insert queueBatchObj;
                  List<PlateQueue__c> plateQueueToUpdate = new List<PlateQueue__c>();
                  for (PlateQueue__c plateQueuObj:plateSeries){
                       plateQueuObj.Plate_Queue_Batch__c=queueBatchObj.Id;
                       plateQueueToUpdate.add(plateQueuObj);
                  }
                  if (plateQueueToUpdate.size()>0){
                      update plateQueueToUpdate;
                  
                  }
                  clasObj.exceptionMessage='';
                  clasObj.plateQueueRecords=plateSeries; 
            }
            
            return clasObj;
           
        }catch(exception e){
               PlateQueueComponentController clasObj = new PlateQueueComponentController();
               clasObj.exceptionMessage = e.getMessage();
               return clasObj;
        }                  
    }
    
    private static boolean hasprev(integer off){
            if(off>0)
                return false;
            return true; 
    }
    
    private static boolean hasnxt(integer off,integer li,integer ps){
           if(off+ps<li)
              return false;
           return true;
    } 
    
    
    public class PlateQueueWrapper{
          @AuraEnabled public boolean isSelected;
          @AuraEnabled public PlateQueue__c plateQueueObj ;
          
          public PlateQueueWrapper(PlateQueue__c plateQueueObj){
                 isSelected = false;
                 this.plateQueueObj =plateQueueObj;
          
          }
    
    }   
}