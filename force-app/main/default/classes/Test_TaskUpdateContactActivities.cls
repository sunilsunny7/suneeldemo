/* Author P.P July 2017
* NOTE: This test class uses the @IsTest(SeeAllData=true), as this is required for querying TaskWhoRelations in TaskTriggerHandler by run as User who does not have 'View All Data' True.
* In general, the @IsTest(SeeAllData=true) should never by used, and required data should be created in the test method.
- July 2017 - P.P : SALEF-73 Test Class for TaskTriggerHandler, covers part of UpdateContactActivities
*/

@isTest(SeeAllData = True)
public with sharing class Test_TaskUpdateContactActivities {
    @IsTest
    static void testUpdateContactActivities() {
        User uR1 = new User();
        String roleuR1 = '';
        Account acc = new Account();
        List<Account> accList = new List<Account>();
        Campaign camp = new Campaign();
        Contact conR = new Contact();
        List<Id> conIdList = new List<Id>();
        List<Contact> contactList = new List<Contact>();

        System.runAs(Test_DataFactory.getByPassUser()) {//to avoid MIXED_DML operation
            List<User> renewalUserList = Test_DataFactory.createLargeRenewalUserTeam(1);
            uR1 = renewalUserList[0];
            roleuR1 = uR1.UserRoleId;
        }
        //D.C.
        acc = Test_DataFactory.createOneLargeStandardAccount();
        acc.OwnerId = uR1.Id;
        accList.add(acc);
        insert accList;
        acc = accList[0];

        camp = Test_DataFactory.createCygateCampaign();
        insert camp;
        conR = new Contact(LastName = 'TestLastName', AccountId = acc.Id, FirstName = 'TestFirstName', Phone = '+460345678', Email = 'testR@dummy.com', Role__c = 'Annan');
        contactList.add(conR);
        insert contactList;
        conR = contactList[0];
        conIdList.add(conR.Id);
        List<Task> taskList = Test_DataFactory.createTasks(2);

        Test.startTest();

        System.runAs(uR1) {
            Task tR = taskList[0];
            tR.OwnerId = uR1.Id;
            tR.WhoId = conR.Id;
            insert tR;

            Task tR1 = taskList[1];
            tR1.OwnerId = uR1.Id;
            insert tR1;

            tR1.WhoId = conR.Id;
            update tR1;

            List<Task> tRList = new List<Task>();
            tR.WhoId = null;
            tR1.WhoId = null;
            tRList.add(tR);
            tRList.add(tR1);
            update tRList;
        }
        Test.stopTest();

        List<Contact> conSAList = [SELECT Id, Telia_Activities__c,Cygate_Activities__c,Other_Activities__c,Service_Management_Activities__c,Marketing_Activities__c FROM COntact WHERE Id IN:conIdList];
        for (Contact con : conSAList) {
            if (conR.Id == con.Id) {
                System.assertEquals(con.Other_Activities__c, False);
            }
        }
    }
}