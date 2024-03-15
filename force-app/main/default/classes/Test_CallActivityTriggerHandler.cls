/**
About
-----
Description: Call Activity Test

Update History
--------------
Created September 2016 - V.M

Issues / TODOs
--------------  
*/

@isTest
public with sharing class Test_CallActivityTriggerHandler {
    
    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }
    
    static testMethod void TestHasCampaignContact(){
        System.debug('@@Test test_PR_createFollowUpTask Starts');
        User prUser;
        Account acc;
  //      System.runAs(new User(Id = Userinfo.getUserId())){
          System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            prUser = Test_DataFactory.createPRUser();
            insert prUser;
            acc = Test_DataFactory.createOneAccount();
            acc.OwnerId = prUser.Id;
            insert acc;
        }
        
        System.runAs(prUser){
            
            List<Contact> conList = Test_DataFactory.createContacts(1);
            conList[0].AccountId = acc.Id;
            insert conList;
            
            Campaign camp = Test_DataFactory.createTeliaCampaign();
            insert camp;
            
            Call_Activity__c ca = Test_DataFactory.createCallActivity(camp.Id, acc.Id);
            
            insert ca;
            
            System.assertEquals(ca.Call_Status__c, null);
            
            ca.Call_Status__c = TaskTriggerHandler.STATUS_CONTACTED;
            
            try{
                Database.SaveResult sr = Database.update(ca);
            } catch (Exception e){
                system.assertEquals(e.getTypeName(), 'System.DmlException');
            }
            
            CampaignMember cm = new CampaignMember();
            cm.CampaignId = camp.Id;
            cm.ContactId = conList[0].Id;
            
            insert cm;
            
            Database.SaveResult sr1 = Database.update(ca);
            system.assertEquals(sr1.isSuccess(), true);
        }
    }
    
}