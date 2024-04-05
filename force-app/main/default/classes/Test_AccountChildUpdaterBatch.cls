//LTAT-18596: AccountTriggerHandler to fix the issue to handle child accounts, test class for AccountChildUpdaterBatch 
@isTest
public class Test_AccountChildUpdaterBatch {

    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }

    @isTest
    static void testAccountChildUpdaterBatch() {
        List<User> largeUserTeam = Test_DataFactory.createLargeUserTeam(4);
        User largeUser = largeUserTeam[0];
        User largeUser1 = largeUserTeam[1];
        User largeUser2 = largeUserTeam[2];
        User largeUser3 = largeUserTeam[3];

        Account childAccount; 

        System.runAs(Test_DataFactory.getByPassUser()) {
            Account parentAccount = Test_DataFactory.createOneKundkontoAccount();
            parentAccount.Telia_Service_Manager__c = largeUser3.Id;
            parentAccount.LifeCycle_Manager__c = largeUser2.Id;
            parentAccount.Change_Manager__c = largeUser1.Id;
            insert parentAccount;

            childAccount = Test_DataFactory.createOneLargeStandardAccount();
            childAccount.OwnerId = largeUser.Id;
            childAccount.parentID = parentAccount.Id;
            insert childAccount;

            Map<Id, Account> updatedAccMap = new Map<Id, Account>{ parentAccount.Id => parentAccount };
            
            AccountChildUpdaterBatch batchInstance = new AccountChildUpdaterBatch(new List<Id>{parentAccount.Id}, updatedAccMap);
            Test.startTest();
            Database.executeBatch(batchInstance);
            Test.stopTest();

            Account updatedChildAccount = [SELECT Id, Telia_Service_Manager__c, LifeCycle_Manager__c, Change_Manager__c, ParentId 
                                          FROM Account WHERE Id = :childAccount.Id];
            System.assertEquals(largeUser3.Id, updatedChildAccount.Telia_Service_Manager__c, 'Telia_Service_Manager__c not updated correctly');
            System.assertEquals(largeUser2.Id, updatedChildAccount.LifeCycle_Manager__c, 'LifeCycle_Manager__c not updated correctly');
            System.assertEquals(largeUser1.Id, updatedChildAccount.Change_Manager__c, 'Change_Manager__c not updated correctly');
        }
    }
}