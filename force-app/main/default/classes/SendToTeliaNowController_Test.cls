@isTest
public with sharing class SendToTeliaNowController_Test {
    @TestSetup
    static void testSetup() {
        System.runAs(Test_DataFactory.getByPassUser()) {
            Contact oneContactExsisting = Test_DataFactory.createOneContactWithAccount();
            oneContactExsisting.email = 'test3345@test.lt';
            insert oneContactExsisting;
            Case testCaseWithContact = new Case();
            testCaseWithContact.Description = 'Test description';
            testCaseWithContact.Subject = 'Test Case with Contact';
            testCaseWithContact.RecordTypeId = SEUtility.getRecordTypeId('Enterprise');
            testCaseWithContact.contactId = oneContactExsisting.id;
            insert testCaseWithContact;
        }
    }
    @isTest
    static void calloutWithContact() {
        Id caseId = [SELECT Id FROM Case WHERE Subject = 'Test Case with Contact' LIMIT 1].Id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new APIMocks());
        SendToTeliaNowController.startTeliaNowAPI(caseId);
        Test.stopTest();
        Case caseAfterTNOW = [
            SELECT TNOW_Case_Id__c, Last_Modified_in_TNOW__c, TNOW_Status__c, Current_TNOW_Queue_Id__c
            FROM Case
            WHERE Subject = 'Test Case with Contact'
            LIMIT 1
        ];
        Assert.areEqual('CS10000000', caseAfterTNOW.TNOW_Case_Id__c);
        Assert.areEqual(Datetime.valueOf('2023-05-26T11:16:30.000Z'.replace('T', ' ').substringBefore('.')), caseAfterTNOW.Last_Modified_in_TNOW__c);
        Assert.areEqual('New', caseAfterTNOW.TNOW_Status__c);
        Assert.areEqual('d0e37ef6db4adb048877cd4d0b961913', caseAfterTNOW.Current_TNOW_Queue_Id__c);
    }
}