@isTest
public class MC_InactiveUtilizerBatch_Test {
    @testSetup
    static void initTestData() 
    {
        System.runAs(Test_DataFactory.getByPassUser()){
            Account acc=Test_DataFactory.createOneSMEAccount();
            acc.Org_Nr__c = '5566765813';
            acc.C2B_Org_nr__c = '165566765813';
            insert acc;
            
            RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today()+(-2);
            contract.ContractTerm=24;
            contract.recordtypeId = rt1.id;
            contract.Agreement_Nr__c = '1000478';        
            insert contract;
            contract.Status='Active';
            update contract;
            
            Utilizer_Contract_Relationship__c uti = new Utilizer_Contract_Relationship__c();
            uti.Org_Number__c = '5566765813';
            uti.Name = 'Test_Utilizer';
            uti.ContractNumber__c = contract.Id;
            uti.AccountId__c = acc.Id;
            uti.Status__c = 'Aktiv';   
            insert uti;  
        }
    }
    
    @isTest
    static void test(){
        Test.startTest();
        MC_InactiveUtilizerBatch obj = new MC_InactiveUtilizerBatch();
        DataBase.executeBatch(obj,1); 
        Test.stopTest();
    }
}