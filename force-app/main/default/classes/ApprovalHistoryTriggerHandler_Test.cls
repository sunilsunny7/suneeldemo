/**
 * Created by kwn687 on 2023-01-31.
 */
@IsTest
public with sharing class ApprovalHistoryTriggerHandler_Test {
    @TestSetup
    public static void initTestData() {
        User newUser = Test_DataFactory.createCygateUser();
        insert newUser;
        System.runAs(newUser) {
            Opportunity newOpportunity = Test_DataFactory.createTeliaCygateOpportunity();
            newOpportunity.Cygate_Amount_for_Approval__c = 100;
            newOpportunity.Cygate_Margin_for_Approval__c = 10;
            insert newOpportunity;
            List<Opportunity> oneOpp = new List<Opportunity>{newOpportunity};
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setComments('Submitting request for approval.');
            request.setObjectId(newOpportunity.Id);
            request.setSubmitterId(newUser.Id);
            request.setProcessDefinitionNameOrId('Cygate_Opportunity_Approval_Process');
            request.setSkipEntryCriteria(true);
            request.setNextApproverIds(new List<Id>{newUser.Id});
            Approval.ProcessResult result = Approval.process(request);
            getApprovalHistory.execute(oneOpp);
        }
    }
    @IsTest
    public static void testApprovalHistoryInsert(){
        List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem];
        Test.startTest();
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem workItem : workItems){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItem.Id);
            req.setAction('Approve');
            req.setComments('Your Comment.');
            requests.add(req);
        }
        Approval.ProcessResult[] processResults = Approval.process(requests);
        Test.stopTest();
    }
}