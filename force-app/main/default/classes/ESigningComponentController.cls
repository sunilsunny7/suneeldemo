/**
 * Created by uly8476 on 2021-11-23.
 */

public with sharing class ESigningComponentController {
    @AuraEnabled
    public static List<Contact> retrieveContacts(Id recordId, String objectApiName) {
        List<Contact> contactsList = new List<Contact>();
        if (objectApiName == 'Opportunity') {
            for (OpportunityContactRole oppContactRole : [SELECT ContactId, Contact.Name, Contact.MobilePhone, Contact.Email FROM OpportunityContactRole WHERE OpportunityId = :recordId AND Role = 'Avtalstecknare']) {
                contactsList.add(oppContactRole.Contact);
            }
        } else if (objectApiName == 'Account') {
            for (AccountContactRelation accContactRole : [SELECT ContactId, Contact.Name, Contact.MobilePhone, Contact.Email FROM AccountContactRelation WHERE AccountId = :recordId AND E_Signing_Role__c = 'Signer']) {
                contactsList.add(accContactRole.Contact);
            }
        }
        return contactsList;
    }

    @AuraEnabled
    public static Boolean createScriveDocument(List<DocumentObject> attachedDocuments, Id recordId, List<Id>selectedContactIds) {
        Map<Id, DocumentObject> documentMap = new Map<Id, DocumentObject>();
        Set<Id> documentIds = new Set<Id>();

        for (DocumentObject documentObject : attachedDocuments){
            documentIds.add(documentObject.documentId);
            documentMap.put(documentObject.documentId, documentObject);
        }

        List<ContentVersion> contentVersions = [SELECT Id, Title, VersionData, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :documentIds];
        for (ContentVersion contentVersion : contentVersions) {
            DocumentObject documentObject = documentMap.get(contentVersion.ContentDocumentId);
            if (documentObject != null) {
                documentObject.document = contentVersion;
                documentMap.put(documentObject.documentId, documentObject);
            }
        }
        //Creates Scrive document instance
        scrive.ScriveDocumentGlobal scriveDocument = new scrive.ScriveDocumentGlobal();
        //Set Swedish language
        scriveDocument.language = 'sv';
        //Links related record
        scriveDocument.addRelatedObject(recordId);
        //Update current user to viewer
        scrive.ScriveDocumentGlobal.Party currentParty = scriveDocument.getPartyByRecordId(UserInfo.getUserId());
        if (currentParty != null){
            currentParty.signs = false;
        }
        //Adds selected contacts as a signing parties
        for (Integer i = 0; i < selectedContactIds.size(); i++){
            scriveDocument.addParty(selectedContactIds[i],2+i);
            scrive.ScriveDocumentGlobal.Party party = scriveDocument.getPartyByRecordId(selectedContactIds[i]);
            if (party != null){
                party.authenticationToSign = scrive.ScriveDocumentGlobal.AuthToSign.SWEDISH_BANKID;
            }
        }
        //Sets selected attached file as main file for Scrive Document and adds other files as attachments of Scrive Document
        for(DocumentObject documentObject : documentMap.values()){
            if (documentObject.selected){
                scriveDocument.setMainDocument(documentObject.document.Title,documentObject.document.VersionData);
            } else {
                scriveDocument.addAttachment(documentObject.document.Title, documentObject.document.VersionData);
            }
        }

        //Creates draft Scrive Document in SF, but doesn't send for signing
        try {
            scriveDocument.save();
        } catch (Exception ex) {
            if (!Test.isRunningTest()){
                System.debug('Exception occurred: '+ ex.getMessage());
            }
        }

        return true;
    }

    @AuraEnabled
    public static void updateAttachedFiles(List<DocumentObject> attachedDocuments, Id recordId, String product, Date startDate, Date endDate, String agreementNumber, String replaceAgreement, String documentType, String note) {
        Set<Id> documentIds = new Set<Id>();

        for (DocumentObject documentObject : attachedDocuments){
            documentIds.add(documentObject.documentId);
        }

        List<ContentVersion> attachedDocumentsList = [SELECT Id, TeliaSE_MC_Start_Date__c, TeliaSE_MC_End_Date__c, TeliaSE_MC_Agreement_Number__c, TeliaSE_MC_ReplaceAgreement__c, TeliaSE_MC_DocumentType__c, TeliaSE_MC_Note__c, TeliaSE_MC_Product__c, TeliaSE_MC_ExternalDataSourceId__c FROM ContentVersion WHERE ContentDocumentId IN :documentIds];
        for (ContentVersion cv : attachedDocumentsList) {
            cv.TeliaSE_MC_ExternalDataSourceId__c = recordId;
            cv.TeliaSE_MC_Product__c = product;
            cv.TeliaSE_MC_Note__c = note;
            cv.TeliaSE_MC_DocumentType__c = documentType;
            cv.TeliaSE_MC_Agreement_Number__c = agreementNumber;
            cv.TeliaSE_MC_ReplaceAgreement__c = replaceAgreement;
            cv.TeliaSE_MC_Start_Date__c = startDate;
            cv.TeliaSE_MC_End_Date__c = endDate;
        }

        update attachedDocumentsList;
    }

    @AuraEnabled
    public static String retrieveScriveDocumentId(String recordId){
        //Retrieves latest Scrive Document
        List<scrive__ScriveDocument__c> scriveDocs = [SELECT Id, CreatedDate FROM scrive__ScriveDocument__c WHERE scrive__opportunity__c= :recordId OR scrive__account__c = :recordId ORDER BY CreatedDate DESC];
        return String.valueOf(scriveDocs[0].Id);
    }

    @AuraEnabled(cacheable=true)
    public static List<SigningComponentValue> getProductPicklistValues() {
        List<eSigningComponentValues__c> values = eSigningComponentValues__c.getAll().values();
        values.sort();

        List<SigningComponentValue> eSigningComponentValuesList = new List<SigningComponentValue>();
        for (eSigningComponentValues__c value : values) {
            SigningComponentValue picklistValue = new SigningComponentValue();
            picklistValue.label = value.Name;
            picklistValue.value = value.API_name__c;
            eSigningComponentValuesList.add(picklistValue);
        }
        //Adds 'Other' value at the bottom of the Products list
        SigningComponentValue otherValue = new SigningComponentValue();
        otherValue.label = 'Other';
        otherValue.value = 'other';
        eSigningComponentValuesList.add(otherValue);
        return eSigningComponentValuesList;
    }

    @AuraEnabled
    public static void updateScriveDocumentFields(String scriveDocumentId, List<DocumentObject> attachedDocuments) {
        Id mainDocumentId;

        for (DocumentObject documentObject : attachedDocuments){
            if (documentObject.selected = true) {
                mainDocumentId = documentObject.documentId;
            }
        }
        if (mainDocumentId != null) {
            List<scrive__ScriveDocument__c> scriveDoc = [SELECT Id, TeliaSE_MC_Start_Date__c, TeliaSE_MC_End_Date__c, TeliaSE_MC_Product__c, TeliaSE_MC_ContentVersion_Id__c, TeliaSE_MC_ReplaceAgreement__c, TeliaSE_MC_DocumentType__c, TeliaSE_MC_Note__c, TelisSE_MC_Agreement_Number__c FROM scrive__ScriveDocument__c WHERE Id = :scriveDocumentId LIMIT 1];
            ContentVersion mainAttachedFile = [SELECT Id, TeliaSE_MC_Start_Date__c, TeliaSE_MC_End_Date__c, TeliaSE_MC_Agreement_Number__c, TeliaSE_MC_ReplaceAgreement__c, TeliaSE_MC_DocumentType__c, TeliaSE_MC_Note__c, TeliaSE_MC_Product__c, TeliaSE_MC_ExternalDataSourceId__c FROM ContentVersion WHERE ContentDocumentId= :mainDocumentId];
            if (!scriveDoc.isEmpty()) {
                scriveDoc[0].TeliaSE_MC_Start_Date__c = scriveDoc[0].TeliaSE_MC_Start_Date__c != mainAttachedFile.TeliaSE_MC_Start_Date__c ? mainAttachedFile.TeliaSE_MC_Start_Date__c : scriveDoc[0].TeliaSE_MC_Start_Date__c;
                scriveDoc[0].TeliaSE_MC_End_Date__c = scriveDoc[0].TeliaSE_MC_End_Date__c != mainAttachedFile.TeliaSE_MC_End_Date__c ? mainAttachedFile.TeliaSE_MC_End_Date__c : scriveDoc[0].TeliaSE_MC_End_Date__c;
                scriveDoc[0].TeliaSE_MC_Product__c = scriveDoc[0].TeliaSE_MC_Product__c != mainAttachedFile.TeliaSE_MC_Product__c ? mainAttachedFile.TeliaSE_MC_Product__c : scriveDoc[0].TeliaSE_MC_Product__c;
                scriveDoc[0].TeliaSE_MC_ContentVersion_Id__c = scriveDoc[0].TeliaSE_MC_ContentVersion_Id__c != mainAttachedFile.Id ? mainAttachedFile.Id : scriveDoc[0].TeliaSE_MC_ContentVersion_Id__c;
                scriveDoc[0].TelisSE_MC_Agreement_Number__c = scriveDoc[0].TelisSE_MC_Agreement_Number__c != mainAttachedFile.TeliaSE_MC_Agreement_Number__c ? mainAttachedFile.TeliaSE_MC_Agreement_Number__c : scriveDoc[0].TelisSE_MC_Agreement_Number__c;
                scriveDoc[0].TeliaSE_MC_ReplaceAgreement__c = scriveDoc[0].TeliaSE_MC_ReplaceAgreement__c != mainAttachedFile.TeliaSE_MC_ReplaceAgreement__c ? mainAttachedFile.TeliaSE_MC_ReplaceAgreement__c : scriveDoc[0].TeliaSE_MC_ReplaceAgreement__c;
                scriveDoc[0].TeliaSE_MC_DocumentType__c = scriveDoc[0].TeliaSE_MC_DocumentType__c != mainAttachedFile.TeliaSE_MC_DocumentType__c ? mainAttachedFile.TeliaSE_MC_DocumentType__c : scriveDoc[0].TeliaSE_MC_DocumentType__c;
                scriveDoc[0].TeliaSE_MC_Note__c = scriveDoc[0].TeliaSE_MC_Note__c != mainAttachedFile.TeliaSE_MC_Note__c ? mainAttachedFile.TeliaSE_MC_Note__c : scriveDoc[0].TeliaSE_MC_Note__c;

                try {
                    update scriveDoc;
                } catch(DmlException ex) {
                    System.debug('The following exception has occured: ' + ex.getMessage());
                }
            }
        }
    }

    public class DocumentObject {
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String documentId { get; set; }
        @AuraEnabled
        public Boolean selected { get; set; }
        @AuraEnabled
        public ContentVersion document { get; set; }
    }

    public class SigningComponentValue {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
    }
}