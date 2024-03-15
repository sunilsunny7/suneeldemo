@isTest
public class MC_UpdateCliPriceTest 
{
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
        insert contract;
        
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
    }
    @istest
    static void updatePriceTest1()
    {
        Test.startTest();
        Database.executeBatch(new MC_UpdateCliPrice(), 1);
        new MC_UpdateCliPrice().execute(null);
        new MC_UpdateCliPrice().finish(null);
        Test.stopTest();
    }
    
}