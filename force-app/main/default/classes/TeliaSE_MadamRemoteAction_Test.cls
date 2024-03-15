/**
 * @Author:      Shubham Kundu
 * @Company:     Capgemini
 * @Date:        4th Feb 2019
 * @Description: TeliaSE_MadamRemoteAction_Test is a Test Class for TeliaSE_MadamRemoteAction.
 *
 * History
 * <Date>           <Authors Name>      <Brief Description of Change>
 * -------------------------------------------------------------------
*/
@isTest
public with sharing class TeliaSE_MadamRemoteAction_Test {
    
     private static void customSettingSetup() {
        List < WebService__c > endpointURLs = new List < WebService__c > ();
        WebService__c wbTest,wbTest2,wbTest3;
        wbTest = new WebService__c(Name = 'TeliaSE_MadamAuthenticationWS', 
                                       EndpointURL__c = 'https://apimarket-test.eam.telia.se/token',
                                       Content_Type__c = 'application/x-www-form-urlencoded', 
                                       userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                       password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                       Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        wbTest2 = new WebService__c(Name = 'MC_APIGarden_token', 
                                       EndpointURL__c = 'https://api-garden-test.teliacompany.com/customer/v0.2/oauth/client_credential/accesstoken?grant_type=client_credentials',
                                       Content_Type__c = 'application/json', 
                                       userName__c = 'sYIyaB9O5zBYqgvHd9Mb7HktvsMriRmr',
                                       password__c = '1XrFMATziuG0A6QV', 
                                       Authorization__c = 'Basic c1lJeWFCOU81ekJZcWd2SGQ5TWI3SGt0dnNNcmlSbXI6MVhyRk1BVHppdUcwQTZRVg=='); 
        wbTest3 = new WebService__c(Name = 'TeliaSE_MadamAuthenticationWS_UAT', 
                                       EndpointURL__c = 'https://api-garden-test.teliacompany.com/customer/v0.2/oauth/client_credential/accesstoken?grant_type=client_credentials',
                                       Content_Type__c = 'application/json', 
                                       userName__c = 'sYIyaB9O5zBYqgvHd9Mb7HktvsMriRmr',
                                       password__c = '1XrFMATziuG0A6QV', 
                                       Authorization__c = 'Basic c1lJeWFCOU81ekJZcWd2SGQ5TWI3SGt0dnNNcmlSbXI6MVhyRk1BVHppdUcwQTZRVg=='); 
         endpointURLs.add(wbTest);
        endpointURLs.add(wbTest2);
         endpointURLs.add(wbTest3);
        insert endpointURLs;
         
    }

    @isTest
    static void authentication_Scenario() {
        customSettingSetup();
        TeliaSE_MadamRemoteAction mra = new TeliaSE_MadamRemoteAction();
        String methodName = 'authMethod';
        Map<String,Object> inputMap = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();
        Map<String,Object> options = new  Map<String,Object>();
        test.startTest();
        mra.invokeMethod(methodName,inputMap,outMap,options);
        test.stopTest();
    }
    
    @isTest
    static void apiGardenAuthentication_Scenario1() {
        customSettingSetup();
        TeliaSE_MadamRemoteAction mra = new TeliaSE_MadamRemoteAction();
        String methodName = 'authMethod_APIGarden';
        Map<String,Object> inputMap = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();
        Map<String,Object> options = new  Map<String,Object>();
        Map<String,Object> endpointMap = new Map<String,object>();
        endpointMap.put('APIToken','MC_APIGarden_token');
        inputMap.put('SetEndPoint',endpointMap);
        test.startTest();
        mra.invokeMethod(methodName,inputMap,outMap,options);
        test.stopTest();
    }
    
     @isTest
    static void apiGardenAuthentication_Scenario2() {
        customSettingSetup();
        TeliaSE_MadamRemoteAction mra = new TeliaSE_MadamRemoteAction();
        String methodName = 'authMethod_AT';
        Map<String,Object> inputMap = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();
        Map<String,Object> options = new  Map<String,Object>();
        test.startTest();
        mra.invokeMethod(methodName,inputMap,outMap,options);
        test.stopTest();
    }
    
   

}