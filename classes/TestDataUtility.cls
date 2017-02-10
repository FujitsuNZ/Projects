/*********************************************************************************
Name:       TestDataUtility
Author:     Vinay Pathak [Fujitsu]
Purpose:    To create test data. 
Created Date:   09/02/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/

@isTest
public class TestDataUtility{
    
    /******* DECLARATION OF STATIC VARIABLES **********/  
    public static Account testAccountObj;
    public static List<Contact> lstContact;
    public static Case testCaseObj;
    public static User testUserObj;
    public static User testAdminUserCreationObj;
    public static Profile testProfileObj;
    
    /**************************************************
    Method  : Testdata
    Purpose : Constructor
    *****************************************************/
    public TestDataUtility(){}
    
    /**************************************************
    Method  : testAccountCreation
    Purpose : Method to create account data.
    *****************************************************/
    public static void testAccountCreation(){
        if(testAccountObj == null){
            testAccountObj = new Account(name='Test Account', Phone = '123456' , fax = '1234567');
            insert testAccountObj;
            System.assertEquals('Test Account',testAccountObj.Name);
        }
    }
    
    
    /**************************************************
    Method  : testContactCreation
    Purpose : Method to create contact data.
    *****************************************************/
    public static void testContactCreation(){
        testAccountCreation();
        if(lstContact == null){
            lstContact = new List<Contact>();
            lstContact.add(new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = testAccountObj.Id , Phone = '123456' , fax = '1234567', Email = 'test@gmail.com'));
            lstContact.add(new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = testAccountObj.Id , Phone = '123' , fax = '1234567', Email = 'xyzc@gmail.com'));
            insert lstContact;     
            System.assertEquals(2,lstContact.size());
        }
    }
}