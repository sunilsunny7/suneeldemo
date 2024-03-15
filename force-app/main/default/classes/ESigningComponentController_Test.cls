/**
 * Created by uly8476 on 2021-12-09.
 */

@IsTest
private class ESigningComponentController_Test {
    @TestSetup
    static void testSetup() {
        System.runAs(Test_DataFactory.getByPassUser()) {
            List<Account> testAccounts = Test_DataFactory.createAccounts(2);
            insert testAccounts;
            List<Contact> testContacts = Test_DataFactory.createContacts(4);
            for (Contact contact : testContacts) {
                contact.AccountId = testAccounts[0].Id;
            }
            insert testContacts;
            AccountContactRelation accContactRelation = new AccountContactRelation();
            accContactRelation.E_Signing_Role__c = 'Signer';
            accContactRelation.AccountId = testAccounts[1].Id;
            accContactRelation.ContactId = testContacts[1].Id;
            insert accContactRelation;
        }
        List<Opportunity> testOpportunities = Test_DataFactory.createOpportunities(1);
        insert testOpportunities;
        Contact contactOnOtherAcc = Test_DataFactory.createOneContactWithAccount();
        insert contactOnOtherAcc;

        OpportunityContactRole oppContactRole = Test_DataFactory.createOpportunityContactRole();
        oppContactRole.Role = 'Avtalstecknare';
        oppContactRole.OpportunityId = testOpportunities[0].Id;
        oppContactRole.ContactId = contactOnOtherAcc.Id;
        insert oppContactRole;

        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for (Integer i = 0; i <= 1; i++){
            ContentVersion contentVersion = new ContentVersion(
                    Title='Test Document ' + i,
                    PathOnClient='document_'+ i + '.pdf',
                    VersionData= Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
            contentVersions.add(contentVersion);
        }
        insert contentVersions;

        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        for(ContentDocument doc : documents){
            ContentDocumentLink cdl = new ContentDocumentLink(
                    LinkedEntityId = testOpportunities[0].Id,
                    ContentDocumentId = doc.Id,
                    ShareType = 'V',
                    Visibility = 'AllUsers');
            cdls.add(cdl);
        }
        insert cdls;
    }
    @IsTest
    static void retrieveOpportunityContacts_Test() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        List<Contact> relatedContactsList = ESigningComponentController.retrieveContacts(opp.Id, 'Opportunity');
        Test.stopTest();

        System.assertEquals(1,relatedContactsList.size());
    }
    @IsTest
    static void retrieveAccountContacts_Test() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount1' LIMIT 1];

        Test.startTest();
        List<Contact> relatedContactsList = ESigningComponentController.retrieveContacts(acc.Id, 'Account');
        Test.stopTest();

