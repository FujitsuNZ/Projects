/*********************************************************************************
Name:           FacebookIntegration
Author:         Himanshu Verma [Fujitsu]
Purpose:        RestHandler Class to Handler the Response from the Facebook page 
                related to Feed Updates.This will work as a webhook.
Created Date:   16/01/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/


@RestResource(urlMapping='/facebook_webhook')
global class FacebookIntegration
{   
    
    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String bodyString = req.requestBody.toString();
        sendEmails(bodyString);
        if (!String.isBlank(bodyString )){
             FaceBookPostParser parseObj=new FaceBookPostParser(System.JSON.createParser(bodyString));
             Case caseObj= new Case();
             caseObj.Description=parseObj.message;
             caseObj.Origin='Facebook';
             caseObj.Subject=parseObj.sender_name +' '+'Facebook';
             insert caseObj;
        }
             
    }
    
    @HttpGet
    global static integer doValidate(){
        subscribeToPage();
        String retVal = RestContext.request.params.get('hub.challenge');
        return integer.valueOf(retVal);
    }  
    
    /***** Subscription to Facebook Page*******/
    private static boolean subscribeToPage(){
        
        Facebook_Details__c csObj = Facebook_Details__c.getValues('ToyotaDemo');
        string accessToken = csObj.PageAccess_Token__c;
        string pageId = csObj.Facebook_Page_Id__c; 
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://graph.facebook.com/'+pageId+'/subscribed_apps?access_token='+accessToken);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        Http obj= new Http();
        HttpResponse res = obj.send(req);
        return true;
    }
    
    private static void sendEmails(string responsefromsite){
         List<Messaging.SingleEmailMessage> mails =new List<Messaging.SingleEmailMessage>();
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         List<String> sendTo = new List<String>();
         sendTo.add('himanshu.verma@in.fujitsu.com');
         mail.setToAddresses(sendTo);
         mail.setSubject('Facebook Page Response');
         string body = responsefromsite;
         mail.setHtmlBody(body);
         mails.add(mail);
         Messaging.sendEmail(mails);
    
    }
    
   
    
    
}