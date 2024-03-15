@isTest
public with sharing class MCOnline_ActivateAgreements_Test {
    @testSetup
    static void initTestData() 
    {
        Account acc=Test_DataFactory.createOneSMEAccount();
        acc.Org_Nr__c = '5566765813';
        acc.C2B_Org_nr__c = '165566765813';
        insert acc;


        RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='MFA ReadOnly'];
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
    }

    @isTest
    static void testActivateBatch(){
        Test.startTest();
        Database.executeBatch(new MCOnline_ActivateAgreements(null,new Set<String>{'113868'},null,null), 1);
        Test.stopTest();
    }
}