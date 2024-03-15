@isTest
public class MC_HandleAgreementJobTest 
{
    @testSetup
    static void initTestData() 
    {
        Account acc=Test_DataFactory.createOneSMEAccount();
        acc.Org_Nr__c = '5566765813';
        acc.C2B_Org_nr__c = '165566765813';
        insert acc;
        
        RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='RAM ReadOnly'];
        RecordType rt2 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
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
        
        Contract contract1=new Contract();
        contract1.Name='Test';
        contract1.AccountId=acc.id;
        contract1.Status='Draft';
        contract1.Solution_Area__c='Vxl';
        contract1.StartDate=Date.today();
        contract1.ContractTerm=24;
        contract1.recordtypeId = rt1.id;
        contract1.Agreement_Nr__c = '113868';        
        insert contract1;
        
        Contract contract2=new Contract();
        contract2.Name='Test';
        contract2.AccountId=acc.id;
        contract2.Status='Draft';
        contract2.Solution_Area__c='Vxl';
        contract2.StartDate=Date.today();
        contract2.ContractTerm=24;
        contract2.recordtypeId = rt2.id;
        contract2.Agreement_Nr__c = '8736424';        
        insert contract2;
        
        Contract contract3=new Contract();
        contract3.Name='Test';
        contract3.AccountId=acc.id;
        contract3.Status='Draft';
        contract3.Solution_Area__c='Vxl';
        contract3.StartDate=Date.today();
        contract3.ContractTerm=24;
        contract3.recordtypeId = rt1.id;
        contract3.Agreement_Nr__c = '8736424';        
        insert contract3;
    }
    @istest
    static void testDuplicateAgreement()
    {
        List<AggregateResult> aggregate = [Select Agreement_Nr__c from Contract Where (Contract_Record_Type__c IN ('Ramavtal')  AND status != 'Cancelled' AND Mconline_Status__c = null) OR (Contract_Record_Type__c IN ('RAM ReadOnly', 'MFA ReadOnly')) GROUP BY Agreement_Nr__c HAVING COUNT(Agreement_Nr__c) > 1 LIMIT 2000];
        Test.startTest();
        new MC_HandleAgreementJob().execute(null, aggregate);
        new MC_HandleAgreementJob().start(null);
        new MC_HandleAgreementJob().finish(null);
        new MC_HandleAgreementJob().execute(null);
        Test.stopTest();
    }
}