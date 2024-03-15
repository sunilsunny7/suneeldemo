/**
 * Created by kwn687 on 2022-04-12.
 */
@IsTest
public with sharing class TeliaNowStatusUpdateService_Test {
    @TestSetup
    static void testSetup() {
        System.runAs(Test_DataFactory.getByPassUser()) {
            Case testCase = new Case();
            testCase.TNOW_Case_Id__c = 'CS12345678';
            testCase.Subject = 'Test Case';
            testCase.RecordTypeId = SEUtility.getRecordTypeId('Enterprise');
            insert testCase;
        }
    }
    @IsTest
    static void updateTeliaNowCaseStatus_Ok_Test() {
        TeliaNowStatusUpdateService.TroubleTicketWrapper newTroubleTicketWrapper = new TeliaNowStatusUpdateService.TroubleTicketWrapper();
        newTroubleTicketWrapper.id = 'CS12345678';
        newTroubleTicketWrapper.status = 'Closed';
        newTroubleTicketWrapper.lastUpdate = DateTime.newInstance(2021, 6, 29, 12, 21, 0);
        newTroubleTicketWrapper.assignmentGroupID = 'd0e37ef6db4adb048877cd4d0b961913';
        TeliaNowStatusUpdateService.EventWrapper newEventWrapper = new TeliaNowStatusUpdateService.EventWrapper();
        newEventWrapper.troubleTicket = newTroubleTicketWrapper;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/telianow/case';
        request.addHeader('Content-Type', 'application/json');
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(
            '{"event": { "troubleTicket": { "id": "CS12345678","status": "Closed","lastUpdate": "2021-06-29T12:21:00.000Z","assignmentGroupID": "d0e37ef6db4adb048877cd4d0b961913"}},"eventType":"TroubleTicketStateChangeEvent"}'
        );

        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        TeliaNowStatusUpdateService.updateTeliaNowCaseStatus(newEventWrapper, 'TroubleTicketStateChangeEvent', 'status');
        Test.stopTest();
        TeliaNowStatusUpdateService.SuccessfulWrapper successful = (TeliaNowStatusUpdateService.SuccessfulWrapper) JSON.deserialize(
            response.responseBody.toString(),
            TeliaNowStatusUpdateService.SuccessfulWrapper.class
        );

        Case updatedCase = [SELECT Id, TNOW_Status__c, Current_TNOW_Queue_Id__c, Current_TNOW_Queue__c FROM Case WHERE TNOW_Case_Id__c = 'CS12345678'];
        Assert.areEqual('Closed', updatedCase.TNOW_Status__c, 'TNOW Status is wrong');
        Assert.areEqual('d0e37ef6db4adb048877cd4d0b961913', updatedCase.Current_TNOW_Queue_Id__c, 'TNOW Queue Id is wrong');
        Assert.areEqual('2nd line Nummertjänster och Centrex Order Leverans', updatedCase.Current_TNOW_Queue__c, 'TNOW Queue is wrong');
        Assert.areEqual('200', successful.status, 'Not successful status was sent');
        Assert.areEqual('Successfully updated case', successful.message, 'Not successful message was sent');
    }
    @IsTest
    static void updateTeliaNowCaseStatus_IdEmpty_Test() {
        TeliaNowStatusUpdateService.TroubleTicketWrapper newTroubleTicketWrapper = new TeliaNowStatusUpdateService.TroubleTicketWrapper();
        newTroubleTicketWrapper.id = '';
        newTroubleTicketWrapper.status = 'Closed';
        newTroubleTicketWrapper.lastUpdate = DateTime.newInstance(2021, 6, 29, 12, 21, 0);
        newTroubleTicketWrapper.assignmentGroupID = 'd0e37ef6db4adb048877cd4d0b961913';
        TeliaNowStatusUpdateService.EventWrapper newEventWrapper = new TeliaNowStatusUpdateService.EventWrapper();
        newEventWrapper.troubleTicket = newTroubleTicketWrapper;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/telianow/case';
        request.addHeader('Content-Type', 'application/json');
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(
            '{"event": { "troubleTicket": { "id": "","status": "Closed","lastUpdate": "2021-06-29T12:21:00.000Z","assignmentGroupID": "d0e37ef6db4adb048877cd4d0b961913"}},"eventType":"TroubleTicketStateChangeEvent"}'
        );

        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        TeliaNowStatusUpdateService.updateTeliaNowCaseStatus(newEventWrapper, 'TroubleTicketStateChangeEvent', 'status');
        Test.stopTest();
        TeliaNowStatusUpdateService.ErrorWrapper error = (TeliaNowStatusUpdateService.ErrorWrapper) JSON.deserialize(
            response.responseBody.toString(),
            TeliaNowStatusUpdateService.ErrorWrapper.class
        );
        Assert.areEqual('400', error.status, 'Wrong error status was sent');
        Assert.areEqual('Case Id not provided', error.error, 'Wrong error message was sent');
    }
    @IsTest
    static void updateTeliaNowCaseStatus_IdWrong_Test() {
        TeliaNowStatusUpdateService.TroubleTicketWrapper newTroubleTicketWrapper = new TeliaNowStatusUpdateService.TroubleTicketWrapper();
        newTroubleTicketWrapper.id = 'CA1234567';
        newTroubleTicketWrapper.status = 'Closed';
        newTroubleTicketWrapper.lastUpdate = DateTime.newInstance(2021, 6, 29, 12, 21, 0);
        newTroubleTicketWrapper.assignmentGroupID = 'd0e37ef6db4adb048877cd4d0b961913';
        TeliaNowStatusUpdateService.EventWrapper newEventWrapper = new TeliaNowStatusUpdateService.EventWrapper();
        newEventWrapper.troubleTicket = newTroubleTicketWrapper;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/telianow/case';
        request.addHeader('Content-Type', 'application/json');
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(
            '{"event": { "troubleTicket": { "id": "CA1234567","status": "Closed","lastUpdate": "2021-06-29T12:21:00.000Z","assignmentGroupID": "d0e37ef6db4adb048877cd4d0b961913"}},"eventType":"TroubleTicketStateChangeEvent"}'
        );

        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        TeliaNowStatusUpdateService.updateTeliaNowCaseStatus(newEventWrapper, 'TroubleTicketStateChangeEvent', 'status');
        Test.stopTest();
        TeliaNowStatusUpdateService.ErrorWrapper error = (TeliaNowStatusUpdateService.ErrorWrapper) JSON.deserialize(
            response.responseBody.toString(),
            TeliaNowStatusUpdateService.ErrorWrapper.class
        );
        Assert.areEqual('Case Id is in wrong format', error.error, 'Wrong error message was sent');
        Assert.areEqual('400', error.status, 'Wrong error status was sent');
    }
    @IsTest
    static void updateTeliaNowCaseStatus_assignmentGroupIdWrong_Test() {
        TeliaNowStatusUpdateService.TroubleTicketWrapper newTroubleTicketWrapper = new TeliaNowStatusUpdateService.TroubleTicketWrapper();
        newTroubleTicketWrapper.id = 'CS12345678';
        newTroubleTicketWrapper.status = 'Closed';
        newTroubleTicketWrapper.lastUpdate = DateTime.newInstance(2021, 6, 29, 12, 21, 0);
        newTroubleTicketWrapper.assignmentGroupID = 'd0e37ef6db4adb048877cd4d0b96191';
        TeliaNowStatusUpdateService.EventWrapper newEventWrapper = new TeliaNowStatusUpdateService.EventWrapper();
        newEventWrapper.troubleTicket = newTroubleTicketWrapper;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/telianow/case';
        request.addHeader('Content-Type', 'application/json');
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(
            '{"event": { "troubleTicket": { "id": "CS12345678","status": "Closed","lastUpdate": "2021-06-29T12:21:00.000Z","assignmentGroupID": "d0e37ef6db4adb048877cd4d0b96191"}},"eventType":"TroubleTicketStateChangeEvent"}'
        );

        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        TeliaNowStatusUpdateService.updateTeliaNowCaseStatus(newEventWrapper, 'TroubleTicketStateChangeEvent', 'status');
        Test.stopTest();
        TeliaNowStatusUpdateService.ErrorWrapper error = (TeliaNowStatusUpdateService.ErrorWrapper) JSON.deserialize(
            response.responseBody.toString(),
            TeliaNowStatusUpdateService.ErrorWrapper.class
        );
        Assert.areEqual('404', error.status, 'Wrong error status was sent');
        Assert.areEqual('assignmentGroupID not found in Salesforce', error.error, 'Wrong error message was sent');
    }
    @IsTest
    static void updateTeliaNowCaseStatus_IdNotFound_Test() {
        TeliaNowStatusUpdateService.TroubleTicketWrapper newTroubleTicketWrapper = new TeliaNowStatusUpdateService.TroubleTicketWrapper();
        newTroubleTicketWrapper.id = 'CS12345677';
        newTroubleTicketWrapper.status = 'Closed';
        newTroubleTicketWrapper.lastUpdate = DateTime.newInstance(2021, 6, 29, 12, 21, 0);
        newTroubleTicketWrapper.assignmentGroupID = 'd0e37ef6db4adb048877cd4d0b961913';
        TeliaNowStatusUpdateService.EventWrapper newEventWrapper = new TeliaNowStatusUpdateService.EventWrapper();
        newEventWrapper.troubleTicket = newTroubleTicketWrapper;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/telianow/case';
        request.addHeader('Content-Type', 'application/json');
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(
            '{"event": { "troubleTicket": { "id": "CS12345677","status": "Closed","lastUpdate": "2021-06-29T12:21:00.000Z","assignmentGroupID": "d0e37ef6db4adb048877cd4d0b961913"}},"eventType":"TroubleTicketStateChangeEvent"}'
        );

        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        TeliaNowStatusUpdateService.updateTeliaNowCaseStatus(newEventWrapper, 'TroubleTicketStateChangeEvent', 'status');
        Test.stopTest();
        TeliaNowStatusUpdateService.ErrorWrapper error = (TeliaNowStatusUpdateService.ErrorWrapper) JSON.deserialize(
            response.responseBody.toString(),
            TeliaNowStatusUpdateService.ErrorWrapper.class
        );
        Assert.areEqual('404', error.status, 'Wrong error status was sent');
        Assert.areEqual('Case not found in Salesforce', error.error, 'Wrong error message was sent');
    }
}