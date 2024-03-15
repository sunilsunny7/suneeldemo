@isTest
private class MC_Utility_Test {
     @testSetup
    private static void testDataSetup() {
        List <WebService__c> endpoints = new List < WebService__c > ();
        WebService__c wbTest = new WebService__c(Name = 'TeliaSE_MadamAuthenticationWS', 
                                                 EndpointURL__c = 'https://test.endpoint.com/token',
                                                 Content_Type__c = 'application/x-www-form-urlencoded', 
                                                 userName__c = '123ab',
                                                 password__c = 'testpwd', 
                                                 Authorization__c = 'Basic testiweurioewroiu3oi4rjdkwd');
        insert wbTest;
    }
    
    @isTest
    private static void test_getEndpointInfo(){
        Test.startTest();
        WebService__c data = MC_Utility.getEndpointInfo('TeliaSE_MadamAuthenticationWS');
        Test.stopTest();
        System.assertEquals('application/x-www-form-urlencoded',data.Content_Type__c);
    }
    
    @isTest
    private static void test_buildHttpRequest(){
        Test.startTest();
        HttpRequest request = MC_Utility.buildHttpRequest('POST','testendpoint','application/json','uhfufi8','testRequest)');
        Test.stopTest();
        System.assertEquals('testendpoint',request.getEndpoint());
    }
    
    @isTest
    private static void test_generateLog(){
        Test.startTest();
        MC_Utility.generateLog('Info','testMethod','test',null,200,'testRequest','testResponse',null,null);
        Test.stopTest();
        List<Application_Logs__c> log = [SELECT Id FROM Application_Logs__c];
        System.assertEquals(1,log.size());        
    }
    
    @isTest
    private static void test_getMadamAuthToken(){
        Test.startTest();
        String authToken = MC_Utility.getMadamAuthToken();
        Test.stopTest();
    }
    
    @isTest
    private static void test_getCustomLabel(){
        Test.startTest();
        String label = MC_Utility.getCustomLabel(null,'MC_API_Success_Logging',null);
        Test.stopTest();
        System.assertNotEquals(null,label);
    }
}