/*********************************************************************************
Name:          NZPostRESTInteface
Author:         Fujitsu
Purpose:        callout accesses the NZPost API for checking addresses
Created Date:   03/01/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
public class NZPostRESTInteface {

     public NZPost__c NZP = [select Client_Id__c,Client_Secret__c,End_Point_Find__c,End_Point_Details__c from NZPost__c where Name = 'Credentials' limit 1]; 
     public string accessToken;
    
    
    // this method isnt used atm due to this server from nzpost only supports TLS1.0 which is no longer supported by salesforce.
    public string refreshToken() {
        Http h = new Http();
        HttpRequest req = new HttpRequest ();
        req.setEndpoint('https://oauth.nzpost.co.nz/as/token.oauth2 -d ' + '?grant_type=client_credentials&client_id=' + NZP.Client_Id__c + '&client_secret=' + NZP.Client_Secret__c);
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        return res.getHeader('Authorization');
    }

    // ------------------------------------------------------------------------------------------------------ callout methods -----------------------------------------------------------------------------------------------------------------------------------------------------    
   // callout to the nzpost API - passing it an address to get a matching NZPost address.
   public void findCallout(string address1, string address2){
	 integer returnDPID = 0;
       
     HttpRequest req = new HttpRequest();
     address1= EncodingUtil.urlEncode(address1, 'UTF-8');   
     address2= EncodingUtil.urlEncode(address2, 'UTF-8');          
     req.setEndpoint(NZP.End_Point_Find__c + '?client_id=' + NZP.Client_Id__c + '&client_secret=' + NZP.Client_Secret__c + '&address_line_1=' + address1 + '&address_line_2=' + address2);
     req.setMethod('GET');

     	// Specify the required user name and password to access the endpoint
     	// As well as the header and header information
     	accessToken='eyJhbGciOiJIUzI1NiIsImtpZCI6IlRFU1QifQ.eyJjbGllbnRfaWQiOiIwMzU4M2ExODBiYzM0NmQyYWZmMzIzZGQ1NDBlZGYyMSIsImV4cCI6MTQ4NDY3ODI1MCwic2NvcGUiOltdfQ.B6TSjAk8FeIE1KOIbbNnItTUQEYNgeJr8lr755ju6xI';
     	Blob headerValue = Blob.valueOf(accessToken);
     	String authorizationHeader = 'Bearer ' + EncodingUtil.base64Encode(headerValue);
     	req.setHeader('Authorization', authorizationHeader);
     	req.setHeader('Accept', 'application/json');  
     	req.setHeader('Accept-Encoding', 'gzip,deflate');         

       	// Create a new http object to send the request object
      	// A response object is generated as a result of the request  
       	Http http = new Http();
       	HTTPResponse res = http.send(req);
      	 if(res.getStatus() == 'OK') {
     		returnDPID = deserialiseAddress(res.getBody());
             if(returnDPID > 0) {dpidCallout(returnDPID);}
       	}
   }

    
   // callout to the nzpost API - passing it a DPID to get a full address.
   public void dpidCallout(Integer dpid){
       
     HttpRequest req = new HttpRequest();
     req.setEndpoint(NZP.End_Point_Details__c + '?client_id=' + NZP.Client_Id__c + '&client_secret=' + NZP.Client_Secret__c + '&dpid=' + dpid);
     req.setMethod('GET');

     	// Specify the required user name and password to access the endpoint
     	// As well as the header and header information
     	accessToken='eyJhbGciOiJIUzI1NiIsImtpZCI6IlRFU1QifQ.eyJjbGllbnRfaWQiOiIwMzU4M2ExODBiYzM0NmQyYWZmMzIzZGQ1NDBlZGYyMSIsImV4cCI6MTQ4NDY3ODI1MCwic2NvcGUiOltdfQ.B6TSjAk8FeIE1KOIbbNnItTUQEYNgeJr8lr755ju6xI';
     	Blob headerValue = Blob.valueOf(accessToken);
     	String authorizationHeader = 'Bearer ' + EncodingUtil.base64Encode(headerValue);
     	req.setHeader('Authorization', authorizationHeader);
     	req.setHeader('Accept', 'application/json');  
     	req.setHeader('Accept-Encoding', 'gzip,deflate');         

     	// Create a new http object to send the request object
        // A response object is generated as a result of the request  
     	Http http = new Http();
     	HTTPResponse res = http.send(req);
       	if(res.getStatus() == 'OK') {
     		deserialiseDetails(res.getBody());
       }
   }

    // ------------------------------------------------------------------------------------------------------ deserialise methods -----------------------------------------------------------------------------------------------------------------------------------------------------
    // FIND - deserialize the JSON response and determine best matching address if any.
    public static integer deserialiseAddress(string strJSON) {
		integer returnDPID = 0;
        integer matchScore = 0;
        
        // check for any error messages
    	Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(strJSON);
        boolean success = (boolean) m.get('success');
        if(!success) {
            Map<String, Object> error = (Map<String, Object>)m.get('error');
            integer errorCode = (integer) error.get('code');
            string errorMsg = (String) error.get('message');
            system.debug(errorcode + ' - ' + errorMsg);
            return returnDPID;
        }

        // if no errors extract the address
        list<Object> details = (list<object>) m.get('addresses'); 
        if(details != null) {
        if(!details.isEmpty()) {
        for (Object record: details) {
                    Map<String, Object> rec = (Map<String, Object>) record;                             
                    string address1= (String) rec.get('FullAddress');   
            		integer dpid= (Integer) rec.get('DPID');
            		integer mscore= (Integer) rec.get('MatchScore');
            
            		if(mscore > matchScore && mscore > 50) {matchScore = mscore;   returnDPID = dpid;}
                    system.debug(dpid + '   ' + address1 + ' - ' + mscore);
        }}}
        
        return returnDPID;
    }    


    // DPID - deserialize the JSON response and get the full address details using the DPID
    public static void deserialiseDetails(string strJSON) {
            
        // check for any error messages
    	Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(strJSON);
        boolean success = (boolean) m.get('success');
        if(!success) {
            Map<String, Object> error = (Map<String, Object>)m.get('error');
            integer errorCode = (integer) error.get('code');
            string errorMsg = (String) error.get('message');
            system.debug(errorcode + ' - ' + errorMsg);
            return;
        }
        
        // if no errors extract the details
        list<Object> details = (list<object>) m.get('details'); 
        if(details != null) {
        if(!details.isEmpty()) {
        for (Object record: details) {
                    Map<String, Object> rec = (Map<String, Object>) record;                             
                    string address1= (String) rec.get('AddressLine1'); 
            		string address2= (String) rec.get('AddressLine2');   
            		string address3= (String) rec.get('AddressLine3');   
            		string address4= (String) rec.get('AddressLine4');   
            		string address5= (String) rec.get('AddressLine5');   
            		string postcode= (String) rec.get('Postcode');               
            		string SourceDesc= (String) rec.get('SourceDesc');   
            		string Deliverable= (String) rec.get('Deliverable');   
            		string Physical= (String) rec.get('Physical');     
            		string Meshblock= (String) rec.get('Meshblock');                
            		system.debug(address1);
                    system.debug(address2);
                    system.debug(address3);
                    system.debug(address4);
                    system.debug(address5);            
                    system.debug(postcode);  
                    system.debug('type: ' + SourceDesc);
                    system.debug('deliverable: ' + Deliverable);            
                    system.debug('physical address: ' + Physical);       
                    system.debug('meshblock: ' + Meshblock);              
        }}}
            
    }       
    

    
    
}