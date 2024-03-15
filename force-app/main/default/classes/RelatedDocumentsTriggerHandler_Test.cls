/**
 * Created by kwn687 on 2023-04-18.
 */
@IsTest
public with sharing class RelatedDocumentsTriggerHandler_Test {
    @TestSetup
    public static void initTestData() {
        Account newAccount;
        User newUser = Test_DataFactory.createCygateUser();
        insert newUser;
        User newUserAdmin = Test_DataFactory.createAdminUser();
        insert newUserAdmin;
        System.runAs(newUserAdmin) {
            newAccount = Test_DataFactory.createOneCygateAccount(newUser.Id);
            newAccount.Cygate_Account_Manager__c = newUser.id;
            insert newAccount;
        }
        System.runAs(newUser) {
            Opportunity newOpportunity = Test_DataFactory.createTeliaCygateOpportunity();
            newOpportunity.Cygate_Amount_for_Approval__c = 100;
            newOpportunity.Cygate_Margin_for_Approval__c = 10;
            newOpportunity.Account = newAccount;
            insert newOpportunity;
            List<Related_Documents__c> allRelatedDocuments = new List<Related_Documents__c>();
            for (Integer i = 0; i < 2; i++) {
                Related_Documents__c oneRelatedDocument = new Related_Documents__c();
                oneRelatedDocument.name = 'TEST' + i;
                oneRelatedDocument.Opportunity__c = newOpportunity.Id;
                allRelatedDocuments.add(oneRelatedDocument);
            }
            insert allRelatedDocuments;
        }
    }
    @IsTest
    public static void testRelatedDocumentOK() {
        Related_Documents__c beforeUpdateRelatedDocument = [SELECT Id, Sent_to_Customer__c FROM Related_Documents__c WHERE Name = 'Test0' LIMIT 1];
        Test.startTest();
        beforeUpdateRelatedDocument.Sent_to_Customer__c = true;
        update beforeUpdateRelatedDocument;
        Test.stopTest();
        Related_Documents__c afterUpdateRelatedDocument = [SELECT Id, Sent_to_Customer__c FROM Related_Documents__c WHERE Name = 'Test0' LIMIT 1];
        assert.areEqual(true, afterUpdateRelatedDocument.Sent_to_Customer__c, 'Related Document failed to update');
    }
    @IsTest
    public static void testRelatedDocumentNotOKonMassUpdate() {
        List<Related_Documents__c> beforeUpdateRelatedDocuments = [SELECT Id, Sent_to_Customer__c FROM Related_Documents__c];
        String error = '';
        Test.startTest();
        for (Related_Documents__c oneRelatedDocument : beforeUpdateRelatedDocuments) {
            oneRelatedDocument.Sent_to_Customer__c = true;
        }
        try {
            update beforeUpdateRelatedDocuments;
        } catch (Exception ex) {
            error = ex.getDmlMessage(0);
        }
        Test.stopTest();
        assert.areEqual(System.Label.Relaterat_dokument_Sent_to_Customer_error, error, 'Related Document not failed to update');
    }
    @IsTest
    public static void testRelatedDocumentNotOKonSingleUpdate() {
        Related_Documents__c relatedDocumentFirst = [SELECT Id, Sent_to_Customer__c FROM Related_Documents__c WHERE Name = 'Test0' LIMIT 1];
        relatedDocumentFirst.Sent_to_Customer__c = true;
        update relatedDocumentFirst;
        String error = '';
        Test.startTest();
        Related_Documents__c relatedDocumentSecond = [SELECT Id, Sent_to_Customer__c FROM Related_Documents__c WHERE Name = 'Test1' LIMIT 1];
        relatedDocumentSecond.Sent_to_Customer__c = true;
        try {
            update relatedDocumentSecond;
        } catch (Exception ex) {
            error = ex.getDmlMessage(0);
        }
        Test.stopTest();
        assert.areEqual(System.Label.Relaterat_dokument_Sent_to_Customer_error, error, 'Related Document not failed to update');
    }
    @IsTest
    public static void testRelatedDocumentCopyFromOpp() {
        Id opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Test.startTest();
        Related_Documents__c oneRelatedDocument = new Related_Documents__c();
        oneRelatedDocument.name = 'TEST for copy data';
        oneRelatedDocument.Opportunity__c = opportunityId;
        insert oneRelatedDocument;
        Test.stopTest();
        Opportunity newestOpportunity = [
            SELECT
                Id,
                Cygate_Account_Manager__c,
                Account.Cygate_Account_Manager__r.Email,
                Account.Cygate_Account_Manager__r.MobilePhone,
                Account.Cygate_Account_Manager__r.Phone,
                Owner.FirstName,
                Owner.LastName,
                OrganisationalUnit__r.Order_Account_Id__c,
                Name,
                Opportunity_id__c
            FROM Opportunity
        ];
        Related_Documents__c afterUpdateRelatedDocuments = [
            SELECT
                Id,
                Conga_Cygate_Account_Manager_Name__c,
                Conga_Cygate_Account_Manager_Email__c,
                Conga_Cygate_Account_Manager_Mobile__c,
                Conga_Cygate_Account_Manager_Phone__c,
                Conga_Opportunity_Owner_Name__c,
                Conga_Opp_Account__c,
                Opportunity_Name__c,
                Opportunity_no__c
            FROM Related_Documents__c
            WHERE Name = 'TEST for copy data'
        ];
        assert.areEqual(newestOpportunity.Cygate_Account_Manager__c, afterUpdateRelatedDocuments.Conga_Cygate_Account_Manager_Name__c);
        assert.areEqual(newestOpportunity.Account.Cygate_Account_Manager__r.Email, afterUpdateRelatedDocuments.Conga_Cygate_Account_Manager_Email__c);
        assert.areEqual(newestOpportunity.Account.Cygate_Account_Manager__r.MobilePhone, afterUpdateRelatedDocuments.Conga_Cygate_Account_Manager_Mobile__c);
        assert.areEqual(newestOpportunity.Account.Cygate_Account_Manager__r.Phone, afterUpdateRelatedDocuments.Conga_Cygate_Account_Manager_Phone__c);
        assert.areEqual(
            newestOpportunity.Owner.FirstName + ' ' + newestOpportunity.Owner.LastName,
            afterUpdateRelatedDocuments.Conga_Opportunity_Owner_Name__c
        );
        assert.areEqual(newestOpportunity.OrganisationalUnit__r.Order_Account_Id__c, afterUpdateRelatedDocuments.Conga_Opp_Account__c);
        assert.areEqual(newestOpportunity.Name, afterUpdateRelatedDocuments.Opportunity_Name__c);
        assert.areEqual(newestOpportunity.Opportunity_id__c, afterUpdateRelatedDocuments.Opportunity_no__c);
    }
}