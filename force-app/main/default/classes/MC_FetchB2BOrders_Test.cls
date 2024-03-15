@isTest
private class MC_FetchB2BOrders_Test {
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        String type;
        public MockHttpResponseGenerator(String type){
            this.type = type;
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if(type == null){
                res.setBody('{ "statusCode": 0, "statusMessage": null, "transactionId": null, "status": true, "subsystemStatusCode": null, "totalCount": 3, "filteredCount": 3, "customerOrders": [{ "customerorderid": "9556870", "customerorderentereddate": "2021-10-27T15:30:05.000+02:00", "customerorderregistereddate": "2021-10-27T15:30:41.000+02:00", "customerordercategory": "Standard Order", "customerordertype": "Cancellation", "customerordernotificationchoice": null, "customerorderrequestedcompletiondate": "2021-12-01T00:00:00.000+01:00", "customerorderpromisedcompletiondate": "2021-12-01T00:00:00.000+01:00", "customerordercompletiondate": "2021-12-21T11:45:06.000+01:00", "customerorderstatus":"Ongoing", "tscid": "7000564687", "customername": "SKF Sverige AB", "customertype": "ORGANIZATION", "channelid": "DOE", "ordererid": null, "ordereremailaddress": null, "ordererfirstname": " Framtidens Nät", "ordererlastname": null, "orderername": " Framtidens Nät", "orderertelephonenumber": "+4670", "customerpurchaseagreementid": null, "creditagreementid": null, "retailerid": "353884", "tcadid": "GGG832", "uororderstatus": "ACTIVE", "customeridentificationnumber": "165562408301", "customerOrderItemPromisedDeliveryDate": "2021-12-01T00:00:00.000+01:00", "customerOrderItemQuantity": "1", "customerOrderItemRequestedDeliveryDate": "2021-12-01T00:00:00.000+01:00", "customerOrderItemStatus": "Closed", "mainorderitem": "Yes", "offeringname": "Paket Huvudproduktanläggning", "offeringnameofferingcode": "ERBJUDANDE-PAKET" }] }');            
            } else if(type == 'addons'){
                res.setBody('{ "statusCode": 0, "statusMessage": "OK - order details found", "transactionId": null, "status": true, "subsystemStatusCode": null, "level2data": { "uororderid": "madam:25008", "uoruid": "4A8155A453CE9D118AA44097CF731EE6014D938AC48AC89546403119E1A668E3", "uororderstatus": "ACTIVE", "customerorderid": "25008", "customerordertype": "NEW", "customerordernotificationchoice": null, "customerorderrequestedcompletiondate": null, "customerorderpromisedcompletiondate": null, "customerordercompletiondate": null, "customerorderentereddate": "2022-12-09T10:48:54.000+01:00", "customerorderstatus": "Ongoing", "tscid": "7000136196", "customername": "Make Up Center i Norrköping AB", "customertype": "ORGANIZATION", "channelid": null, "ordereremailaddress": null, "ordererfirstname": null, "ordererlastname": null, "customeridentificationnumber": "165565228235" }, "sourcesystemorders": [ { "uorOrderId": "madam:25008", "uoruid": "4A8155A453CE9D118AA44097CF731EE6014D938AC48AC89546403119E1A668E3", "customerIdentificationnumber": "165565228235", "billingAccountId": null, "creditCheckResult": null, "description": null, "sourceSystemOrderId": "25008", "sourceSystem": "madam", "sourceSystemOrderType": "TouchPoint", "mainOrderId": "madam:null:46730996362", "customerOrderStatus": "Ongoing", "tscid": "7000136196", "customerName": "Make Up Center i Norrköping AB", "customerType": "ORGANIZATION", "channelId": null, "uorOrderStatus": "ACTIVE", "customerOrderEnteredDate": "2022-12-09T10:48:54.000+01:00", "orderItems": [ { "uorOrderItemId": "madam:25008:1", "uorOrderItemStatus": "ACTIVE", "uorOrderId": "madam:25008", "mainOrderId": "madam:null:46730996362", "uoruid": "4A8155A453CE9D118AA44097CF731EE6014D938AC48AC89546403119E1A668E3", "offeringNameOfferingCode": "SMESOLCDG", "offeringName": null, "subscriptionid": "46730996362", "mainOrderItem": false, "customerOrderId": "25008", "agents": [], "madamService": {}, "autoVoiceService": null, "customerOrderItemAttributes": [], "parcelIds": [] } ], "orderAttributes": [], "customerOrderParcels": [] } ], "sourcesystemupdates": null, "sourceSystemReferences": null }'); 
            }
            res.setStatusCode(200);
            return res;
        }
    }
    
    @testSetup
    private static void testDataSetup() {
        List <WebService__c> endpoints = new List < WebService__c > ();
        WebService__c wbTest = new WebService__c(Name = 'TeliaSE_MadamAuthenticationWS', 
                                                 EndpointURL__c = 'https://test.endpoint.com/token',
                                                 Content_Type__c = 'application/x-www-form-urlencoded', 
                                                 userName__c = '123ab',
                                                 password__c = 'testpwd', 
                                                 Authorization__c = 'Basic testiweurioewroiu3oi4rjdkwd');
        endpoints.add(wbTest);
        WebService__c wbTest1 = new WebService__c(Name = 'MC_UOR_CustomerOrders', 
                                                  EndpointURL__c = 'https://testOrders.endpoint.com',
                                                  Content_Type__c = 'application/json');
        
        WebService__c wbTest2 = new WebService__c(Name = 'MC_UOR_CustomerOrderDetails', 
                                                  EndpointURL__c = 'https://testOrders.endpoint.com',
                                                  Content_Type__c = 'application/json');
        
        endpoints.add(wbTest1);
        endpoints.add(wbTest2);
        insert endpoints;
        User salesManager;         
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            List<Account> accList = new List<Account>();
            
            Account acc=Test_DataFactory.createOneSMEAccount();
            acc.Name = 'AccWithOrders';
            acc.C2B_Org_nr__c ='42523452';
            accList.add(acc);
            
            Account acc2=Test_DataFactory.createOneSMEAccount();
            acc2.Name = 'AccWithOutOrders';
            acc2.C2B_Org_nr__c ='425252';
            accList.add(acc2);
            insert accList;
            
            MC_B2B_Order__c ord1 = new MC_B2B_Order__c();
            ord1.Name = 'Test1';
            ord1.MC_Order_Number__c = '1001';
            ord1.MC_UOR_OrderId__c = '1001';
            ord1.MC_Orderer_Email__c = 'test1@more.biz';
            ord1.MC_Account__c = acc.Id;
            ord1.MC_Main_Order_Item__c = true;
            insert ord1;
            
            MC_B2B_Order__c ord2 = new MC_B2B_Order__c();
            ord2.Name = 'Test2';
            ord2.MC_Order_Number__c = '1002';
            ord2.MC_UOR_OrderId__c = '1002';
            ord2.MC_Orderer_Email__c = 'test2@more.biz';
            ord2.MC_Account__c = acc.Id;
            ord2.MC_Main_Order_Item__c = false;
            insert ord2;
        }
        
    }
    
    @isTest
    private static void test_getRecordsForB2BOrders(){
        
        Account acc=[SELECT Id,C2B_Org_nr__c FROM Account WHERE Name = 'AccWithOrders'];
        MC_FetchB2BOrders fetchOrders = new MC_FetchB2BOrders();
        Test.startTest();
        MC_FetchB2BOrders.getRecordsForB2BOrders(acc.Id,acc.C2B_Org_nr__c);
        Test.stopTest();
    }
    
    @isTest
    private static void test_getRecordsForB2BOrders2(){
        
        Account acc=[SELECT Id,C2B_Org_nr__c FROM Account WHERE Name = 'AccWithOutOrders'];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(null));
        Test.startTest();
        MC_FetchB2BOrders.getRecordsForB2BOrders(acc.Id,acc.C2B_Org_nr__c);
        Test.stopTest();
    }
    
    @isTest
    private static void test_fetchAddonsApiCall(){
        
        Account acc=[SELECT Id,C2B_Org_nr__c FROM Account WHERE Name = 'AccWithOutOrders'];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('addons'));
        Test.startTest();
        MC_FetchB2BOrders.fetchAddonsApiCall(new List<String>{'1224','44322'},acc.Id);
        Test.stopTest();
    }
    
    @isTest
    private static void test_getAddonsForB2BOrders(){
        
        Account acc=[SELECT Id,C2B_Org_nr__c FROM Account WHERE Name = 'AccWithOrders'];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('addons'));
        Test.startTest();
        MC_FetchB2BOrders.getAddonsForB2BOrders(acc.Id,'1002');
        Test.stopTest();
    }
    
    @isTest
    private static void test_getAddonsForB2BOrders2(){
        
        Account acc=[SELECT Id,C2B_Org_nr__c FROM Account WHERE Name = 'AccWithOutOrders'];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('addons'));
        Test.startTest();
        MC_FetchB2BOrders.getAddonsForB2BOrders(acc.Id,'1112');
        Test.stopTest();
    }
}