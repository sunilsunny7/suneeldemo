@isTest
public class Test_TeliaSE_CreateUtilizerBatchContract{

@isTest static void executeMethod(){
        User salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        
        //System.runAs(salesManager){
            Account acc=Test_DataFactory.createOneSMEAccount();
            insert acc;
            
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;
            contract.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();
            insert contract;
            
            List<Account> listofaccount = new List<Account>();
            Account acc1 = Test_DataFactory.createOneKundkontoAccount();
            acc1.Business_Unit__c = 'SME';
            acc1.Is_Owner_Changed__c = system.today();
            acc1.FA_Contract__c=contract.id;
            acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SME/SOHO Organisation').getRecordTypeId();
            acc1.TeliaSE_Utilzer_Role__c = 'Utilizer';
            listofaccount.add(acc1);
            
            Account acc2 = new Account(Name='TestAccount 123');
            //acc2.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);
            acc2.Business_Unit__c = 'SOHO';
            acc2.Kundkonto_Nr__c = 'abc' + 00;
            acc2.FA_Contract__c=contract.id;
            acc2.TeliaSE_Utilzer_Role__c = 'Utilizer';
            acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SME/SOHO Organisation').getRecordTypeId();
            listofaccount.add(acc2);
            
            insert listofaccount;
            
            Test.startTest();
            TeliaSE_CreateUtilizerBatchContract obj = new TeliaSE_CreateUtilizerBatchContract();
            DataBase.executeBatch(obj);             
            Test.stopTest();  
        //}
    }
}