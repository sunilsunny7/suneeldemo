@isTest
public with sharing class GUIDConverterBatchProcessor_Test {
    
    @testsetup
    static void setup()
    {
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();

        System.runAs(new User(Id = Userinfo.getUserId(),Bypass_VR__c =true)){
        Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.ProductCode='C-OFFICE-365';
            prod.TeliaSE_MC_isCallOff_Flag__c = false;
        insert prod;
            
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        insert prod1;
        pricebookId = stdPriceBookRecId ;
        
        Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        prod2.Name = 'Användarpaket';
        prod2.productCode = 'TPP_PKG';
        prod2.MC_Product_Name_Eng__c='User packages';
        prod2.TeliaSE_Offer_Type__c='Non-SubscriptionOffering';
        insert prod2;
       
        Account acc=Test_DataFactory.createOneSMEAccount();
        insert acc;
            
        Opportunity opp = Test_DataFactory.createSmeOpportunity();
        opp.AccountId = acc.Id;
        opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
        opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
        opp.Kammarkollegiet__c = 'Kammarkollegiet';
        opp.Expected_Opportunity_Type__c = 'abc';
        insert opp;

       
         PricebookEntry objpricebookentry =new PricebookEntry();
         objpricebookentry.Product2ID = prod.id;
         objpricebookentry.Pricebook2ID = stdPriceBookRecId;
         objpricebookentry.UnitPrice=23.50;
         objpricebookentry.UseStandardPrice=false;
         objpricebookentry.isActive=true;//Add this line
         insert objpricebookentry;
         
         PricebookEntry objpricebookentry1 =new PricebookEntry();
         objpricebookentry1.Product2ID = prod2.id;
         objpricebookentry1.Pricebook2ID = stdPriceBookRecId;
         objpricebookentry1.UnitPrice=23.50;
         objpricebookentry1.UseStandardPrice=false;
         objpricebookentry1.isActive=true;//Add this line
         insert objpricebookentry1;
            
        String masterQuote=System.Label.TeliaSE_Master_quote;
        
        Quote qut1 = new Quote();
        qut1.Name='Master Quote';
        qut1.status = 'Draft';
        qut1.opportunityId = opp.id;
        qut1.Pricebook2ID = stdPriceBookRecId;
        qut1.TeliaSE_Approval_Flag__c = False; 

        qut1.TeliaSE_Type__c='Renegotiation';
        qut1.TeliaSE_MC_Sales_Flow_Identifier__c='New Sales';

        insert qut1; 
        Quote qut = new Quote();
        qut.Name='Test Quote';
        qut.status = 'Draft';

        qut.TeliaSE_Type__c='Renegotiation';
        qut.opportunityId = opp.id;
        qut.Pricebook2ID = stdPriceBookRecId;
        qut.TeliaSE_Approval_Flag__c = False;        

        qut.TeliaSE_MC_Sales_Flow_Identifier__c='Omforhandling';
        insert qut;
        
            Test.startTest();
        QuoteLineItem oli3 = new QuoteLineItem();
        oli3.PricebookEntryId = objpricebookentry.Id;
        oli3.TeliaSE_MC_Customer_Requested_Percentage__c=10;
        oli3.QuoteId = qut.id;
        oli3.UnitPrice = 200;
        oli3.Quantity = 4;
        oli3.vlocity_cmt__Product2Id__c = prod.id;
        oli3.Product2Id = prod.id;
        oli3.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
        oli3.TeliaSE_Approved__c = null;
        oli3.vlocity_cmt__RecurringCharge__c  = 200;
        oli3.TeliaSE_Ceiling_Price__c = 400;
        oli3.TeliaSE_Root_Product__c=prod.id;
        insert oli3;    
            
            oli3.vlocity_cmt__RootItemId__c = oli3.id;
            update oli3;
            
        QuoteLineItem oli1 = new QuoteLineItem();
        oli1.PricebookEntryId = objpricebookentry.Id;
        oli1.QuoteId = qut.id;
        oli1.TeliaSE_MC_Customer_Requested_Percentage__c=10;
        oli1.UnitPrice = 200;
        oli1.Quantity = 4;
        oli1.Product2Id = prod.id;
        oli1.vlocity_cmt__Product2Id__c = prod.id;
        oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
        oli1.TeliaSE_Approved__c = null;
        oli1.vlocity_cmt__RecurringCharge__c  = 200;
        oli1.TeliaSE_Ceiling_Price__c = 400;
        oli1.TeliaSE_Root_Product__c=prod.id;
        insert oli1;
            
            oli1.vlocity_cmt__RootItemId__c = oli1.id;
            update oli1;
            
        QuoteLineItem oli2 = new QuoteLineItem();
        oli2.PricebookEntryId = objpricebookentry.Id;
        oli2.QuoteId = qut.id;
        oli2.UnitPrice = 200;
        oli2.Quantity = 4;
        oli2.TeliaSE_MC_Customer_Requested_Percentage__c=10;
        oli2.Product2Id = prod.id;
        oli2.vlocity_cmt__Product2Id__c = prod.id;    
        oli2.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
        oli2.TeliaSE_Approved__c = null;
        oli2.vlocity_cmt__RecurringCharge__c  = 200;
        oli2.TeliaSE_Ceiling_Price__c = 400;
        oli2.TeliaSE_Root_Product__c=prod.id;
            oli2.vlocity_cmt__RootItemId__c = oli1.id;
            oli2.vlocity_cmt__ParentItemId__c = oli1.Id;
        insert oli2;
        
            
            //Master Quote Line Items 
            QuoteLineItem oli4 = new QuoteLineItem();
            oli4.PricebookEntryId = objpricebookentry.Id;
            oli4.QuoteId = qut1.id;
            oli4.UnitPrice = 200;
            oli4.Quantity = 4;
            oli4.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli4.Product2Id = prod.id;
            oli4.vlocity_cmt__Product2Id__c = prod.id;    
            oli4.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli4.TeliaSE_Approved__c = null;
            oli4.vlocity_cmt__RecurringCharge__c  = 200;
            oli4.TeliaSE_Ceiling_Price__c = 400;
            oli4.TeliaSE_Root_Product__c=prod.id;
            insert oli4;
            
            oli4.vlocity_cmt__RootItemId__c = oli4.id;
            update oli4;
            
            QuoteLineItem oli5 = new QuoteLineItem();
            oli5.PricebookEntryId = objpricebookentry.Id;
            oli5.QuoteId = qut1.id;
            oli5.UnitPrice = 200;
            oli5.Quantity = 4;
            oli5.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli5.Product2Id = prod2.id;
            oli5.vlocity_cmt__Product2Id__c = prod2.id;    
            oli5.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli5.TeliaSE_Approved__c = null;
            oli5.vlocity_cmt__RecurringCharge__c  = 200;
            oli4.TeliaSE_Ceiling_Price__c = 400;
            oli4.TeliaSE_Root_Product__c=prod2.id;
            insert oli5;
       
        }

    }
    @isTest
    static void testGUID()
    {
        Test.startTest();
        Database.executeBatch(new GUIDConverterBatchProcessor('Quote',GUIDConverterBatchProcessor.Options.COUNT_ONLY,null,10));
        Test.stopTest();
    }
    
    @isTest
    static void testGUID2()
    {
        Test.startTest();
        Database.executeBatch(new GUIDConverterBatchProcessor('Quote',GUIDConverterBatchProcessor.Options.CONVERT,null,null));
        Test.stopTest();

    }
    @isTest
    static void testGUID3()
    {
        Test.startTest();
        Database.executeBatch(new GUIDConverterBatchProcessor('Quote',GUIDConverterBatchProcessor.Options.CONVERT,null,null));
        Test.stopTest();

    }
    @isTest
    static void testGUID4()
    {
        Test.startTest();
        Database.executeBatch(new GUIDConverterBatchProcessor('Quote',GUIDConverterBatchProcessor.Options.CONVERT, new Map<Id,QuoteLineItem>([select id from QuoteLineItem]).keySet(),null));
        Test.stopTest();
    }
    
    @isTest
    static void testGUID5()
    {
        GUIDConverterBatchProcessor obj=new GUIDConverterBatchProcessor('Quote',GUIDConverterBatchProcessor.Options.COUNT_ONLY,null,null);
        obj.needConvertingContainerIdList=new List<Id>(new Map<Id,QuoteLineItem>([select id from QuoteLineItem]).keySet());
        obj.getSupplyIdsOnlyResultDescription();
    }
    
    @isTest
    static void testGUID6()
    {
        GUIDConverterBatchProcessor obj=new GUIDConverterBatchProcessor('Quote',GUIDConverterBatchProcessor.Options.COUNT_ONLY,null,null);
        try{
            Integer i=1/0;
        }
        catch(Exception e){
        obj.handleAnalysisException(e,null);
        obj.handleConversionException(e,null);
        }
    }
    
    
    @isTest
    static void testGUID7()
    {
        GUIDConverterBatchProcessor obj=new GUIDConverterBatchProcessor('Quote',GUIDConverterBatchProcessor.Options.COUNT_ONLY,null,null);
        try{
            obj.throwException('sfsdf');
            }catch(exception e)
            {}
    }
    
    @isTest
    static void testGUID8()
    {

        GUIDConverterBatchProcessor obj=new GUIDConverterBatchProcessor('Quote',GUIDConverterBatchProcessor.Options.COUNT_ONLY,null,null);
        obj.analysisErrorContainerIdList=new List<Id>(new Map<Id,QuoteLineItem>([select id from QuoteLineItem]).keySet());
        obj.getCountResultDescription();

    }
    
}