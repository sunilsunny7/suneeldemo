/**
 * Created by uly8476 on 2021-11-09.
 */

@IsTest
private class DedicatedChatWebService_Test {
    @TestSetup
    static void testSetup() {
        System.runAs(Test_DataFactory.getByPassUser()) {
            Account acc = Test_DataFactory.createOneLargeStandardAccount();
            User largeUser = Test_DataFactory.createLargeUser();
            largeUser.Title = 'Sales Manager';
            largeUser.Phone = '+46999999597';
            insert largeUser;

            acc.Working_hour_Start_Call__c = Time.newInstance(8,0,0,0);
            acc.Working_hour_End_Call__c = Time.newInstance(17,0,0,0);
            acc.Working_hour_Start_Chat__c = Time.newInstance(8,0,0,0);
            acc.Working_hour_End_Chat__c = Time.newInstance(17,0,0,0);
            acc.Weekend_hour_Start_Chat__c = Time.newInstance(8,0,0,0);
            acc.Weekend_hour_End_Chat__c = Time.newInstance(17,0,0,0);
            acc.Support_Number__c = 'Other';
            acc.Chat_Type__c = 'Large Live Chat';
            acc.Other_Support_Number__c = '+46771112625';
            acc.Org_Nr__c = '1234512345';
            acc.OwnerId = largeUser.Id;
            acc.Sales_Team__c = 'Large Public North';
            insert acc;
        }
    }

    @IsTest
    static void getDedicatedChatInfoByOrgNr_Ok_Test() {
        Account acc = [SELECT Id, Name, Org_Nr__c FROM Account LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/dedicatedChatWebService/' + acc.Org_Nr__c;
        request.addHeader('Content-Type', 'application/json');
        request.httpMethod = 'GET';
        request.requestBody = Blob.valueOf('{}');

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        DedicatedChatWebService.getDedicatedChatInfoByOrgNr();
        Test.stopTest();

        System.assertNotEquals(null, response.responseBody.toString());
    }

    @IsTest
    static void getDedicatedChatInfoByOrgNr_NotOk_Test() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/dedicatedChatWebService/' + '1234';
        request.addHeader('Content-Type', 'application/json');
        request.httpMethod = 'GET';
        request.requestBody = Blob.valueOf('{}');

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        DedicatedChatWebService.getDedicatedChatInfoByOrgNr();
        Test.stopTest();

        System.assertNotEquals(null, response.responseBody.toString());
    }

    @IsTest
    static void getDedicatedChatInfoByOrgNr_OrgNrEmpty_Test() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/dedicatedChatWebService/' + '';
        request.addHeader('Content-Type', 'application/json');
        request.httpMethod = 'GET';
        request.requestBody = Blob.valueOf('{}');

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        DedicatedChatWebService.getDedicatedChatInfoByOrgNr();
        Test.stopTest();

        System.assertNotEquals(null, response.responseBody.toString());
    }
}