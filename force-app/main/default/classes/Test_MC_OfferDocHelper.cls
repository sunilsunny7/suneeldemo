@isTest
public with sharing class Test_MC_OfferDocHelper {
    
    testMethod public static void prepareTestData(){
        
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        //Inserting Object Type
        List<vlocity_cmt__ObjectClass__c> objectClassList = new List<vlocity_cmt__ObjectClass__c>();
        vlocity_cmt__ObjectClass__c objectClass1 = new vlocity_cmt__ObjectClass__c();
        objectClass1.Name = 'ITDaaS Offer Spec';    
        objectClass1.vlocity_cmt__IsActive__c = True;
        objectClass1.vlocity_cmt__ObjectApiName__c = 'Product2';
        objectClassList.add(objectClass1);
        
        insert objectClassList;
        
        //Inserting product
        List<Product2> prodList = new List<product2>();
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = objectClass1.Id;
        prod1.ProductCode='ITP_PLUS_USER';
        prod1.name = 'Användare IT-support Plus';
        prodList.add(prod1);
        
        insert prodList;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        PricebookEntry objpricebookentry =new PricebookEntry();
        objpricebookentry.Product2ID = prod1.id;
        objpricebookentry.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry.UnitPrice=23.50;
        objpricebookentry.UseStandardPrice=false;
        objpricebookentry.isActive=true;
        pbeList.add(objpricebookentry);
        
        insert pbeList;
        
        User salesManager;
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager)
        {
            //Insert Account
            Account acc = Test_DataFactory.createOneAccount();
            insert acc; 
            
            //Insert opportunity
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId = acc.id;
            opp.CloseDate = System.today();
            opp.StageName='Kvalificera';  
            opp.Pricebook2Id=Test.getStandardPricebookId();
            opp.TeliaSE_SharingSetting_Flag__c = false;
            insert opp;
            
            //Insert quote
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';  
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;
            qut.TeliaSE_MC_Sales_Flow_Identifier__c = 'New Sales';
            insert qut;
            
            //Insert quoteLineItems
            List<QuoteLineItem> QliList = new List<QuoteLineItem>();
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.QuoteId = qut.Id;
            oli1.Product2Id = prod1.Id;
            oli1.vlocity_cmt__Product2Id__c = prod1.Id;
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.UnitPrice = 0;
            oli1.Quantity = 1;
            oli1.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli1.TeliaSE_Root_Product__c = prod1.Id;
            QliList.add(oli1); 
            
            insert QLIList;
            
        }
    }
    
    @isTest
    static void test_OfferDocumentLineItems() {
        string inputstr = '[{\"parentItemId\":\"root\",\"discountPercentage\":0,\"recPrice\":0,\"recurringCharge\":0,\"objectTypeName\":\"BroadbandStartOfferingSpec\",\"productHierarchyPath\":\"01t08000009Rd3KAAS<01t08000009RcyKAAS\",\"effectiveQty\":1,\"oneTimeCharge\":0,\"QuoteId\":\"0Q05r00000124QPCAY\",\"excludeItem\":false,\"BindingTime\":\"36\",\"RootProduct\":\"01t08000009Rd3KAAS\",\"BaseQuantity\":\"222\",\"Sequencenumber\":1,\"prodId\":\"01t08000009Rd3KAAS\",\"TargetPrice\":0,\"qliId\":\"0QL5r000000eDtaGAE\",\"offerType\":\"AgreementOffering\",\"productType\":\"Price\",\"productCode\":\"CO-BBSTART\",\"assetReferenceId\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\",\"name\":\"BredbandStart\",\"rootItem\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\"},{\"discountPercentage\":0,\"recPrice\":595,\"recurringCharge\":595,\"objectTypeName\":\"BroadbandStartOfferingSpec\",\"productHierarchyPath\":\"01t08000009Rd3KAAS<01t08000009RcyPAAS\",\"effectiveQty\":1,\"oneTimeCharge\":0,\"QuoteId\":\"0Q05r00000124QPCAY\",\"excludeItem\":false,\"RootProduct\":\"01t08000009Rd3KAAS\",\"Sequencenumber\":1,\"prodId\":\"01t08000009RcyPAAS\",\"TargetPrice\":595,\"qliId\":\"0QL5r000000eDtfGAE\",\"offerType\":\"SubscriptionOffering\",\"productType\":\"Price\",\"productCode\":\"CO-BBSTART-10MB\",\"assetReferenceId\":\"86868e8f-540a-578a-87c5-451f87aa9e60\",\"parentItemId\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\",\"faQty\":1,\"name\":\"BredbandStart10Mbit/s\",\"initialOrderQty\":3,\"rootItem\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\"},{\"discountPercentage\":0,\"recPrice\":745,\"recurringCharge\":745,\"objectTypeName\":\"BroadbandStartOfferingSpec\",\"productHierarchyPath\":\"01t08000009Rd3KAAS<01t0800000Adz8GAAR\",\"effectiveQty\":1,\"oneTimeCharge\":0,\"QuoteId\":\"0Q05r00000124QPCAY\",\"excludeItem\":false,\"RootProduct\":\"01t08000009Rd3KAAS\",\"Sequencenumber\":2,\"prodId\":\"01t0800000Adz8GAAR\",\"TargetPrice\":745,\"qliId\":\"0QL5r000000eDtkGAE\",\"offerType\":\"SubscriptionOffering\",\"productType\":\"Price\",\"productCode\":\"CO-BBSTART-50MB\",\"assetReferenceId\":\"5e8a1329-c9e8-aa49-bda9-9d85bbf63e21\",\"parentItemId\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\",\"faQty\":2,\"name\":\"BredbandStart50Mbit/s\",\"initialOrderQty\":2,\"rootItem\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\"},{\"discountPercentage\":0,\"recPrice\":895,\"recurringCharge\":895,\"objectTypeName\":\"BroadbandStartOfferingSpec\",\"productHierarchyPath\":\"01t08000009Rd3KAAS<01t08000009RcyKAAS\",\"effectiveQty\":1,\"oneTimeCharge\":0,\"QuoteId\":\"0Q05r00000124QPCAY\",\"excludeItem\":false,\"RootProduct\":\"01t08000009Rd3KAAS\",\"Sequencenumber\":4,\"prodId\":\"01t08000009RcyKAAS\",\"TargetPrice\":895,\"qliId\":\"0QL5r000000eDtpGAE\",\"offerType\":\"SubscriptionOffering\",\"productType\":\"Price\",\"productCode\":\"CO-BBSTART-100MB\",\"assetReferenceId\":\"6ef1cb7c-b728-ef56-4f73-2628da812cb0\",\"parentItemId\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\",\"faQty\":3,\"name\":\"BredbandStart100Mbit/s\",\"initialOrderQty\":1,\"rootItem\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\"},{\"discountPercentage\":0,\"recPrice\":0,\"recurringCharge\":0,\"objectTypeName\":\"BindingOTCOfferingSpec\",\"productHierarchyPath\":\"01t08000009Rd3KAAS<01t08000009STlPAAW\",\"effectiveQty\":1,\"oneTimeCharge\":0,\"QuoteId\":\"0Q05r00000124QPCAY\",\"excludeItem\":false,\"RootProduct\":\"01t08000009Rd3KAAS\",\"Sequencenumber\":7.5,\"prodId\":\"01t08000009STlPAAW\",\"TargetPrice\":0,\"qliId\":\"0QL5r000000eDtbGAE\",\"offerType\":\"Non-SubscriptionOffering\",\"productType\":\"Price\",\"productCode\":\"CO-BBSTART-BIND\",\"assetReferenceId\":\"c5a5e7d5-6d92-d215-4332-5e835cb32367\",\"parentItemId\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\",\"name\":\"Engångsavgifter\",\"rootItem\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\"},{\"discountPercentage\":0,\"recPrice\":0,\"recurringCharge\":0,\"objectTypeName\":\"BroadbandStartOfferingSpec\",\"productHierarchyPath\":\"01t08000009Rd3KAAS<01t08000009RczJAAS\",\"effectiveQty\":1,\"oneTimeCharge\":0,\"QuoteId\":\"0Q05r00000124QPCAY\",\"excludeItem\":false,\"RootProduct\":\"01t08000009Rd3KAAS\",\"Sequencenumber\":8,\"prodId\":\"01t08000009RczJAAS\",\"TargetPrice\":0,\"qliId\":\"0QL5r000000eDteGAE\",\"offerType\":\"Non-SubscriptionOffering\",\"productType\":\"Price\",\"productCode\":\"CO-BBSTART-OTHER\",\"assetReferenceId\":\"65c71f67-f589-0df6-8947-8aede60a65f3\",\"parentItemId\":\"f2ed22ea-bceb-1586-ee22-74f92bcec352\",\"name\":\"InstallationochÖvrigaTillval\",\"rootItem\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\"},{\"discountPercentage\":0,\"recPrice\":0,\"recurringCharge\":0,\"objectTypeName\":\"BindingOTCOfferingSpec\",\"productHierarchyPath\":\"01t08000009Rd3KAAS<01t08000009STlPAAW<01t08000009STkrAAG\",\"effectiveQty\":1,\"oneTimeCharge\":1995,\"QuoteId\":\"0Q05r00000124QPCAY\",\"excludeItem\":false,\"RootProduct\":\"01t08000009Rd3KAAS\",\"Sequencenumber\":10,\"prodId\":\"01t08000009STkrAAG\",\"TargetPrice\":0,\"qliId\":\"0QL5r000000eDtcGAE\",\"offerType\":\"SubscriptionOffering\",\"productType\":\"Price\",\"productCode\":\"CO-BBSTART-BIND-G1-0M\",\"assetReferenceId\":\"ca7cb13c-83c9-bab6-5945-e8678a32a1c9\",\"parentItemId\":\"c5a5e7d5-6d92-d215-4332-5e835cb32367\",\"name\":\"Engångsavgiftföranslutningar0Mån\",\"rootItem\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\"},{\"discountPercentage\":0,\"recPrice\":0,\"recurringCharge\":0,\"objectTypeName\":\"BindingOTCOfferingSpec\",\"productHierarchyPath\":\"01t08000009Rd3KAAS<01t08000009STlPAAW<01t08000009STkwAAG\",\"effectiveQty\":1,\"oneTimeCharge\":0,\"QuoteId\":\"0Q05r00000124QPCAY\",\"excludeItem\":false,\"RootProduct\":\"01t08000009Rd3KAAS\",\"Sequencenumber\":20,\"prodId\":\"01t08000009STkwAAG\",\"TargetPrice\":0,\"qliId\":\"0QL5r000000eDtdGAE\",\"offerType\":\"SubscriptionOffering\",\"productType\":\"Price\",\"productCode\":\"CO-BBSTART-BIND-G1-24M\",\"assetReferenceId\":\"f2ed22ea-bceb-1586-ee22-74f92bcec352\",\"parentItemId\":\"c5a5e7d5-6d92-d215-4332-5e835cb32367\",\"name\":\"Engångsavgiftföranslutningar24Mån\",\"rootItem\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\"}]';     
        List<MC_OfferDocHelper.qli> qliList = (List<MC_OfferDocHelper.qli>)JSON.deserialize(inputstr,  List<MC_OfferDocHelper.qli>.class);
        Map<String, object> input = new Map<String,object>();
        map<String,Object> output = new map<String,Object>();
        map<String,Object> options = new map<String,Object>();
        input.put('QLI',qliList);
        MC_OfferDocHelper obj = new MC_OfferDocHelper();
        Test.startTest();
        obj.invokeMethod('offerDocumentLineItems',input,output,options);
        Test.stopTest();
    }
    
    @istest
    static void test_simplifiedLineItems(){ 
        CO_BindingOTC__c cus0 = new CO_BindingOTC__c ();
        cus0.ProductCode__c = 'CO-BBSTART-10MB';
        cus0.Code12M__c = 'CO-BBSTART-10MB';
        cus0.Price12M__c = 6000;
        cus0.Name = '0';
        insert cus0;
        CO_BindingOTC__c cus1 = new CO_BindingOTC__c ();
        cus1.ProductCode__c = 'CO-BBSTART-50MB';
        cus1.Code12M__c = 'CO-BBSTART-50MB';
        cus1.Price12M__c = 6000;
        cus1.Name = '1';
        insert cus1;
        CO_BindingOTC__c cus2 = new CO_BindingOTC__c ();
        cus2.ProductCode__c = 'CO-BBSTART-100MB';
        cus2.Code12M__c = 'CO-BBSTART-100MB';
        cus2.Price12M__c = 6000;
        cus2.Name ='2';
        insert cus2;
        
        string inputstr = '[{\"parentItemId\":\"root\",\"discountPercentage\":0,\"recPrice\":0,\"recurringCharge\":0,\"objectTypeName\":\"BroadbandStartOfferingSpec\",\"productHierarchyPath\":\"01t08000009Rd3KAAS<01t08000009RcyKAAS\",\"effectiveQty\":1,\"oneTimeCharge\":0,\"QuoteId\":\"0Q05r00000124QPCAY\",\"excludeItem\":false,\"BindingTime\":\"36\",\"RootProduct\":\"01t08000009Rd3KAAS\",\"BaseQuantity\":\"222\",\"Sequencenumber\":1,\"prodId\":\"01t08000009Rd3KAAS\",\"TargetPrice\":0,\"qliId\":\"0QL5r000000eDtaGAE\",\"offerType\":\"AgreementOffering\",\"productType\":\"Price\",\"productCode\":\"CO-BBSTART\",\"assetReferenceId\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\",\"name\":\"BredbandStart\",\"rootItem\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\"},{\"discountPercentage\":0,\"recPrice\":595,\"recurringCharge\":595,\"objectTypeName\":\"BroadbandStartOfferingSpec1\",\"productHierarchyPath\":\"01t08000009Rd3KAAS<01t08000009RcyPAAS\",\"effectiveQty\":1,\"oneTimeCharge\":0,\"QuoteId\":\"0Q05r00000124QPCAY\",\"excludeItem\":false,\"RootProduct\":\"01t08000009Rd3KAAS\",\"Sequencenumber\":1,\"prodId\":\"01t08000009RcyPAAS\",\"TargetPrice\":595,\"qliId\":\"0QL5r000000eDtfGAE\",\"offerType\":\"SubscriptionOffering\",\"productType\":\"Price\",\"productCode\":\"CO-BBSTART-10MB\",\"assetReferenceId\":\"86868e8f-540a-578a-87c5-451f87aa9e60\",\"parentItemId\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\",\"faQty\":1,\"name\":\"BredbandStart10Mbit/s\",\"initialOrderQty\":3,\"rootItem\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\"},{\"discountPercentage\":0,\"recPrice\":745,\"recurringCharge\":745,\"objectTypeName\":\"BroadbandStartOfferingSpec\",\"productHierarchyPath\":\"01t08000009Rd3KAAS<01t0800000Adz8GAAR\",\"effectiveQty\":1,\"oneTimeCharge\":0,\"QuoteId\":\"0Q05r00000124QPCAY\",\"excludeItem\":false,\"RootProduct\":\"01t08000009Rd3KAAS\",\"Sequencenumber\":2,\"prodId\":\"01t0800000Adz8GAAR\",\"TargetPrice\":745,\"qliId\":\"0QL5r000000eDtkGAE\",\"offerType\":\"SubscriptionOffering\",\"productType\":\"Price\",\"productCode\":\"CO-BBSTART-50MB\",\"assetReferenceId\":\"5e8a1329-c9e8-aa49-bda9-9d85bbf63e21\",\"parentItemId\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\",\"faQty\":2,\"name\":\"BredbandStart50Mbit/s\",\"initialOrderQty\":2,\"rootItem\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\"},{\"discountPercentage\":0,\"recPrice\":895,\"recurringCharge\":895,\"objectTypeName\":\"BroadbandStartOfferingSpec2\",\"productHierarchyPath\":\"01t08000009Rd3KAAS<01t08000009RcyKAAS\",\"effectiveQty\":1,\"oneTimeCharge\":0,\"QuoteId\":\"0Q05r00000124QPCAY\",\"excludeItem\":false,\"RootProduct\":\"01t08000009Rd3KAAS\",\"Sequencenumber\":4,\"prodId\":\"01t08000009RcyKAAS\",\"TargetPrice\":895,\"qliId\":\"0QL5r000000eDtpGAE\",\"offerType\":\"SubscriptionOffering\",\"productType\":\"Price\",\"productCode\":\"CO-BBSTART-100MB\",\"assetReferenceId\":\"6ef1cb7c-b728-ef56-4f73-2628da812cb0\",\"parentItemId\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\",\"faQty\":3,\"name\":\"BredbandStart100Mbit/s\",\"initialOrderQty\":1,\"rootItem\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\"},{\"discountPercentage\":0,\"recPrice\":0,\"recurringCharge\":0,\"objectTypeName\":\"BindingOTCOfferingSpec\",\"productHierarchyPath\":\"01t08000009Rd3KAAS<01t08000009STlPAAW\",\"effectiveQty\":1,\"oneTimeCharge\":0,\"QuoteId\":\"0Q05r00000124QPCAY\",\"excludeItem\":false,\"RootProduct\":\"01t08000009Rd3KAAS\",\"Sequencenumber\":7.5,\"prodId\":\"01t08000009STlPAAW\",\"TargetPrice\":0,\"qliId\":\"0QL5r000000eDtbGAE\",\"offerType\":\"Non-SubscriptionOffering\",\"productType\":\"Price\",\"productCode\":\"CO-BBSTART-BIND\",\"assetReferenceId\":\"c5a5e7d5-6d92-d215-4332-5e835cb32367\",\"parentItemId\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\",\"name\":\"Engångsavgifter\",\"rootItem\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\"},{\"discountPercentage\":0,\"recPrice\":0,\"recurringCharge\":0,\"objectTypeName\":\"BroadbandStartOfferingSpec\",\"productHierarchyPath\":\"01t08000009Rd3KAAS<01t08000009RczJAAS\",\"effectiveQty\":1,\"oneTimeCharge\":0,\"QuoteId\":\"0Q05r00000124QPCAY\",\"excludeItem\":false,\"RootProduct\":\"01t08000009Rd3KAAS\",\"Sequencenumber\":8,\"prodId\":\"01t08000009RczJAAS\",\"TargetPrice\":0,\"qliId\":\"0QL5r000000eDteGAE\",\"offerType\":\"Non-SubscriptionOffering\",\"productType\":\"Price\",\"productCode\":\"CO-BBSTART-OTHER\",\"assetReferenceId\":\"65c71f67-f589-0df6-8947-8aede60a65f3\",\"parentItemId\":\"f2ed22ea-bceb-1586-ee22-74f92bcec352\",\"name\":\"InstallationochÖvrigaTillval\",\"rootItem\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\"},{\"discountPercentage\":0,\"recPrice\":0,\"recurringCharge\":0,\"objectTypeName\":\"BindingOTCOfferingSpec\",\"productHierarchyPath\":\"01t08000009Rd3KAAS<01t08000009STlPAAW<01t08000009STkrAAG\",\"effectiveQty\":1,\"oneTimeCharge\":1995,\"QuoteId\":\"0Q05r00000124QPCAY\",\"excludeItem\":false,\"RootProduct\":\"01t08000009Rd3KAAS\",\"Sequencenumber\":10,\"prodId\":\"01t08000009STkrAAG\",\"TargetPrice\":0,\"qliId\":\"0QL5r000000eDtcGAE\",\"offerType\":\"SubscriptionOffering\",\"productType\":\"Price\",\"productCode\":\"CO-BBSTART-BIND-G1-0M\",\"assetReferenceId\":\"ca7cb13c-83c9-bab6-5945-e8678a32a1c9\",\"parentItemId\":\"c5a5e7d5-6d92-d215-4332-5e835cb32367\",\"name\":\"Engångsavgiftföranslutningar0Mån\",\"rootItem\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\"},{\"discountPercentage\":0,\"recPrice\":0,\"recurringCharge\":0,\"objectTypeName\":\"BindingOTCOfferingSpec\",\"productHierarchyPath\":\"01t08000009Rd3KAAS<01t08000009STlPAAW<01t08000009STkwAAG\",\"effectiveQty\":1,\"oneTimeCharge\":0,\"QuoteId\":\"0Q05r00000124QPCAY\",\"excludeItem\":false,\"RootProduct\":\"01t08000009Rd3KAAS\",\"Sequencenumber\":20,\"prodId\":\"01t08000009STkwAAG\",\"TargetPrice\":0,\"qliId\":\"0QL5r000000eDtdGAE\",\"offerType\":\"SubscriptionOffering\",\"productType\":\"Price\",\"productCode\":\"CO-BBSTART-BIND-G1-24M\",\"assetReferenceId\":\"f2ed22ea-bceb-1586-ee22-74f92bcec352\",\"parentItemId\":\"c5a5e7d5-6d92-d215-4332-5e835cb32367\",\"name\":\"Engångsavgiftföranslutningar24Mån\",\"rootItem\":\"6516eaa2-f531-b7a5-3ccd-33457cd18227\"}]';     
        List<MC_OfferDocHelper.qli> qliList = (List<MC_OfferDocHelper.qli>)JSON.deserialize(inputstr,  List<MC_OfferDocHelper.qli>.class);
        Map<String, object> input = new Map<String,object>();
        map<String,Object> output = new map<String,Object>();
        map<String,Object> options = new map<String,Object>();
        Map<String,String> offerTypeToBindingPeriodMap=new Map<String,String>();
        offerTypeToBindingPeriodMap.put('BroadbandStartOfferingSpec1','36');
        offerTypeToBindingPeriodMap.put('BroadbandStartOfferingSpec2','24');
        offerTypeToBindingPeriodMap.put('BroadbandStartOfferingSpec','12');
        input.put('offerTypeToBindingPeriodMap',offerTypeToBindingPeriodMap);
        input.put('FinalAdded',qliList);
        MC_OfferDocHelper obj1 = new MC_OfferDocHelper();
        Test.startTest();
        obj1.invokeMethod('simplifiedLineItems',input,output,options);
        Test.stopTest();
    }
    
    @isTest
    static void test_coUpdateHera(){
        string inputstr = '[{\"vlocity_cmt__QuoteGroupId__c\":\"a895r000000GyhiAAC\",\"Quantity\":1,\"vlocity_cmt__EffectiveQuantity__c\":1,\"MC_HeraReferenceNumber__c\":\"3\",\"MC_HeraType__c\":\"Primary Access\",\"vlocity_cmt__QuoteMemberId__c\":\"aAk5r0000000UkCCAU\",\"PriceBookEntryId\":\"01u0800000mCBT0AAO\",\"vlocity_cmt__RecurringCharge__c\":100,\"vlocity_cmt__OneTimeCharge__c\":100},{\"vlocity_cmt__QuoteGroupId__c\":\"a895r000000GyhiAAC\",\"Quantity\":1,\"vlocity_cmt__EffectiveQuantity__c\":1,\"MC_HeraReferenceNumber__c\":\"5\",\"MC_HeraType__c\":\"Secondary Access\",\"vlocity_cmt__QuoteMemberId__c\":\"aAk5r0000000UkDCAU\",\"PriceBookEntryId\":\"01u0800000mCBT0AAO\",\"vlocity_cmt__RecurringCharge__c\":300,\"vlocity_cmt__OneTimeCharge__c\":300}]';
        List<Object> HERAPriceUpdate = (list<Object>)JSON.deserializeUntyped(inputstr);
        Map<String, object> input = new Map<String,object>();
        map<String,Object> output = new map<String,Object>();
        map<String,Object> options = new map<String,Object>();
        input.put('HERAPriceUpdate',HERAPriceUpdate);
        MC_OfferDocHelper obj2 = new MC_OfferDocHelper();
        Test.startTest();
        obj2.invokeMethod('coUpdateHera',input,output,options);
        Test.stopTest();
    }
    
    @isTest
    static void test_reArrangeLineItem(){
        string inputstr = '{ "selectedOffer": "e0630d36-81c4-ec28-f773-62eabcc8a92e", "QLI": [ { "maxQuantity": "9999", "parentItemId": "root", "rootPriceFlag": true, "disbaleExistingQty": true, "level": 0, "disableCallOff": false, "finalCharge": 0, "rootItem": "e0630d36-81c4-ec28-f773-62eabcc8a92e", "recurringCharge": 0, "recPrice": 0, "qliId": "0QL5r000000efUIGAY", "productType": "Price", "productHierarchyPath": "01t7a00000FcVLJAA3", "productCode": "ITP_OFFER", "prodId": "01t7a00000FcVLJAA3", "oneTimeCharge": 0, "offerType": "AgreementOffering", "objectTypeName": "ITDaaS Offer Spec", "name": "IT-support Plus", "excludeItem": false, "effectiveQty": 1, "discountPercentage": 0, "assetReferenceId": "e0630d36-81c4-ec28-f773-62eabcc8a92e", "TargetPrice": 0, "Sequencenumber": 1, "RootProduct": "01t7a00000FcVLJAA3", "QuoteId": "0Q05r0000012dniCAA", "BaseQuantity": "567" }, { "rootPriceFlag": false, "disbaleExistingQty": true, "level": 1, "disableCallOff": false, "finalCharge": 349, "rootItem": "e0630d36-81c4-ec28-f773-62eabcc8a92e", "recurringCharge": 349, "recPrice": 349, "qliId": "0QL5r000000efUJGAY", "productType": "Price", "productHierarchyPath": "01t7a00000FcVLJAA3<01t7a00000FcVLTAA3", "productCode": "ITDAAS_Offer", "prodId": "01t7a00000FcVLTAA3", "parentItemId": "e0630d36-81c4-ec28-f773-62eabcc8a92e", "oneTimeCharge": 0, "offerType": "SubscriptionOffering", "objectTypeName": "ITDaaS Offer Spec", "name": "Användare IT-support Plus", "excludeItem": false, "effectiveQty": 1, "discountPercentage": 0, "assetReferenceId": "7a10971d-cdc5-aa4e-41f1-c66353617a4d", "TargetPrice": 349, "Sequencenumber": 10, "RootProduct": "01t7a00000FcVLJAA3", "QuoteId": "0Q05r0000012dniCAA", "BaseQuantity": "567", "maxQuantity": 250 }, { "rootPriceFlag": false, "disbaleExistingQty": true, "level": 1, "disableCallOff": false, "finalCharge": 0, "rootItem": "e0630d36-81c4-ec28-f773-62eabcc8a92e", "recurringCharge": 0, "recPrice": 0, "qliId": "0QL5r000000efUKGAY", "productType": "Price", "productHierarchyPath": "01t7a00000FcVLJAA3<01t7a00000FcVLnAAN", "productCode": "ITP_ADDN_SERVICE", "prodId": "01t7a00000FcVLnAAN", "parentItemId": "e0630d36-81c4-ec28-f773-62eabcc8a92e", "oneTimeCharge": 0, "offerType": "Non-SubscriptionOffering", "objectTypeName": "ITDaaS Offer Spec", "name": "Tilläggstjänster", "excludeItem": false, "effectiveQty": 1, "discountPercentage": 0, "assetReferenceId": "75b33441-1f3f-ac6a-833b-0ee55f649f70", "TargetPrice": 0, "Sequencenumber": 20, "RootProduct": "01t7a00000FcVLJAA3", "QuoteId": "0Q05r0000012dniCAA", "BaseQuantity": "0", "maxQuantity": 1 } ] } }';
        Map<String,Object> input = (Map<String,Object>)JSON.deserializeUntyped(inputstr);
        map<String,Object> output = new map<String,Object>();
        map<String,Object> options = new map<String,Object>();
        MC_OfferDocHelper obj2 = new MC_OfferDocHelper();
        Test.startTest();
        obj2.invokeMethod('reArrangeLineItem',input,output,options);
        Test.stopTest();
    }
    
    @isTest
    static void test_saveQuantitiesOnFA(){
        prepareTestData();
        List<QuotelineItem> qli = [Select id from QuotelineItem ];
        string inputstr = '{"salesFlow":"New Sales","updatedQLIJson":{"'+String.valueOf(qli[0].Id)+'":{"record":{"Id":"REC0","assetReferenceId":"7a10971d-cdc5-aa4e-41f1-c66353617a4d","bindingTime":null,"childItem":null,"collapseChild":true,"disableCallOff":false,"disbaleExistingQty":true,"existingQty":null,"existingQuantity":null,"faQty":"2","hasChildren":false,"hideInputs":false,"level":1,"maxQuantity":250,"name":"Användare IT-support Plus","objectType":"ITDaaS Offer Spec","offerQty":null,"offerType":"SubscriptionOffering","oneTimeCharge":0,"parentItemId":"e0630d36-81c4-ec28-f773-62eabcc8a92e","productCode":"ITDAAS_Offer","ptObjectName":null,"qliId":"'+String.valueOf(qli[0].Id)+'","recPrice":349,"rootItem":"e0630d36-81c4-ec28-f773-62eabcc8a92e","rootPriceFlag":false,"uniqueKey":"REC0","_flex":{"uniqueKey":"REC0","state0element0block_element0block_element0":false,"state0element0block_element0block_element0_child":false,"state0element0block_element0block_element1":false,"state0element0block_element0block_element1_child":false,"state0element0block_element1":false,"state0element0block_element1_child":false,"state0element0block_element2":true,"state0element0block_element2_child":true,"state0element0block_element3":false,"state0element0block_element3_child":false,"state0element0block_element4":true,"state0element0block_element4_child":true,"state0element1block_element0":true,"state0element1block_element0_child":true,"state0element1block_element1":true,"state0element1block_element1_child":true,"state0element2":false,"state0element2_child":false,"state0element3":true,"state0element3_child":true,"state0element4":true,"state0element4_child":true,"state0element5":false,"state0element5_child":false,"state0element6":true,"state0element6_child":true}}}},"CheckCO":false}';
        Map<String,Object> input = (Map<String,Object>)JSON.deserializeUntyped(inputstr);
        map<String,Object> output = new map<String,Object>();
        map<String,Object> options = new map<String,Object>();
        MC_OfferDocHelper obj2 = new MC_OfferDocHelper();
        Test.startTest();
        obj2.invokeMethod('saveQuantitiesOnFA',input,output,options);
        Test.stopTest();
    }
}