/**
 * Created by uly8476 on 2023-03-02.
 */

public with sharing class attachedFilesComponentController {
    @AuraEnabled(cacheable=true)
    public static Id getRelatedRecordId(Id recordId, String objectApiName) {
        if (objectApiName == 'ProcessInstanceStep') {
            List<ProcessInstanceStep> processInstanceSteps = [SELECT ProcessInstance.TargetObjectId FROM ProcessInstanceStep WHERE Id = :recordId LIMIT 1];
            return processInstanceSteps[0].ProcessInstance.TargetObjectId;
        } else if (objectApiName == 'ProcessInstanceWorkitem') {
            List<ProcessInstanceWorkitem> processInstanceWorkitems = [SELECT ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE Id = :recordId LIMIT 1];
            return processInstanceWorkitems[0].ProcessInstance.TargetObjectId;
        }
        return null;
    }

    @AuraEnabled
    public static void updateAttachedFiles(List<Id> contentVersionIds) {
        List<ContentVersion> attachedFiles = [SELECT Id, Attached_From_Approval__c FROM ContentVersion WHERE Id IN: contentVersionIds];
        for (ContentVersion file : attachedFiles) {
            file.Attached_From_Approval__c = true;
        }

        try {
            update attachedFiles;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

    }

    @AuraEnabled
    public static List<AttachedFiles> retrieveAttachedFiles(Id recordId) {
        Set<Id> contentDocumentIdsSet = new Set<Id>();
        List<AttachedFiles> attachedFiles = new List<AttachedFiles>();

        for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId]) {
            contentDocumentIdsSet.add(cdl.ContentDocumentId);
        }

        String baseUrl = System.URL.getSalesforceBaseURL().toExternalForm();

        for (ContentVersion cv : [SELECT Id, Title, ContentDocumentId, OwnerId  FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIdsSet AND Attached_From_Approval__c = TRUE]) {
            AttachedFiles file = new AttachedFiles();
            file.Id = cv.Id;
            file.Title = cv.Title;
            file.ContentDocumentId = cv.ContentDocumentId;
            file.OwnerId = cv.OwnerId;
            file.FileLink = baseUrl + '/' + cv.ContentDocumentId;
            attachedFiles.add(file);
        }

        return attachedFiles;
    }

    public class AttachedFiles {
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String ContentDocumentId { get; set; }
        @AuraEnabled
        public String Title { get; set; }
        @AuraEnabled
        public String FileLink { get; set; }
        @AuraEnabled
        public Id OwnerId { get; set; }
    }

}