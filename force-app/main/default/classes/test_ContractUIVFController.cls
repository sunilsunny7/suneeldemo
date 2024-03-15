@istest
public class test_ContractUIVFController {
    
    @isTest static void testContractUIVFmethod() {
    
        Account acc = Test_DataFactory.createOneAccount();
        acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
        insert acc; 

        List<Contract> listofcontracts = new List<Contract>();
        
        Contract cont = new Contract();
        cont.Type_of_Agreement__c = 'Cygate leveransavtal';
        cont.Status = 'Draft';
        cont.AccountId = acc.Id;
        cont.ContractTerm = 1;
        cont.StartDate = system.today()-180;
        cont.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.Contract_TELIA);
        cont.Reminder_Days_Before__c = '90';
        listofcontracts.add(cont);
        
        Contract cont1 = new Contract();
        cont1.Type_of_Agreement__c = 'Cygate leveransavtal';
        cont1.Status = 'Draft';
        cont1.AccountId = acc.Id;
        cont1.ContractTerm = 36;
        cont1.StartDate = system.today()-1;
        cont1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.Contract_TELIA);
        cont1.Reminder_Days_Before__c = '90';
        listofcontracts.add(cont1);
        
        Test.startTest();
        insert listofcontracts;
                
        Apexpages.StandardController controller = new Apexpages.StandardController(acc);
        ApexPages.currentPage().getParameters().put('accId',acc.id);
        
        ContractUIVFController  contcontroller = new ContractUIVFController(controller);
        contcontroller.refresh();
        contcontroller.setError();
     //   ContractUIVFController.createProspect(cont.id,SEUtility.getPriceBookId(SEUtility.PRICEBOOK_CYGATE));
       // ContractUIVFController.createCygateOpportunity(cont.id,SEUtility.getPriceBookId(SEUtility.PRICEBOOK_CYGATE));
        ContractUIVFController.createSmeOpportunity(cont.id);
        ContractUIVFController.createSmeQuickOpportunity(cont.id);
        ContractUIVFController.deleteContract(cont.id);
        ContractUIVFController.createContract(acc.id);
        Test.stopTest();
      //  ContractUIVFController.createProspect(cont1.id,SEUtility.getPriceBookId(SEUtility.PRICEBOOK_CYGATE));
           
    }
     @isTest static void testContractUImethod() {
      Account acc = Test_DataFactory.createOneAccount();
        acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
        insert acc; 

        List<Contract> listofcontracts = new List<Contract>();
        
        Contract cont = new Contract();
        cont.Type_of_Agreement__c = 'Cygate leveransavtal';
        cont.Status = 'Draft';
        cont.AccountId = acc.Id;
        cont.ContractTerm = 36;
        cont.StartDate = system.today()-1;
        cont.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.Contract_TELIA);
        cont.Reminder_Days_Before__c = '90';
        listofcontracts.add(cont);
        Test.startTest();
        insert listofcontracts;
        Test.stopTest();
        ContractUIController.createOpportunity(cont.id);
      //  ContractUIController.createProspect(cont.id);
        ContractUIController.getContracts(acc.id);
        ContractUIController.deleteContract(cont.id);
       }
}