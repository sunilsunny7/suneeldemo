/**
 * Created by kwn687 on 2022-03-07.
 */
@IsTest
public with sharing class Test_MassDeleteDocumentsController {
    @TestSetup
    static void setup()
    {

        Opportunity opp= new Opportunity();
        opp = Test_DataFactory.createOpportunity();
        opp.StageName='01 Prospect';
        opp.Revenue_NS__c=0;
        opp.Revenue_CS__c=0;
        insert opp;
        Related_Documents__c newRelatedDocuments = new Related_Documents__c(
                name = 'test1',
                Opportunity__c = opp.id,
                Document_Link__c = 'TEST'
        );
        insert newRelatedDocuments;

    }
    @IsTest
    static void testRelatedDocumentsGet()
    {
        id oppId = [SELECT Id FROM Opportunity LIMIT 1].id;
        Test.startTest();
        List<Related_Documents__c> relatedDocuments = MassDeleteDocumentsController.retrieveRelatedDocuments(oppId);
        Test.stopTest();
        system.assertEquals(1, relatedDocuments.size(), 'No Related Documents was got');
    }
    @IsTest
    static void testRelatedDocumentsDelete()
    {
        List<Related_Documents__c> relatedDocuments = [SELECT Id FROM Related_Documents__c];
        Test.startTest();
        List<id> releatedDocumentIds = New List<Id>();
        for (Related_Documents__c relatedDocument : relatedDocuments)
        {
            releatedDocumentIds.add(relatedDocument.id);
        }
        MassDeleteDocumentsController.deleteUndeleteRelatedDocuments(releatedDocumentIds,true);
        Test.stopTest();
        List<Related_Documents__c> relatedDocumentIds = [SELECT Id FROM Related_Documents__c];
        system.assertEquals(0, relatedDocumentIds.size(), 'Wasn\'t able to delete Related documents');
    }
    @IsTest
    static void testDeletedRelatedDocuments()
    {
        List<Related_Documents__c> relatedDocuments = [SELECT Id FROM Related_Documents__c];
        id oppId = [SELECT Id FROM Opportunity LIMIT 1].id;
        Test.startTest();
        Delete relatedDocuments;
        List<Related_Documents__c> deletedDocuments = MassDeleteDocumentsController.retrieveDeletedRelatedDocuments(oppId);
        Test.stopTest();
        system.assertEquals(1, deletedDocuments.size(), 'No deleted Related Documents was got');
    }

}