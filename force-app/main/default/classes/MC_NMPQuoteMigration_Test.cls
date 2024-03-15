@isTest
public class MC_NMPQuoteMigration_Test {
 @testSetup static void testDataSetup(){
        User salesManager;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
     
        vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
        objClass.Name = 'Mobile Offer Specification';    
        objClass.vlocity_cmt__IsActive__c = True;
        objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass;
        
        vlocity_cmt__ObjectClass__c objClass2 = new vlocity_cmt__ObjectClass__c();
        objClass2.Name = 'Virtual Offer Products';    
        objClass2.vlocity_cmt__IsActive__c = True;
        objClass2.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass2;
     
        List<Product2> prodList = new List<Product2>();
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod.Name = 'Speical addon group';
        prod.ProductCode = 'MOB_SP_ADDON_ABROAD_MAX';
        prodList.add(prod);
        
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod1.Name = 'Kluster Large';
       prod1.ProductCode = 'MOB_SP_ADDON_ABROAD';
        prodList.add(prod1);
        
        insert prodList;
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        Opportunity opp = new Opportunity();
        System.runAs(salesManager){
            
            opp.Name='opp1';
            opp.CloseDate = System.today();
            opp.StageName='Kvalificera';  
            opp.Pricebook2Id=Test.getStandardPricebookId();
            opp.TeliaSE_SharingSetting_Flag__c = false;
            insert opp;
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            insert objpricebookentry;
            
            PricebookEntry objpricebookentry2 =new PricebookEntry();
            objpricebookentry2.Product2ID = prod1.id;
            objpricebookentry2.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry2.UnitPrice=23.50;
            objpricebookentry2.UseStandardPrice=false;
            objpricebookentry2.isActive=true;//Add this line
            insert objpricebookentry2;
            
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';  
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;
            qut.TeliaSE_MC_Sales_Flow_Identifier__c = 'New Sales';
            insert qut;
            
            
            List<QuoteLineItem> qliList = new List<QuoteLineItem>();
            QuoteLineItem oli = new QuoteLineItem();
            oli.QuoteId = qut.Id;
            oli.Product2Id = prod1.Id;
          oli.vlocity_cmt__Product2Id__c = prod1.id;
            oli.PricebookEntryId = objpricebookentry2.Id;
            oli.TeliaSE_MC_FACallOffQuantity__c = 2;
            oli.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id);
            oli.UnitPrice = 0;
            oli.TeliaSE_ParentClusterCode__c = 'large';
            oli.Quantity = 1;
            qliList.add(oli);
            
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.QuoteId = qut.Id;
            oli1.Product2Id = prod1.Id;
           oli1.vlocity_cmt__Product2Id__c = prod1.id;
            oli1.PricebookEntryId = objpricebookentry2.Id;
            oli1.TeliaSE_MC_FACallOffQuantity__c = 2;
            oli1.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id);
            oli1.UnitPrice = 0;
            oli1.TeliaSE_ParentClusterCode__c = 'small';
            oli1.Quantity = 1;
            qliList.add(oli1);
            
            insert qliList;

        }
    }
    
     @isTest
    private static void testMethod1(){
        List<Quote> quoteList = [Select id from quote where name='Test Quote' LIMIT 1];
         List<PriceBookentry> pbe = [select id,Product2.Name,Product2.ProductCode from PricebookEntry ];
        system.debug('pbe_'+pbe);
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();   
        Map<String,Object> options=new Map<String,Object>();
        
        inputMap.put('QuoteId',quoteList[0].Id);
        
        Test.startTest();
        
        MC_NMPQuoteMigration obj=new MC_NMPQuoteMigration();        
        obj.invokeMethod('buildRequestMap',inputMap,outMap,options);
        
        Test.stopTest();
    }
    
}