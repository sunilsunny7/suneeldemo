@isTest
public class MC_MadamIntegrationRetryJobTest {
    
    @testSetup
    static void initTestData() 
    {
        List <MC_RAMMFA_Settings__c> RAMMFAList = new List <MC_RAMMFA_Settings__c> ();

        MC_RAMMFA_Settings__c offer1 = new MC_RAMMFA_Settings__c(Name = 'PricePlanCategory', Type_Name__c = 'F1GRUNDAVG', Type__c = 'Price Plan Category');
        RAMMFAList.add(offer1);
        
        MC_RAMMFA_Settings__c offer2 = new MC_RAMMFA_Settings__c(Name = 'SME', Type_Name__c = 'MFA ReadOnly', Type__c = 'Record Type');
        RAMMFAList.add(offer2);
        
        MC_RAMMFA_Settings__c offer3 = new MC_RAMMFA_Settings__c(Name = 'STO', Type_Name__c = 'RAM ReadOnly', Type__c = 'Record Type');
        RAMMFAList.add(offer3);
        
        MC_RAMMFA_Settings__c offer4 = new MC_RAMMFA_Settings__c(Name = 'SubscriptionCode', Type_Name__c = 'TJ', Type__c = 'Subscription Code');
        RAMMFAList.add(offer4);
        
        insert RAMMFAList;
        
        Account acc=Test_DataFactory.createOneSMEAccount();
        acc.Org_Nr__c = '5566765813';
        acc.C2B_Org_nr__c = '165566765813';
        insert acc;
        Map<String, Object> options = new Map<String, Object>();
        String  serviceConNum ='02780846';

        RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='RAM ReadOnly'];
        Contract contract=new Contract();
        contract.Name='Test';
        contract.AccountId=acc.id;
        contract.Status='Draft';
        contract.Solution_Area__c='Vxl';
        contract.StartDate=Date.today();
        contract.ContractTerm=24;
        contract.recordtypeId = rt1.id;
        contract.Agreement_Nr__c = '113868';  
        //contract.ContractNumber ='02780846';
        insert contract;
        options.put(contract.id,serviceConNum);
        
        Product2 prod1 = new Product2();
        prod1.ProductCode = 'AGR_108';
        prod1.Name = 'AGROffer';
        prod1.C2BC_Category__c = 'offerbundle';
        prod1.C2BC_Subcategory__c = '';
        prod1.Family = 'Online Order';
        prod1.IsActive =true;
        prod1.vlocity_cmt__Status__c = 'Active';
        insert prod1;
        
        Product2 prod2 = new Product2();
        prod2.ProductCode = 'AGR_50';
        prod2.Name = '50 GB';
        prod2.C2BC_Category__c = 'mobilevoicesubscription';
        prod2.C2BC_Subcategory__c = 'voice';
        prod2.Family = 'Online Order';
        prod2.IsActive =true;
        prod2.TeliaSE_Subscription_Type__c = 'XÖ';
        prod2.vlocity_cmt__Status__c = 'Active';
        insert prod2;
        
        vlocity_cmt__ContractLineItem__c contr = new vlocity_cmt__ContractLineItem__c();
        contr.vlocity_cmt__Product2Id__c = prod2.Id;
        contr.vlocity_cmt__ContractId__c = contract.Id;
        contr.vlocity_cmt__Quantity__c = 1;
        contr.TeliaSE_SubsidisedVoice__c ='Yes';
        contr.vlocity_cmt__OneTimeCharge__c = 0;
        contr.vlocity_cmt__OneTimeTotal__c = 0;
        contr.vlocity_cmt__RecurringTotal__c = 0;
        contr.vlocity_cmt__RecurringCharge__c = 0;
        insert contr;
        
        MC_AgreementPlanChange__c agr = new MC_AgreementPlanChange__c();
        agr.MC_AgreementNumber__c = '113868';
        agr.MC_PricePlan__c = 'F10000';
        agr.MC_PricePlanCategory__c = 'F1GRUNDAVG';
        agr.MC_PricePlanType__c = 'MOBILL';
        agr.MC_SubscriptionType__c = 'XÖ';
        insert agr;
        
        MC_PrismaPlan__c pri = new MC_PrismaPlan__c();
        pri.MC_Price_Plan__c = 'F10000';
        pri.MC_Price_Plan_Category__c = 'F1GRUNDAVG';
        pri.MC_Agreement_MRC_Price__c = '264.00';
        pri.MC_Agreement_NRC_Price__c = '0.00';
        pri.MC_ServiceCode__c = 'TJ';
        pri.MC_ServiceValue__c = '';
        insert pri;
        
        List<Contract> con = [Select id, ContractNumber from Contract LIMIT 1];
        vlocity_cmt__VlocityErrorLogEntry__c err = new vlocity_cmt__VlocityErrorLogEntry__c();
        err.vlocity_cmt__ErrorCode__c = 'ERR-501';
        err.vlocity_cmt__ErrorType__c = 'Data Mismatch';
        err.vlocity_cmt__ContextId__c = 'Test-'+String.valueOf(con[0].ContractNumber);
        err.vlocity_cmt__ErrorMessage__c = '{"utilizer":[{"name":"Test_Utilizer","status":"V","organizationNumber":"434545454"}]}';
        err.vlocity_cmt__InputData__c = '{"SetParameter":{"agreementNumber":"113868","serviceContractNumber":"02053337","contractId":null},"operation":"Update","agreement":{"agreementNumber":"113868","agreementVersion":null,"agreementType":"STO","agreementStartDate":"2022-02-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"RAM","agreementType":"STO","agreementStatus":"N","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","serviceContractNumber":"02053928","accountId":"165566765814","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"utilizer":[{"organizationNumber":"5566765813","status":"V","name":"Test_Utilizer"},{"organizationNumber":"55667654","status":"V","name":"Test_Utilizer1"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"}}';
        err.MC_RetryStatus__c = false;
        err.vlocity_cmt__SourceName__c = 'MassCustomized_MadamIntegration';
        insert err;
    }
    @istest
    static void test()
    {
        Test.startTest();
        Database.executeBatch(new MC_MadamIntegrationRetryJob(), 1);
        new MC_MadamIntegrationRetryJob().execute(null);
        new MC_MadamIntegrationRetryJob().finish(null);
        Test.stopTest();
    }
}