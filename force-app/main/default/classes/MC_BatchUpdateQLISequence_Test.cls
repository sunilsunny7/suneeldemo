@isTest
private class MC_BatchUpdateQLISequence_Test {
    
    @testSetup
    private static void testSetup(){
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
        objClass.Name = 'Mobile Offer Specification';    
        objClass.vlocity_cmt__IsActive__c = True;
        objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass;
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod.Name = 'Mobilupplägg All-IN+';
        prod.ProductCode = 'MOB_MULTI_ALL_IN_PLUS_V3';
        prodList.add(prod);
        
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod1.Name = 'Jobbmobil 7 GB';
        prod1.ProductCode = 'MOB_MULTI_123';
        prodList.add(prod1);
        insert prodList;
        
        vlocity_cmt__ProductChildItem__c pci1 = new vlocity_cmt__ProductChildItem__c();
        pci1.vlocity_cmt__ParentProductId__c = prod.Id;
        pci1.vlocity_cmt__ChildProductId__c = prod1.Id;
        pci1.Name = 'Test PCI1';
        pci1.vlocity_cmt__Quantity__c = 1;
        pci1.vlocity_cmt__MinQuantity__c = 1;
        pci1.vlocity_cmt__MaxQuantity__c = 25;
        pci1.vlocity_cmt__IsRootProductChildItem__c = false;
        pci1.vlocity_cmt__IsOverride__c = false;
        pci1.vlocity_cmt__ChildLineNumber__c = '10';
        insert pci1;
        
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
        
        Opportunity opp = new Opportunity();
        opp.Name='opp1';
        opp.CloseDate = System.today();
        opp.StageName='Kvalificera';  
        opp.Pricebook2Id=Test.getStandardPricebookId();
        opp.TeliaSE_SharingSetting_Flag__c = false;
        insert opp;
        Id recId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Contract Quote').getRecordTypeId();
        Quote qut = new Quote();
        qut.Name='Test Quote';
        qut.status = 'Draft';  
        qut.opportunityId = opp.id;
        qut.Pricebook2ID = stdPriceBookRecId;
        qut.TeliaSE_Approval_Flag__c = False;
        qut.TeliaSE_MC_Sales_Flow_Identifier__c = 'New Sales';
        qut.RecordTypeId = recId;
        insert qut;
        
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        QuoteLineItem oli = new QuoteLineItem();
        oli.QuoteId = qut.Id;
        oli.Product2Id = prod.Id;
        oli.vlocity_cmt__Product2Id__c = prod.id;
        oli.PricebookEntryId = objpricebookentry.Id;
        oli.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod.Id);
        oli.UnitPrice = 0;
        oli.Quantity = 1;
        insert oli;
        
        QuoteLineItem oli1 = new QuoteLineItem();
        oli1.QuoteId = qut.Id;
        oli1.Product2Id = prod1.Id;
        oli1.vlocity_cmt__ParentItemId__c = oli.Id;
        oli1.vlocity_cmt__Product2Id__c = prod1.id;
        oli1.PricebookEntryId = objpricebookentry2.Id;
        oli1.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod.Id)+'<'+String.valueOf(prod1.Id);
        oli1.UnitPrice = 0;
        oli1.Quantity = 1;
        insert oli1;
    }
    
    @isTest
    private static void testMethod1(){
       
        Test.startTest();
        MC_BatchUpdateQLISequence bs = new MC_BatchUpdateQLISequence();
        Id batchID = Database.executeBatch(bs,100);
        Test.stopTest();
    }
}