@isTest public class OrderDetailsTest {
    
    @isTest static void invokeTrigger(){
        User salesManager;
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        Account acc = new Account();
        acc.Name='TestAccount';
        acc.Org_Nr__c =  '1234567890';
        acc.TSCID__c = 'TSCID5609';
        //acc.CreatedDate = Date.today().addDays(-30);
        Insert acc;
        System.debug('acc.id'+acc.id);
        
        RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Draft';
        contr.Agreement_Nr__c = '11100491';
        contr.recordtypeId = rt1.id;       
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;        
        insert contr;
        contr.Status='Active';
        System.runAs(salesManager){update contr;}
        
        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';
        order.AccountId = acc.Id;  
        order.ContractId = contr.Id;
               
        Test.startTest();
        Database.SaveResult result = Database.insert(order, false);
        Database.DeleteResult result1 = Database.delete(order, false);        
        Test.stopTest();
    }
}