        System.assertEquals(1,relatedContactsList.size());
    }

    @IsTest
    static void createScriveDocument_Test() {
        List<Id> contactIds = new List<Id>();
        for(Contact contact : [SELECT Id FROM Contact]){
            contactIds.add(contact.Id);
        }
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity];
        List<ContentVersion> contentVersions = [SELECT Id, Title, VersionData, ContentDocumentId FROM ContentVersion];
        List<ESigningComponentController.DocumentObject> documentsObjectsList = new List<ESigningComponentController.DocumentObject>();
        ESigningComponentController.DocumentObject documentObject = new ESigningComponentController.DocumentObject();

        documentObject.name = contentVersions[0].Title;
        documentObject.documentId = contentVersions[0].ContentDocumentId;
        documentObject.selected = true;
        documentObject.document = contentVersions[0];
        documentsObjectsList.add(documentObject);

        Test.startTest();
        Boolean scriveDocCreated = ESigningComponentController.createScriveDocument(documentsObjectsList,opportunities[0].Id,contactIds);
        Test.stopTest();

        system.assertEquals(true,scriveDocCreated);
    }
    @IsTest
    static void updateAttachedFiles_Test() {
        List<ContentVersion> contentVersions = [SELECT Id, Title, VersionData, ContentDocumentId FROM ContentVersion];
        List<ESigningComponentController.DocumentObject> documentsObjectsList = new List<ESigningComponentController.DocumentObject>();
        ESigningComponentController.DocumentObject documentObject = new ESigningComponentController.DocumentObject();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        documentObject.name = contentVersions[0].Title;
        documentObject.documentId = contentVersions[0].ContentDocumentId;
        documentObject.selected = true;
        documentObject.document = contentVersions[0];
        documentsObjectsList.add(documentObject);

        Test.startTest();
        ESigningComponentController.updateAttachedFiles(documentsObjectsList,opp.Id,'ACE',System.today(),System.today()+30,'1234567','','Antal','test');
        Test.stopTest();

        List<ContentVersion> updatedContentVersions = [SELECT Id, TeliaSE_MC_Start_Date__c, TeliaSE_MC_End_Date__c, TeliaSE_MC_Agreement_Number__c, TeliaSE_MC_ReplaceAgreement__c, TeliaSE_MC_DocumentType__c, TeliaSE_MC_Note__c, TeliaSE_MC_Product__c FROM ContentVersion WHERE ContentDocumentId = :contentVersions[0].ContentDocumentId];

        System.assertEquals('Antal',updatedContentVersions[0].TeliaSE_MC_DocumentType__c);
        System.assertEquals('ACE',updatedContentVersions[0].TeliaSE_MC_Product__c);
    }
    @IsTest
    static void getProductPicklistValues_Test(){
        eSigningComponentValues__c newValue = new eSigningComponentValues__c();
        newValue.Name = 'customsetting';
        newValue.API_name__c = 'customsetting';
        insert newValue;

        Test.startTest();
        List<ESigningComponentController.SigningComponentValue> picklistValues = ESigningComponentController.getProductPicklistValues();
        Test.stopTest();

        System.assert(!picklistValues.isEmpty());
    }
    @IsTest
    static void updateScriveDocumentFields_Test() {
        List<ContentVersion> contentVersions = [SELECT Id, Title, VersionData, ContentDocumentId, TeliaSE_MC_DocumentType__c, TeliaSE_MC_Product__c FROM ContentVersion];
        List<ESigningComponentController.DocumentObject> documentsObjectsList = new List<ESigningComponentController.DocumentObject>();
        ESigningComponentController.DocumentObject documentObject = new ESigningComponentController.DocumentObject();
        contentVersions[0].TeliaSE_MC_Product__c = 'ACE';
        contentVersions[0].TeliaSE_MC_DocumentType__c = 'Avtal';
        update contentVersions[0];

        documentObject.name = contentVersions[0].Title;
        documentObject.documentId = contentVersions[0].ContentDocumentId;
        documentObject.selected = true;
        documentObject.document = contentVersions[0];

        documentsObjectsList.add(documentObject);

        scrive__ScriveDocument__c scriveDocument = new scrive__ScriveDocument__c(
               Name = 'Test Scrive Document'
        );
        insert scriveDocument;

        scrive__ScriveDocument__c insertedScriveDocument = [SELECT Id, Name FROM scrive__ScriveDocument__c WHERE Name = 'Test Scrive Document'];

        Test.startTest();
        ESigningComponentController.updateScriveDocumentFields(insertedScriveDocument.Id, documentsObjectsList);
        Test.stopTest();

        scrive__ScriveDocument__c updatedScriveDoc = [SELECT Id, TeliaSE_MC_DocumentType__c, TeliaSE_MC_Product__c FROM scrive__ScriveDocument__c WHERE Id = :insertedScriveDocument.Id LIMIT 1];

        System.assertEquals('ACE', updatedScriveDoc.TeliaSE_MC_Product__c);
        System.assertEquals('Avtal', updatedScriveDoc.TeliaSE_MC_DocumentType__c);
    }
}