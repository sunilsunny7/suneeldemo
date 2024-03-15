@isTest
public class MC_MadamIntegrationQueueableTest {

    @testSetup
    static void initTestData() 
    {
        System.runAs(Test_DataFactory.getByPassUser()){
        Account acc=Test_DataFactory.createOneSMEAccount();
        acc.Org_Nr__c = '5566765813';
        acc.C2B_Org_nr__c = '165566765813';
        insert acc;
        
        Account acc1=Test_DataFactory.createOneSMEAccount();
        acc1.Org_Nr__c = '5566765814';
        acc1.C2B_Org_nr__c = '165566765814';
        insert acc1;
        
        RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
        Contract contract=new Contract();
        contract.Name='Test';
        contract.AccountId=acc.id;
        contract.Status='Draft';
        contract.Solution_Area__c='Vxl';
        contract.StartDate=Date.today();
        contract.ContractTerm=24;
        contract.recordtypeId = rt1.id;
        contract.Agreement_Nr__c = '1000478';        
        insert contract;
        contract.Status='Active';
        update contract;
        
        Contract contract1=new Contract();
        contract1.Name='Test1';
        contract1.AccountId=acc1.id;
        contract1.Status='Draft';
        contract1.Solution_Area__c='Vxl';
        contract1.StartDate=Date.today();
        contract1.ContractTerm=24;
        contract1.recordtypeId = rt1.id;
        contract1.Agreement_Nr__c = '1000479';        
        insert contract1;
        contract1.Status='Active';
        update contract1;
        
        Utilizer_Contract_Relationship__c uti = new Utilizer_Contract_Relationship__c();
        uti.Org_Number__c = '5566765813';
        uti.Name = 'Test_Utilizer';
        uti.ContractNumber__c = contract.Id;
        uti.AccountId__c = acc.Id;
        insert uti;
    }}
    @isTest
    static void test(){
        String methodName= 'manageMadamRequest';
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Test.startTest();
        new MC_MadamIntegrationQueueable(methodName, inputMap, outputMap, options).execute(null);
        Test.stopTest();
    }
    @isTest
    static void test1(){
        List<Contract> conDetails = [Select id, ContractNumber, Agreement_Nr__c, Account.Org_Nr__c from contract where Agreement_Nr__c = '1000478' LIMIT 1];
        Test.startTest();
        new MC_MadamIntegrationQueueable(conDetails[0].ContractNumber, conDetails[0].Agreement_Nr__c, conDetails[0].Id, conDetails[0].Account.Org_Nr__c).execute(null);
        Test.stopTest();
    }
}