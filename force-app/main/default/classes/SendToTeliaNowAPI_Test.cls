@isTest
public with sharing class SendToTeliaNowAPI_Test {
    @TestSetup
    static void testSetup() {
        System.runAs(Test_DataFactory.getByPassUser()) {
            List<Contact> newContacts = new List<Contact>();
            Contact oneContactExsisting = Test_DataFactory.createOneContactWithAccount();
            oneContactExsisting.email = 'test3345@test.lt';
            newContacts.add(oneContactExsisting);
            Contact oneContactNew = Test_DataFactory.createOneContactWithAccount();
            oneContactNew.email = 'test.empty@test.lt';
            newContacts.add(oneContactNew);
            Contact oneContacError = Test_DataFactory.createOneContactWithAccount();
            oneContacError.email = 'error.error@error.error';
            newContacts.add(oneContacError);
            insert newContacts;
            List<Case> newCases = new List<Case>();
            Case testCaseWithoutContact = new Case();
            testCaseWithoutContact.Description = 'Test description';
            testCaseWithoutContact.Subject = 'Test Case without Contact';
            testCaseWithoutContact.RecordTypeId = SEUtility.getRecordTypeId('Enterprise');
            newCases.add(testCaseWithoutContact);
            Case testCaseWithContact = new Case();
            testCaseWithContact.Description = 'Test description';
            testCaseWithContact.Subject = 'Test Case with Contact';
            testCaseWithContact.RecordTypeId = SEUtility.getRecordTypeId('Enterprise');
            testCaseWithContact.contactId = oneContactExsisting.id;
            newCases.add(testCaseWithContact);
            Case testCaseWithNewContact = new Case();
            testCaseWithNewContact.Description = 'Test description';
            testCaseWithNewContact.Subject = 'Test Case with New Contact';
            testCaseWithNewContact.RecordTypeId = SEUtility.getRecordTypeId('Enterprise');
            testCaseWithNewContact.contactId = oneContactNew.id;
            newCases.add(testCaseWithNewContact);
            Case testCaseWithErrorContact = new Case();
            testCaseWithErrorContact.Description = 'Test description';
            testCaseWithErrorContact.Subject = 'Test Case with Error Contact';
            testCaseWithErrorContact.RecordTypeId = SEUtility.getRecordTypeId('Enterprise');
            testCaseWithErrorContact.contactId = oneContacError.id;
            newCases.add(testCaseWithErrorContact);
            insert newCases;
            ContentVersion cv = new ContentVersion(
                Title = 'Test Document',
                PathOnClient = 'TestDocument.txt',
                VersionData = Blob.valueOf('This is a test document')
            );
            insert cv;
            cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = cv.ContentDocumentId,
                LinkedEntityId = testCaseWithContact.Id,
                ShareType = 'V'
            );
            insert cdl;
        }
    }
    @isTest
    static void calloutWithoutContact() {
        Id caseId = [SELECT Id FROM Case WHERE Subject = 'Test Case without Contact' LIMIT 1].Id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new APIMocks());
        SendToTeliaNowAPI.teliaNowAPIConnection(caseId);
        Test.stopTest();
        Case caseAfterTNOW = [
            SELECT TNOW_Case_Id__c, Last_Modified_in_TNOW__c, TNOW_Status__c, Current_TNOW_Queue_Id__c
            FROM Case
            WHERE Subject = 'Test Case without Contact'
            LIMIT 1
        ];
        Assert.areEqual('CS10000000', caseAfterTNOW.TNOW_Case_Id__c);
        Assert.areEqual(Datetime.valueOf('2023-05-26T11:16:30.000Z'.replace('T', ' ').substringBefore('.')), caseAfterTNOW.Last_Modified_in_TNOW__c);
        Assert.areEqual('New', caseAfterTNOW.TNOW_Status__c);
        Assert.areEqual('d0e37ef6db4adb048877cd4d0b961913', caseAfterTNOW.Current_TNOW_Queue_Id__c);
    }
    @isTest
    static void calloutWithContact() {
        Id caseId = [SELECT Id FROM Case WHERE Subject = 'Test Case with Contact' LIMIT 1].Id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new APIMocks());
        SendToTeliaNowAPI.teliaNowAPIConnection(caseId);
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
    @isTest
    static void calloutWithNewContact() {
        Id caseId = [SELECT Id FROM Case WHERE Subject = 'Test Case with New Contact' LIMIT 1].Id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new APIMocks());
        SendToTeliaNowAPI.teliaNowAPIConnection(caseId);
        Test.stopTest();
        Case caseAfterTNOW = [
            SELECT TNOW_Case_Id__c, Last_Modified_in_TNOW__c, TNOW_Status__c, Current_TNOW_Queue_Id__c
            FROM Case
            WHERE Subject = 'Test Case with New Contact'
            LIMIT 1
        ];
        Assert.areEqual('CS10000000', caseAfterTNOW.TNOW_Case_Id__c);
        Assert.areEqual(Datetime.valueOf('2023-05-26T11:16:30.000Z'.replace('T', ' ').substringBefore('.')), caseAfterTNOW.Last_Modified_in_TNOW__c);
        Assert.areEqual('New', caseAfterTNOW.TNOW_Status__c);
        Assert.areEqual('d0e37ef6db4adb048877cd4d0b961913', caseAfterTNOW.Current_TNOW_Queue_Id__c);
    }
    @isTest
    static void calloutWithErrorContact() {
        String errorText = '';
        Id caseId = [SELECT Id FROM Case WHERE Subject = 'Test Case with Error Contact' LIMIT 1].Id;
        Test.setMock(HttpCalloutMock.class, new APIMocks());
        Test.startTest();
        try {
            SendToTeliaNowAPI.teliaNowAPIConnection(caseId);
            Assert.isTrue(false, 'Should have thrown an exception');
        } catch (Exception e) {
            system.debug(e.getMessage());
            errorText = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual('Script-thrown exception', errorText);
    }
}