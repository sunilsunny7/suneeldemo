@isTest
public class Test_Fiber_ContractProductMigration {
    @testSetup 
 static void setup()
    {
        User sysAdmin;
  System.runAs(new User(Id = Userinfo.getUserId())){
            sysAdmin = Test_DataFactory.createSalesManagerUsers(1)[0];
            sysAdmin.Bypass_VR__c = true;
            sysAdmin.Telia_Id__c = 'pqr123';
            insert sysAdmin;
        }

        List<FiberDiscountMandate__c >allrecords = new List<FiberDiscountMandate__c >();
        FiberDiscountMandate__c fbrrecdrkt = new FiberDiscountMandate__c();
        fbrrecdrkt .name='Director';
        fbrrecdrkt .EBIT_Max_Mandate__c = 0;
        fbrrecdrkt .EBIT_Min_Mandate__c= 25;
        fbrrecdrkt .ProductDiscountMaxMandate__c= 0;
        fbrrecdrkt .ProductDiscountMinMandate__c= 20;
        fbrrecdrkt .Role__c= 'Fiber Sales Director';
        allrecords.add(fbrrecdrkt);
        
        FiberDiscountMandate__c fbrrecMrg = new FiberDiscountMandate__c();
        fbrrecMrg.name='Manager';
        fbrrecMrg.EBIT_Max_Mandate__c = 0;
        fbrrecMrg.EBIT_Min_Mandate__c= 25;
        fbrrecMrg.ProductDiscountMaxMandate__c= 100;
        fbrrecMrg.ProductDiscountMinMandate__c= 0;
        fbrrecMrg.Role__c= 'Fiber Sales Manager New Sales';
        allrecords.add(fbrrecMrg);
        
        FiberDiscountMandate__c fbrrecSrep = new FiberDiscountMandate__c();
        fbrrecSrep.name='SalesRep';
        fbrrecSrep.EBIT_Max_Mandate__c = 30;
        fbrrecSrep.EBIT_Min_Mandate__c= 0;
        fbrrecSrep.ProductDiscountMaxMandate__c= 11;
        fbrrecSrep.ProductDiscountMinMandate__c= 0;
        fbrrecSrep.Role__c= 'Fiber Sales Rep New Sales';
        allrecords.add(fbrrecSrep);
        
        
        insert allrecords;


System.RunAs(sysAdmin)
{     
        List<vlocity_cmt__ContractLineItem__c> cline = new List<vlocity_cmt__ContractLineItem__c>();
        Id AccRtid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Account acct = new Account(Name='Batch Test Account', recordtypeid = AccRtid);
        Id Rtid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Real Estate Fiber').getRecordTypeId();
        insert acct;
        
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        insert prod;
        prod.vlocity_cmt__SpecificationType__c = 'Product';
        prod.ProductCode = 'MDU_CollIPTV_Start_1707';
        update prod;
        
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        insert prod1;
        prod1.ProductCode = 'MDU_HW_MC_1729';
        update prod1;
        
        Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        insert prod2;
        prod2.ProductCode = 'Property Network Hardware Service Bundle';
        update prod2;
        
        Product2 prod3 = Test_DataFactory.createProducts(1)[0];
        insert prod3;
        prod3.vlocity_cmt__SpecificationType__c = 'offer';
        prod3.TeliaSE_Offer_Type__c = 'Non-SubscriptionOffering';
        prod3.ProductCode = 'MDU_IPTV_LL_Service_Bundle';
        update prod3;
    
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        Id pricebookId = stdPriceBookRecId ;
        Opportunity opp = new Opportunity();
        opp.Name='opp1';
        opp.CloseDate = System.today();
        opp.StageName='Needs Analysis';  
        opp.Pricebook2Id=Test.getStandardPricebookId();
        opp.TeliaSE_SharingSetting_Flag__c = false;
        opp.RecordTypeId = Rtid;
        insert opp;
        system.debug('recordtype'+ opp.RecordTypeId);
    
         PricebookEntry objpricebookentry =new PricebookEntry();
         objpricebookentry.Product2ID = prod.id;
         objpricebookentry.Pricebook2ID = stdPriceBookRecId;
         objpricebookentry.UnitPrice=23.50;
         objpricebookentry.UseStandardPrice=false;
         objpricebookentry.isActive=true;//Add this line
         insert objpricebookentry;
         
    PricebookEntry objpricebookentry1 =new PricebookEntry();
         objpricebookentry1.Product2ID = prod1.id;
         objpricebookentry1.Pricebook2ID = stdPriceBookRecId;
         objpricebookentry1.UnitPrice=23.50;
         objpricebookentry1.UseStandardPrice=false;
         objpricebookentry1.isActive=true;//Add this line
         insert objpricebookentry1;
        
        Quote qut = new Quote();
        qut.Name='Test Quote';
        qut.status = 'Draft';
        qut.Recordtypeid   = SEUTility.getRecordTypeId('Individual_Quote');
        qut.opportunityId = opp.id;
        qut.Pricebook2ID = stdPriceBookRecId;
        qut.TeliaSE_Approval_Flag__c = False;
        insert qut;
    qut.status = 'Sent For Approval';
        update qut;
        
        qut.status = 'Price Approved';
        update qut;
    
      QuoteLineItem oli1 = new QuoteLineItem();
        oli1.PricebookEntryId = objpricebookentry.Id;
        oli1.QuoteId = qut.id;
        oli1.Quantity = 4;
        oli1.Product2Id = prod.id;
        oli1.UnitPrice = 200;
        oli1.vlocity_cmt__Filter__c = null;
        oli1.vlocity_cmt__ParentItemId__c = null;
        oli1.vlocity_cmt__RootItemId__c = null;
        oli1.TeliaSE_Root_Product__c = null;
        insert oli1;
    QuoteLineItem oli2 = new QuoteLineItem();
        oli2.PricebookEntryId = objpricebookentry.Id;
        oli2.QuoteId = qut.id;
        oli2.Quantity = 4;
        oli2.vlocity_cmt__Product2Id__c = prod2.id;
        oli2.UnitPrice = 200;
        oli2.vlocity_cmt__Filter__c = null;
        oli2.vlocity_cmt__ParentItemId__c = null;
        oli2.vlocity_cmt__RootItemId__c = null;
        oli2.TeliaSE_Root_Product__c = null;
        insert oli2;
    
    Contract con = new Contract();
    con.Name = 'Test Contract';
    con.status = 'Draft';
    con.AccountId = acct.id;
    con.vlocity_cmt__QuoteId__c = qut.id;
    con.vlocity_cmt__OpportunityId__c = opp.id;
        insert con;
    
        vlocity_cmt__ContractLineItem__c cli1 = new vlocity_cmt__ContractLineItem__c();
         cli1.vlocity_cmt__ContractId__c = con.id;
         cli1.vlocity_cmt__Product2Id__c = prod.id;
         cli1.TeliaSE_ParentItemId__c = null;
         cli1.TeliaSE_RootItemId__c = null;
         cli1.TeliaSE_Root_Product__c = null;
         cli1.TeliaSE_Contract_Line_Notes__c = null;
         insert cli1;
        
    vlocity_cmt__ContractLineItem__c cli2 = new vlocity_cmt__ContractLineItem__c();
         cli2.vlocity_cmt__ContractId__c = con.id;
         cli2.vlocity_cmt__Product2Id__c = prod1.id;
         cli2.TeliaSE_ParentItemId__c = oli1.id;
         cli2.TeliaSE_RootItemId__c = null;
         cli2.TeliaSE_Root_Product__c = null;
         cli2.TeliaSE_Contract_Line_Notes__c = null;
         insert cli2;

    vlocity_cmt__ContractLineItem__c cli3 = new vlocity_cmt__ContractLineItem__c();
         cli3.vlocity_cmt__ContractId__c = con.id;
         cli3.vlocity_cmt__Product2Id__c = prod2.id;
         cli3.TeliaSE_ParentItemId__c = null;
         cli3.TeliaSE_RootItemId__c = null;
         cli3.TeliaSE_Root_Product__c = null;
         cli3.TeliaSE_Contract_Line_Notes__c = null;
    vlocity_cmt__ContractLineItem__c cli4 = new vlocity_cmt__ContractLineItem__c();
         cli4.vlocity_cmt__ContractId__c = con.id;
         cli4.vlocity_cmt__Product2Id__c = prod3.id;
         cli4.TeliaSE_ParentItemId__c = null;
         cli4.TeliaSE_RootItemId__c = null;
         cli4.TeliaSE_Root_Product__c = null;
         cli4.TeliaSE_Contract_Line_Notes__c = null;

        cline.add(cli3);
        cline.add(cli4);
        insert cline;
   
    }  
    }
    static testmethod void test(){  
        Test.startTest();
        Fiber_ContractProductMigration bt = new Fiber_ContractProductMigration();
        Id batchId = Database.executeBatch(bt);
        Test.stopTest();
    }
}