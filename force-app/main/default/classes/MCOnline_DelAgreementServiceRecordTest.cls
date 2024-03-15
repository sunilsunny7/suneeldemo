@isTest
public class MCOnline_DelAgreementServiceRecordTest 
{
    @testSetup
    static void initTestData() 
    {
        MCOnline_Agreement_Services_Temp_data__c arg = new MCOnline_Agreement_Services_Temp_data__c ();
        arg.MCOnline_Agreement_number__c = '11100491';
        insert arg;
    }
    @istest
    static void madamAgreementTest()
    {
        //String data = '{"ConditionalBlock1Status":false,"SetParameter":{"ContractId":["8007Z000002VgnfQAC","8007Z000002Vqh6QAC","8009E000003trIhQAI","8009E000003tzMVQAY"],"InputContractId":"","InputagreementNumber":"11100491","AgreementVersion":"","AgreementStatus":"","AgreementType":"","AgreementSubscriptionType":"","AgreementSubscriptionTypeStatus":"","AgreementServiceCode":"","AgreementServiceType":"","AgreementServiceStatus":"","AgreementServiceAvailability":"","AgreementContractId":""},"SetParameterStatus":true,"DR_FetchAgreement":{"Contract":[{"contractId":"8007Z000002VgnfQAC","agreementNumber":"11100491"},{"contractId":"8007Z000002Vqh6QAC","agreementNumber":"11100491"},{"contractId":"8009E000003trIhQAI","agreementNumber":"11100491"},{"contractId":"8009E000003tzMVQAY","agreementNumber":"11100491"}],"ExtractSuccess":true},"DR_FetchAgreementStatus":true,"options":{"Content-Type":"application/json","X-Salesforce-Forwarded-To":"xyz","X-B3-TraceId":"5435e85a068d0fc4","X-Salesforce-SNI":"PRESENT","Postman-Token":"fd188d92-ca82-4227-9fd6-ee89cdd6682a","X-B3-Sampled":"0","X-B3-SpanId":"5435e85a068d0fc4","X-Salesforce-SIP":"45.251.234.173","X-Salesforce-VIP":"FORCE","Accept-Encoding":"gzip, deflate, br","Host":"telia--dev2online.my.salesforce.com","Connection":"keep-alive","User-Agent":"PostmanRuntime/7.28.4","CipherSuite":"ECDHE-RSA-AES256-GCM-SHA384 TLSv1.2 443","Accept":"*/*"},"agreement":{"services":[{"agreementContractId":"","agreementServiceAvailability":"","agreementServiceStatus":"","agreementServiceType":"","agreementServiceCode":"","agreementSubscriptionTypeStatus":"","agreementSubscriptionType":""}],"agreementData":{"agreementType":"","agreementStatus":"","agreementVersion":"","contractId":"","agreementNumber":"11100491"}}}';
        String data = '{"agreementNew":{"agreement":{"agreementData":{"agreementNumber":"02445489","contractId":"8003O000002c1pUQAQ","agreementVersion":"V3","agreementStatus":"Active","agreementType":"Ramavtal"},"services":[{"agreementSubscriptionType":"98","agreementSubscriptionTypeStatus":"V","agreementServiceCode":"RLHT","agreementServiceType":"","agreementServiceStatus":"V","agreementServiceAvailability":"VAL"}]}},"agreementOld":{"agreement":{"agreementData":{"agreementNumber":"02445489","contractId":"8003O000002c1pUQAQ","agreementVersion":"V3","agreementStatus":"Active","agreementType":"Ramavtal"},"services":[{"agreementSubscriptionType":"98","agreementSubscriptionTypeStatus":"V","agreementServiceCode":"RLHT","agreementServiceType":"","agreementServiceStatus":"V","agreementServiceAvailability":"VAL"}]}}}';
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> inputMap1 = new Map<String, Object>();
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        Test.startTest();
        new MCOnline_DeleteAgreementServiceRecord ().invokeMethod('madamIntegration',inputMap,outputMap,options);
        new MCOnline_DeleteAgreementServiceRecord ().invokeMethod('madamIntegration',inputMap,outputMap,options);
        new MCOnline_DeleteAgreementServiceRecord ().invokeMethod('madamIntegration',inputMap1,outputMap,options);
        Test.stopTest();
    }
}