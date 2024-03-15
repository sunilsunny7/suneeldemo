/**
 * Created by kwn687 on 2022-04-12.
 */
@RestResource(urlMapping='/telianow/case')
global with sharing class TeliaNowStatusUpdateService {
    @HttpPost
    global static void updateTeliaNowCaseStatus(EventWrapper event, String eventType, String fieldPath) {
        String result = '';
        RestResponse response = RestContext.response;
        Map<String, String> tnowQueueIdMap = new Map<String, String>();

        for (TNOW_Queue__mdt tnowQueue : TNOW_Queue__mdt.getAll().values()) {
            tnowQueueIdMap.put(tnowQueue.Current_TNOW_Queue_ID__c, tnowQueue.Current_TNOW_Queue__c);
        }
        if (validateData(event, response, tnowQueueIdMap)) {
            List<Case> allCases = [
                SELECT id, TNOW_Status__c, Current_TNOW_Queue_Id__c, Current_TNOW_Queue__c, Last_Modified_in_TNOW__c
                FROM Case
                WHERE TNOW_Case_Id__c = :event.troubleTicket.id
            ];
            if (!allCases.isEmpty()) {
                try {
                    for (Case oneCase : allCases) {
                        if (event.troubleTicket.status != null) {
                            oneCase.TNOW_Status__c = event.troubleTicket.status;
                        }
                        if (event.troubleTicket.assignmentGroupID != null) {
                            oneCase.Current_TNOW_Queue_Id__c = event.troubleTicket.assignmentGroupID;
                            oneCase.Current_TNOW_Queue__c = tnowQueueIdMap.get(event.troubleTicket.assignmentGroupID);
                        }
                        oneCase.Last_Modified_in_TNOW__c = event.troubleTicket.lastUpdate;
                    }
                    update allCases;
                    SuccessfulWrapper respond = new SuccessfulWrapper();
                    respond.status = '200';
                    respond.message = 'Successfully updated case';
                    result = JSON.serialize(respond);
                    response.addHeader('Content-Type', 'application/json');
                    response.statusCode = 200;
                    response.responseBody = Blob.valueOf(result);
                } catch (Exception ex) {
                    Application_Logs__c newError = new Application_Logs__c();
                    newError.Debug_Level__c = 'Error';
                    newError.Source__c = 'TeliaNowStatusUpdateService';
                    newError.Source_Function__c = 'updateTeliaNowCaseStatus';
                    newError.Message__c = ex.getDmlMessage(0);
                    newError.Stack_Trace__c = ex.getMessage();
                    insert newError;
                    response.addHeader('Content-Type', 'application/json');
                    response.statusCode = 500;
                    ErrorWrapper responseError = new ErrorWrapper();
                    responseError.error = ex.getDmlMessage(0);
                    responseError.status = '500';
                    response.responseBody = Blob.valueOf(JSON.serialize(responseError));
                }
            } else {
                response.addHeader('Content-Type', 'application/json');
                response.statusCode = 404;
                ErrorWrapper responseError = new ErrorWrapper();
                responseError.error = 'Case not found in Salesforce';
                responseError.status = '404';
                response.responseBody = Blob.valueOf(JSON.serialize(responseError));
            }
        }
    }
    private static boolean validateData(EventWrapper event, RestResponse response, Map<String, String> tnowQueueIdMap) {
        if (event.troubleTicket.id == '') {
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 400;
            ErrorWrapper responseError = new ErrorWrapper();
            responseError.error = 'Case Id not provided';
            responseError.status = '400';
            response.responseBody = Blob.valueOf(JSON.serialize(responseError));
            return false;
        } else if (event.troubleTicket.id.left(2) != 'CS' || event.troubleTicket.id.length() != 10) {
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 400;
            ErrorWrapper responseError = new ErrorWrapper();
            responseError.error = 'Case Id is in wrong format';
            responseError.status = '400';
            response.responseBody = Blob.valueOf(JSON.serialize(responseError));
            return false;
        } else if (
            !tnowQueueIdMap.isEmpty() &&
            !tnowQueueIdMap.keyset().contains(event.troubleTicket.assignmentGroupID) &&
            event.troubleTicket.assignmentGroupID != null
        ) {
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 404;
            ErrorWrapper responseError = new ErrorWrapper();
            responseError.error = 'assignmentGroupID not found in Salesforce';
            responseError.status = '404';
            response.responseBody = Blob.valueOf(JSON.serialize(responseError));
            return false;
        } else {
            return true;
        }
    }
    global class EventWrapper {
        global TroubleTicketWrapper troubleTicket;
    }
    global class TroubleTicketWrapper {
        global String id;
        global String status;
        global Datetime lastUpdate;
        global String assignmentGroupID;
    }
    public class ErrorWrapper {
        public String status;
        public String error;
    }
    public class SuccessfulWrapper {
        public String status;
        public String message;
    }
}