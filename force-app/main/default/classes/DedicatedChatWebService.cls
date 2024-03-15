/**
 * Created by uly8476 on 2021-10-25.
 */
@RestResource(UrlMapping='/dedicatedChatWebService/*')
global with sharing class DedicatedChatWebService {
    @HttpGet
    global static void getDedicatedChatInfoByOrgNr() {
        String result = '';
        List<Account> accList = new List<Account>();
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String orgNr = request.requestURI.substringAfter('/dedicatedChatWebService/');
        if (orgNr != ''){
            accList = [SELECT Id, Org_Nr__c, Support_Number__c, Other_Support_Number__c, Working_hour_Start_Call__c, Working_hour_End_Call__c, Working_hour_Start_Chat__c, Working_hour_End_Chat__c, Weekend_hour_Start_Chat__c, Weekend_hour_End_Chat__c, Chat_Type__c, Owner.Name, Owner.Title, Owner.Email, Owner.MobilePhone, Owner.Phone, Sales_Team__c FROM Account WHERE Org_Nr__c = :orgNr LIMIT 1];
            if (!accList.isEmpty()) {
                DedicatedChatInformation chatInfo = new DedicatedChatInformation();
                chatInfo.workingHourStartCall = String.valueOf(accList[0].Working_hour_Start_Call__c);
                chatInfo.workingHourEndCall = String.valueOf(accList[0].Working_hour_End_Call__c);
                chatInfo.workingHourStartChat = String.valueOf(accList[0].Working_hour_Start_Chat__c);
                chatInfo.workingHourEndChat = String.valueOf(accList[0].Working_hour_End_Chat__c);
                chatInfo.weekendHourStartChat = String.valueOf(accList[0].Weekend_hour_Start_Chat__c);
                chatInfo.weekendHourEndChat = String.valueOf(accList[0].Weekend_hour_End_Chat__c);
                chatInfo.supportNumber = accList[0].Support_Number__c;
                chatInfo.otherSupportNumber = accList[0].Other_Support_Number__c;
                chatInfo.chatType = accList[0].Chat_Type__c;

                salesAgentInformation agentInfo = new salesAgentInformation();
                agentInfo.name = accList[0].Owner.Name;
                agentInfo.title = accList[0].Owner.Title;
                agentInfo.email = accList[0].Owner.Email;
                agentInfo.mobileNumber = accList[0].Owner.MobilePhone;
                agentInfo.phone = accList[0].Owner.Phone;
                agentInfo.salesTeam = accList[0].Sales_Team__c;
                Map<String, Object> responseMap = new Map<String, Object>{
                        'dedicatedChat' => chatInfo,
                        'salesAgent' => agentInfo
                };

                result = JSON.serialize(responseMap);
                response.addHeader('Content-Type', 'application/json');
                response.statusCode = 200;
                response.responseBody = Blob.valueOf(result);
            } else {
                response.addHeader('Content-Type', 'application/json');
                response.statusCode = 404;
                errorWrapper responseError = new errorWrapper();
                responseError.error = 'Org Number not found';
                responseError.status = '404';
                response.responseBody = Blob.valueOf(JSON.serialize(responseError));
            }
        } else {
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 400;
            errorWrapper responseError = new errorWrapper();
            responseError.error = 'Org Number not provided';
            responseError.status = '400';
            response.responseBody = Blob.valueOf(JSON.serialize(responseError));
        }
    }
    public class DedicatedChatInformation {
        public String workingHourStartCall;
        public String workingHourEndCall;
        public String workingHourStartChat;
        public String workingHourEndChat;
        public String supportNumber;
        public String chatType;
        public String otherSupportNumber;
        public String weekendHourStartChat;
        public String weekendHourEndChat;
    }
    public class salesAgentInformation {
        public String name;
        public String title;
        public String email;
        public String mobileNumber;
        public String phone;
        public String salesTeam;
    }
    public class errorWrapper {
        public String status;
        public String error;
    }
}