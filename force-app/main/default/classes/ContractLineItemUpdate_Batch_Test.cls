@isTest public class ContractLineItemUpdate_Batch_Test {
	@testSetup
    static void initTestData() {
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
       /* Account acc = new Account();
        acc.Name='TestAccount';
        acc.Org_Nr__c =  '1234567890';
        acc.TSCID__c = 'TSCID5609';
        Insert acc;*/
        Account acc = Test_DataFactory.createOneAccount();
        insert acc;
        
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Active';        
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;        
        insert contr;
        
       Product2 pr = new Product2();
        pr.Name = 'Old Product';
        pr.ProductCode = 'OLD_PRODUCT';
        pr.IsActive = true;
        pr.vlocity_cmt__Status__c = 'Active';
        insert pr;
        
        Product2 pr1 = new Product2();
        pr1.Name = 'New Product';
        pr1.ProductCode = 'NEW_PRODUCT';
        pr1.IsActive = true;
        pr1.vlocity_cmt__Status__c = 'Active';
        insert pr1;
        
        vlocity_cmt__ContractLineItem__c cli=new vlocity_cmt__ContractLineItem__c();
        cli.name='Office';
        cli.vlocity_cmt__product2id__c=pr.id;
        cli.vlocity_cmt__ContractId__c=contr.id;
        cli.TeliaSE_MC_Customer_Requested_Percentage__c=5;
        cli.TeliaSE_End_Date__C=System.today().addDays(10);
        cli.TeliaSE_ProductHierarchy__c='ABC';
        cli.TeliasSETargetPercentage__c=5;
        cli.TeliaSE_SubsidisedVoice__c = 'No';
        cli.vlocity_cmt__RecurringCharge__c=200;
        cli.TeliaSE_ProductHierarchy__c = (String)pr.Id;
        cli.vlocity_cmt__PricingLogData__c = (String)pr.Id;
        insert cli;
    }
    @isTest static void TestCase()
    {
        Boolean flag = true;
        List<vlocity_cmt__ContractLineItem__c> citem = new List<vlocity_cmt__ContractLineItem__c>();
        citem = [select id from vlocity_cmt__ContractLineItem__c];
        new ContractLineItemUpdate_Batch(citem,flag);
        new ContractLineItemUpdate_Batch(citem,flag).start(null);
        new ContractLineItemUpdate_Batch(citem,flag).execute(null,citem);
        new ContractLineItemUpdate_Batch(citem,flag).finish(null);
    }
}