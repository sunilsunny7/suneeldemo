/**
* @description       : This is a test class for MC_AccessRequestTrigger
which covers MC_AccessRequestTriggerHandler and MC_AccessRequestTriggerDispatcher as well.
* @author            : Mihir Joshi
* @Company           : Capgemini
* @last modified on  : 03-05-2024
* @last modified by  : Mihir Joshi
**/
@isTest
public class MC_AccessRequestTrigger_Test {
    
    @testSetup static void createTestData(){
        
        //Creating Test Data
        Account testAccount = new Account(Name = 'Admin Access Approver');
        insert testAccount;
        
        Contact testContact = new Contact(AccountId = testAccount.id, FirstName = 'Mihir', LastName = 'Joshi', email = 'testuser@test.com',Role__c = 'Administratör');
        insert testContact;
    }
    
    @isTest static void BeforeInsertTest(){
        
        List<MC_Access_Request__c> newAccessRequestList = new List<MC_Access_Request__c>();
        Id conId = [SELECT Id FROM Contact WHERE Name ='Mihir Joshi'].id;
        User user = [SELECT Id FROM User WHERE Name ='Mihir Joshi' AND IsActive !=False LIMIT 1];
        
        System.runAs(user){
            MC_Access_Request__c accessRequest = new MC_Access_Request__c();
            accessRequest.MC_Reason_for_request__c = 'Test_Case';
            accessRequest.MC_Stream__c = 'MC Sales';
            accessRequest.MC_Approver_Name__c = conId;
            insert accessRequest;
        }
        
        String sandboxName = [SELECT MC_Sandbox_Name__c
                              FROM MC_Access_Request__c
                              WHERE MC_Reason_for_request__c ='Test_Case'
                              LIMIT 1].MC_Sandbox_Name__c;
        
        //Verifying if sandbox name is populated or not
        System.assertEquals(FALSE,String.isBlank(sandboxName),'Sandbox Name is not populated');
        
        //Inserting duplicate records
        for(integer i=0; i<50; i++){
            MC_Access_Request__c duplicateAccessRequest = new MC_Access_Request__c();
            duplicateAccessRequest.MC_Reason_for_request__c = 'Test_Case ' + i;
            duplicateAccessRequest.MC_Stream__c = 'MC Sales';
            duplicateAccessRequest.MC_Approver_Name__c = conId;
            newAccessRequestList.add(duplicateAccessRequest);
        }
        
        System.runAs(user){
            if(!newAccessRequestList.isEmpty()){
                try{
                    insert newAccessRequestList;
                }catch(DmlException e){
                    //System.debug('DML Exception BeforeInsertTest => '+e.getMessage());
                    System.assertEquals(TRUE,e.getMessage().contains('Cannot Create Duplicate request since existing request is Open'),'Unexpected Exception Occurred');
                }
            }
        }
    }
    
    @isTest static void BeforeDeleteTest(){
        
        User user = [SELECT Id FROM User WHERE Name ='Mihir Joshi' AND IsActive !=False LIMIT 1];
        Id contactId = [SELECT Id FROM Contact WHERE Name ='Mihir Joshi'].id;
        List<MC_Access_Request__c> newAccessRequestList = new List<MC_Access_Request__c>();
        
        System.runAs(user){
            MC_Access_Request__c accessRequest = new MC_Access_Request__c();
            accessRequest.MC_Reason_for_request__c = 'Test_Case';
            accessRequest.MC_Stream__c = 'MC Sales';
            accessRequest.MC_Approver_Name__c = contactId;
            newAccessRequestList.add(accessRequest);
            
            if(!newAccessRequestList.isEmpty()){
                try{
                    insert newAccessRequestList;
                }catch(DmlException e){
                    //System.debug('Custom Exception @TestSetup => '+e.getMessage());
                }try{
                    delete newAccessRequestList;
                }catch(DmlException e){
                    System.assertEquals(TRUE, e.getMessage().contains('Record Cannot Be Deleted!'), 'Records are being deleted.');
                }
            }   
        }
    }
}