@isTest
public class MC_ErrorLogDeleteJobTest 
{
    @testSetup
    static void initTestData() 
    {
        vlocity_cmt__VlocityErrorLogEntry__c err = new vlocity_cmt__VlocityErrorLogEntry__c();
        err.vlocity_cmt__ErrorCode__c = 'ERR-501';
        err.vlocity_cmt__ErrorType__c = 'Data Mismatch';
        err.vlocity_cmt__ContextId__c = '389457935';
        err.vlocity_cmt__ErrorMessage__c = '{"utilizer":[{"name":"Test_Utilizer","status":"V","organizationNumber":"434545454"}]}';
        err.vlocity_cmt__InputData__c = '{"SetParameter":{"agreementNumber":"113868","serviceContractNumber":"02053337","contractId":null},"operation":"Update","agreement":{"agreementNumber":"113868","agreementVersion":null,"agreementType":"STO","agreementStartDate":"2022-02-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"RAM","agreementType":"STO","agreementStatus":"N","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","serviceContractNumber":"02053928","accountId":"165566765814","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"utilizer":[{"organizationNumber":"5566765813","status":"V","name":"Test_Utilizer"},{"organizationNumber":"55667654","status":"V","name":"Test_Utilizer1"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"}}';
        err.MC_RetryStatus__c = false;
        err.vlocity_cmt__SourceName__c = 'MassCustomized_MadamIntegration';
        insert err;
    }
    @istest
    static void testDuplicateAgreement()
    {
        List<vlocity_cmt__VlocityErrorLogEntry__c> error= [Select id from vlocity_cmt__VlocityErrorLogEntry__c];
        Test.startTest();
        new MC_ErrorLogDeleteJob().execute(null, error);
        new MC_ErrorLogDeleteJob().start(null);
        new MC_ErrorLogDeleteJob().finish(null);
        new MC_ErrorLogDeleteJob().execute(null);
        Test.stopTest();
    }
}