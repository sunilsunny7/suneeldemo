/**
 * Created by uly8476 on 2023-03-15.
 */

@IsTest
private class attachedFilesComponentController_Test {
    @TestSetup
    static void setupTestData() {
        User user = Test_DataFactory.createCygateUser();
        insert user;

        System.runAs(user) {
            Opportunity opp = Test_DataFactory.createTeliaCygateOpportunity();
            opp.Cygate_Amount_for_Approval__c = 100;
            opp.Cygate_Margin_for_Approval__c = 10;
            insert opp;

            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setComments('Submitting request for approval.');
            approvalRequest.setObjectId(opp.Id);
            approvalRequest.setSubmitterId(user.Id);
            approvalRequest.setProcessDefinitionNameOrId('Cygate_Opportunity_Approval_Process');
            approvalRequest.setSkipEntryCriteria(true);
            approvalRequest.setNextApproverIds(new List<Id>{user.Id});
            Approval.process(approvalRequest);

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
                        LinkedEntityId = opp.Id,
                        ContentDocumentId = doc.Id,
                        ShareType = 'V',
                        Visibility = 'AllUsers');
                cdls.add(cdl);
            }
            insert cdls;
        }
    }


    @IsTest
    static void getRelatedRecordId_PIS_Test() {
        Test.startTest();
        Id result = attachedFilesComponentController.getRelatedRecordId([SELECT Id FROM ProcessInstanceStep LIMIT 1].Id, 'ProcessInstanceStep');
        Test.stopTest();

        Assert.areEqual([SELECT TargetObjectId FROM ProcessInstance LIMIT 1].TargetObjectId, result, 'Related record ID should be Opportunity ID');

    }
    @IsTest
    static void getRelatedRecordId_PIW_Test() {
        Test.startTest();
        Id result = attachedFilesComponentController.getRelatedRecordId([SELECT Id FROM ProcessInstanceWorkitem LIMIT 1].Id, 'ProcessInstanceWorkitem');
        Test.stopTest();

        Assert.areEqual([SELECT TargetObjectId FROM ProcessInstance LIMIT 1].TargetObjectId, result, 'Related record ID should be Opportunity ID');
    }
    @IsTest
    static void getRelatedRecordId_Null_Test() {
        Test.startTest();
        Id result = attachedFilesComponentController.getRelatedRecordId([SELECT Id FROM ProcessInstance LIMIT 1].Id, 'InvalidObjectApiName');
        Test.stopTest();

        Assert.areEqual(null, result, 'Related record ID should be null for invalid object API name');
    }
    @IsTest
    static void updateAttachedFiles_Test() {
        List<ContentVersion> contentVersions = [SELECT Id, Attached_From_Approval__c FROM ContentVersion];
        List<Id> contentVersionIds = new List<Id>();

        for (ContentVersion cv : contentVersions) {
            contentVersionIds.add(cv.Id);
        }

        Test.startTest();
        attachedFilesComponentController.updateAttachedFiles(contentVersionIds);
        Test.stopTest();

        List<ContentVersion>updatedContentVersions = [SELECT Id, Attached_From_Approval__c FROM ContentVersion];
        for(ContentVersion cv : updatedContentVersions) {
            Assert.areEqual(true, cv.Attached_From_Approval__c, 'Updated ContentVersions should have Attached_From_Approval__c field value set to true');
        }
    }
    @IsTest
    static void retrieveAttachedFiles_Test() {
        Set<Id> contentDocumentIds = new Set<Id>();
        List<Opportunity> oppList = [SELECT Id, Name, Owner.Name FROM Opportunity LIMIT 1];
        List<ContentDocumentLink> contentDocumentLinks = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: oppList[0].Id];
        for(ContentDocumentLink cdl : contentDocumentLinks) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }
        List<ContentVersion> contentVersions = [SELECT Id, Attached_From_Approval__c FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds];
        for (ContentVersion cv : contentVersions) {
            cv.Attached_From_Approval__c = true;
        }
        update contentVersions;

        Test.startTest();
        List<attachedFilesComponentController.AttachedFiles> attachedFiles = attachedFilesComponentController.retrieveAttachedFiles(oppList[0].Id);
        Test.stopTest();

        Assert.areNotEqual(true, attachedFiles.isEmpty(), 'AttachedFiles list should not be empty.');
    }
}