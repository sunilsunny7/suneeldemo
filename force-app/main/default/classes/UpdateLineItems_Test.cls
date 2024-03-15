@isTest
public class UpdateLineItems_Test {
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
        
        /*Opportunity opp = new Opportunity();
        opp.Name = 'Demo';
        opp.Dealer__c = 'No';
        opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
        opp.CloseDate = system.today().addDays(10);
        opp.StageName = 'Kvalificera';
        opp.AccountId = acc.id;
        insert opp;*/
        
        Opportunity opp = Test_DataFactory.createSmeOpportunity();
        opp.AccountId = acc.Id;
        opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
        opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
        opp.Kammarkollegiet__c = 'Kammarkollegiet';
        opp.Expected_Opportunity_Type__c = 'abc';
        insert opp;
        
        Quote qu = new Quote();       
        qu.OpportunityId = opp.id;
        qu.Name = 'Dummy';
        qu.Pricebook2Id = stdPriceBookRecId;
        insert qu;
        
        PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = pr.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            insert objpricebookentry;
        
        QuoteLineItem ql = new QuoteLineItem();
        ql.QuoteId = qu.id;
        ql.vlocity_cmt__product2id__c = pr.id;
        ql.vlocity_cmt__InCartQuantityMap__c = (String)pr.Id;
        ql.vlocity_cmt__ProductHierarchyPath__c = (String)pr.Id;
        ql.PricebookEntryId = objpricebookentry.id;
        ql.Quantity = 1;
        ql.UnitPrice = 200;
        ql.Product2Id = pr.id;
       	insert ql;
                       
    }
   
    @isTest static void changeProductTestCase()
    {
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        inputMap.put('oldProductCode','OLD_PRODUCT');
        inputMap.put('newProductCode','NEW_PRODUCT');
     	UpdateLineItems prod= new UpdateLineItems();    
    	new UpdateLineItems().invokeMethod('changeProduct',inputMap,outMap,options);
    }
    @isTest static void invalidCode1()
    {
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        inputMap.put('oldProductCode','wrong_code');
        inputMap.put('newProductCode','NEW_PRODUCT');
     	UpdateLineItems prod= new UpdateLineItems();    
    	new UpdateLineItems().invokeMethod('changeProduct',inputMap,outMap,options);
    }
    @isTest static void invalidCode2()
    {
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        inputMap.put('oldProductCode','OLD_PRODUCT');
        inputMap.put('newProductCode','wrong_code');
     	UpdateLineItems prod= new UpdateLineItems();    
    	new UpdateLineItems().invokeMethod('changeProduct',inputMap,outMap,options);
    }
    
     
}