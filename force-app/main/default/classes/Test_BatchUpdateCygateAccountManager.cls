/**
 * Created by esa137 on 2022-12-16.
 */

@IsTest

public class Test_BatchUpdateCygateAccountManager {
    @TestSetup
    static void initTestData(){
        System.runAs(Test_DataFactory.createAdminUser()) {

            User user1 = Test_DataFactory.createCygateUser();
            user1.FirstName = 'Testcygate';
            user1.LastName = 'User';
            insert user1;

            User user2 = Test_DataFactory.createCygateUser();
            user2.FirstName = 'Usercygate';
            user2.LastName = 'Test';
            insert user2;

            Account account1 = Test_DataFactory.createOneCygateAccount();
            account1.Cygate_Account_Manager__c = user1.Id;
            insert account1;

            Contact contact1 = Test_DataFactory.createOneContact();
            contact1.AccountId = account1.Id;
            contact1.LastName = 'Test';
            insert contact1;

            Lead lead1 = Test_DataFactory.createCygateLead();
            lead1.Account__c = account1.Id;
            lead1.LastName = 'Test';
            insert lead1;
        }
    }
    @IsTest
    public static void testBatchUpdateCygateAccountManager() {

        User user1 = [SELECT Id, FirstName,LastName FROM User WHERE FirstName = 'Testcygate'];
        User user2 = [SELECT Id, FirstName,LastName FROM User WHERE FirstName = 'Usercygate'];
        Account account1 = [SELECT Id, Cygate_Account_Manager__c FROM Account];
        Contact contact1 = [SELECT Id, Cygate_account_manager__c FROM Contact WHERE LastName = 'Test'];
        Lead lead1 = [SELECT Id, Cygate_account_manager__c FROM Lead WHERE LastName = 'Test'];

        String fakeManager =  user2.FirstName+ ' ' +user2.LastName;

        lead1.Cygate_account_manager__c = fakeManager;

        update lead1;

        contact1.Cygate_account_manager__c = fakeManager;

        update contact1;

        List<Id> listUpdatedAccounts = new List<Id>{account1.Id};

        Test.startTest();
        BatchUpdateCygateAccountManager batchJob = new BatchUpdateCygateAccountManager(listUpdatedAccounts);
        Database.executeBatch(batchJob, 1);
        Test.stopTest();

        Contact updatedContact = [SELECT Id, Cygate_account_manager__c, AccountId FROM Contact WHERE Id =:contact1.Id];
        Lead updatedLead = [SELECT Id, Cygate_account_manager__c, Account__c FROM Lead WHERE Id = :lead1.Id];

        String cygateAccountManagerName = user1.FirstName + ' ' + user1.LastName;

            System.assertEquals(cygateAccountManagerName, updatedLead.Cygate_account_manager__c, 'Cygate account manager have not been updated for Lead');
            System.assertEquals(cygateAccountManagerName, updatedContact.Cygate_account_manager__c,'Cygate account manager have not been updated for Contact');
    }
}