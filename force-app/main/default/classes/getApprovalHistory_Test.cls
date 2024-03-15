/**
 * Created by kwn687 on 2022-11-30.
 */
@IsTest
public with sharing class getApprovalHistory_Test {
    @TestSetup
    public static void initTestData() {
        User newUser = Test_DataFactory.createCygateUser();
        insert newUser;
        System.runAs(newUser) {
            Opportunity newOpportunity = Test_DataFactory.createTeliaCygateOpportunity();
            newOpportunity.Cygate_Amount_for_Approval__c = 100;
            newOpportunity.Cygate_Margin_for_Approval__c = 10;
            insert newOpportunity;
        }
    }
    @IsTest
    public static void testApprovalHistoryInsert() {
        List<Opportunity> oneOpportunity = [SELECT Id, Cygate_Amount_for_Approval__c, Cygate_Margin_for_Approval__c, Approval_Type__c FROM Opportunity];
        User newUser = [SELECT Id FROM User WHERE Email = 'chgustaf@gmail.com'];
        Test.startTest();
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setComments('Submitting request for approval.');
        request.setObjectId(oneOpportunity[0].Id);
        request.setSubmitterId(newUser.Id);
        request.setProcessDefinitionNameOrId('Cygate_Opportunity_Approval_Process');
        request.setSkipEntryCriteria(true);
        request.setNextApproverIds(new List<Id>{ newUser.Id });
        Approval.ProcessResult result = Approval.process(request);
        getApprovalHistory.execute(oneOpportunity);
        Test.stopTest();
        List<Approval_History__c> approvalHistories = [SELECT Id FROM Approval_History__c WHERE Opportunity__r.Id = :oneOpportunity[0].Id];
        System.assertEquals(1, approvalHistories.size(), 'Approval history wasn\'t copy right');
    }
}