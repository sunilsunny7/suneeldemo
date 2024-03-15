@isTest
public class MC_FunctionAgreementJobTest 
{
    @testSetup
    static void initTestData() 
    {
        Account acc=Test_DataFactory.createOneSMEAccount();
        acc.Org_Nr__c = '5566765813';
        acc.C2B_Org_nr__c = '165566765813';
        acc.TSCID__c = '7000351987';
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
        
        MC_Function_Agreement__c fr = new MC_Function_Agreement__c();
        fr.MC_Agreement_Id__c = '634';
        fr.MC_Agreement_Name__c = 'ft AB';
        fr.MC_Agreement_Number__c = '113868';
        fr.MC_Category_Id__c = 'functionmobileextension';
        fr.MC_Customer_Identification_Number__c = '165566765813';
        fr.MC_TSCID__c = '7000351987';
        insert fr;
    }
    @istest
    static void checkAgreementTest()
    {
        Test.startTest();
        Database.executeBatch(new MC_FunctionAgreementJob(), 1);
        new MC_FunctionAgreementJob().execute(null);
        new MC_FunctionAgreementJob().finish(null);
        Test.stopTest();
    }
}