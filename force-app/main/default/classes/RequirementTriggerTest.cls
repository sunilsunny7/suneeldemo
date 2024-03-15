/************
About:
-----
Author: Varma Alluri
Create Date: 29.03.2017
Description: This is the Test class for RequirementTrigger and RequirementTriggerHandler
*************/

@isTest
public class RequirementTriggerTest {
    
    @isTest
    static void RequirementTriggerTestMethod(){

        System.runAs(new User(Id = Userinfo.getUserId())){   
        Solution_Verification__c solver1 = new Solution_Verification__c();   // Test data
        Insert solver1;
        
        Requirement__c req1 = new Requirement__c();
        req1.Related_Solution__c = solver1.id;
        req1.Reference_Solution__c = true;
        req1.Area__c = 'Växel';
        req1.Platform__c = 'Centrex';
        req1.Article_Version_Number__c = 10;
        req1.Article_Title__c = 'Test Article';
        req1.Approval_Decision_Date_Time__c = system.now();
        req1.Approval_Decision_Made_By__c = Userinfo.getUserId();
        req1.Status__c = 'Ej aktuellt';
        req1.Requirement_fullfiled__c = 'Nej';
        Insert req1;  //Test Data
        
        req1.Related_Solution__c = null;   //
        Update req1;                      // run logic
        
        Requirement__c req = [SELECT id,name,Related_Solution__c,Reference_Solution__c,Area__c,Platform__c,Article_Version_Number__c,Article_Title__c,Approval_Decision_Date_Time__c,Approval_Decision_Made_By__c,Status__c,Requirement_fullfiled__c from Requirement__c where id=:req1.id];
        System.assertEquals(req.Area__c, 'Växel');
        System.assertEquals(req.Platform__c, 'Centrex');
        }
    }
}