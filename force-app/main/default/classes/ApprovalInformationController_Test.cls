@IsTest
public with sharing class ApprovalInformationController_Test {
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
            approvalRequest.setNextApproverIds(new List<Id>{ user.Id });
            Approval.process(approvalRequest);
        }
    }
    @IsTest
    static void getRecordData_PIS_Test() {
        Test.startTest();
        ApprovalInformationController.wrapper result = ApprovalInformationController.getRecordData(
            [SELECT Id FROM ProcessInstanceStep LIMIT 1].Id,
            'ProcessInstanceStep'
        );
        Test.stopTest();

        Assert.isNotNull(result, 'LWC controller return bad wraper');
    }
    @IsTest
    static void getRecordData_PIW_Test() {
        Test.startTest();
        ApprovalInformationController.wrapper result = ApprovalInformationController.getRecordData(
            [SELECT Id FROM ProcessInstanceWorkitem LIMIT 1].Id,
            'ProcessInstanceWorkitem'
        );
        Test.stopTest();
        Assert.isNotNull(result, 'LWC controller return bad wraper');
    }
    @IsTest
    static void getRecordData_PIS_History_Test() {
        Id user = [SELECT Id FROM User WHERE firstname = 'Cygate' LIMIT 1].Id;
        Id opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Test.startTest();
        Id workItems = [
            SELECT Id
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId = :opportunityId
        ]
        .Id;
        Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
        request.setComments('Approving request.');
        request.setAction('Approve');
        request.setNextApproverIds(new List<Id>{ user });
        request.setWorkitemId(workItems);
        Approval.process(request);
        ApprovalInformationController.wrapper result = ApprovalInformationController.getRecordData(
            [SELECT Id FROM ProcessInstanceStep LIMIT 1].Id,
            'ProcessInstanceStep'
        );
        Test.stopTest();
        Assert.isNotNull(result, 'LWC controller return bad wraper');
    }
}