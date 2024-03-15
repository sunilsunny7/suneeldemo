@isTest
public with sharing class MC_Sales_FrameworkPricingClass_Test {
    private static String namespace = 'vlocity_cmt__';  
    public static vlocity_cmt__CalculationMatrixVersion__c version;
    public static vlocity_cmt__CalculationMatrix__c parent;
    public static List<vlocity_cmt__CalculationMatrixRow__c> lineItems;
    private static Id orderId;
    private static boolean flag;  //used to upload matrix row data for Test1 or Test2
    private static Id quoteId, quoteId2; // added by Dipanwita
    static TeliaSERecordTypeSetting__mdt TeliaSERecordTypeSetting;
    MC_Sales_FrameworkPricingClass MCSales= new MC_Sales_FrameworkPricingClass();
    
    @TestSetup
    private static void TestDataSetup(){
        System.runAs(Test_DataFactory.getByPassUser())
        {
            vlocity_cmt__ObjectClass__c newObj=new vlocity_cmt__ObjectClass__c();
            newObj.Name = 'Mobile Offer Specification';
            newObj.vlocity_cmt__IsActive__c = true;
            newObj.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj;
            
            List<Product2> prodList = new List<Product2>();
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.TeliaSE_Subscription_Type__c = '99';
            prod.ProductCode='MOB_MULTI_TOTAL_V3';
            prod.TeliaSE_Price_Flag__c=true;
            prod.MC_Product_Negotiability__c = 'Framework';
            prod.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod);
            
            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            prod2.TeliaSE_Subscription_Type__c = '98';
            prod2.ProductCode='MOB_SP_ADDON_ABROAD_SURF';
            prod2.TeliaSE_Price_Flag__c=true;
            prod2.TeliaSE_Product_Category__c = 'A3DATAROA';
            prod2.MC_Product_Negotiability__c = 'Framework';
            prod2.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod2);
            
            insert prodList;
            
            MC_Sales_FrameworkProductCategoryMaster__c pcm = new MC_Sales_FrameworkProductCategoryMaster__c();
            pcm.MC_Sales_Product_Codes__c = 'MOB_SP_ADDON_ABROAD_SURF';
            pcm.Name = 'A3DATAROA';
            insert pcm;
            
            MC_Sales_FrameworkPricePlanMaster__c ppm = new MC_Sales_FrameworkPricePlanMaster__c();
            ppm.MC_Sales_Product_Category_Master__c = ppm.Id;
            ppm.MC_Sales_StartDate__c = Date.valueOf('2023-02-14');
            ppm.Name = '149';
            ppm.Sequence__c = 6;
            insert ppm;
            
            List<MC_Sales_FrameworkPricingMaster__c> frameworkMasters = new List<MC_Sales_FrameworkPricingMaster__c>();
            MC_Sales_FrameworkPricingMaster__c pm = new MC_Sales_FrameworkPricingMaster__c();
            pm.MC_Sales_Cluster__c = 'ALL';
            pm.MC_Sales_FrameworkProductCategoryMaster__c = pcm.Id;
            pm.MC_Sales_FrameworkPricePlanMaster__c = ppm.Id;
            pm.MC_Sales_Low_Base_Quantity__c = 1;
            pm.MC_Sales_High_Base_Quantity__c = 100;
            pm.MC_Sales_Parent__c = 'MOB_MULTI_TOTAL_V3';
            pm.MC_Sales_Object_Type__c = newObj.Id;
            pm.MC_Sales_Customer_Segment__c = 'ALL';
            pm.MC_Sales_Commitment_Period__c = 'ALL';
            pm.MC_AM_Mandate_Price__c = ppm.Id;          
            pm.MC_CM_Mandate_Price__c = ppm.Id; 
            pm.MC_Sales_Default_Price_Plan__c = true;
            pm.MC_Sales_Approver_Level__c = '4';
            frameworkMasters.add(pm);
            
            MC_Sales_FrameworkPricingMaster__c pm1 = new MC_Sales_FrameworkPricingMaster__c();
            pm1.MC_Sales_Cluster__c = 'SMALL';
            pm1.MC_Sales_FrameworkProductCategoryMaster__c = pcm.Id;
            pm1.MC_Sales_FrameworkPricePlanMaster__c = ppm.Id;
            pm1.MC_Sales_Low_Base_Quantity__c = 1;
            pm1.MC_Sales_High_Base_Quantity__c = 100;
            pm1.MC_Sales_Parent__c = 'MOB_MULTI_TOTAL_V3';
            pm1.MC_Sales_Object_Type__c = newObj.Id;
            pm1.MC_Sales_Customer_Segment__c = 'ALL';
            pm1.MC_Sales_Commitment_Period__c = 'ALL';
            pm1.MC_AM_Mandate_Price__c = ppm.Id;          
            pm1.MC_CM_Mandate_Price__c = ppm.Id; 
            pm1.MC_Sales_Default_Price_Plan__c = true;
            pm1.MC_Sales_Approver_Level__c = '4';
            frameworkMasters.add(pm1);
            
            MC_Sales_FrameworkPricingMaster__c pm2 = new MC_Sales_FrameworkPricingMaster__c();
            pm2.MC_Sales_Cluster__c = 'LARGE';
            pm2.MC_Sales_FrameworkProductCategoryMaster__c = pcm.Id;
            pm2.MC_Sales_FrameworkPricePlanMaster__c = ppm.Id;
            pm2.MC_Sales_Low_Base_Quantity__c = 1;
            pm2.MC_Sales_High_Base_Quantity__c = 100;
            pm2.MC_Sales_Parent__c = 'MOB_MULTI_TOTAL_V3';
            pm2.MC_Sales_Object_Type__c = newObj.Id;
            pm2.MC_Sales_Customer_Segment__c = 'ALL';
            pm2.MC_Sales_Commitment_Period__c = 'ALL';
            pm2.MC_AM_Mandate_Price__c = ppm.Id;          
            pm2.MC_CM_Mandate_Price__c = ppm.Id; 
            pm2.MC_Sales_Default_Price_Plan__c = true;
            pm2.MC_Sales_Approver_Level__c = '4';
            frameworkMasters.add(pm2);
            insert frameworkMasters;
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;
            objpricebookentry.Pricebook2ID = Test.getStandardPricebookId();
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;
            insert objpricebookentry;
            
            Account acc=Test_DataFactory.createOneSMEAccount();
            acc.MC_Commercial_Setup__c = 'Forced BA';
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Kvalificera';  
            opp.Pricebook2Id=Test.getStandardPricebookId();
            opp.TeliaSE_SharingSetting_Flag__c = false;
            insert opp;
            
            Quote testQuote = new Quote();
            testQuote.Name='Test Quote';
            testQuote.status = 'Draft';
            testQuote.TeliaSE_MC_Sales_Flow_Identifier__c = 'New Sales';
            testQuote.opportunityId = opp.id;
            testQuote.Pricebook2ID = Test.getStandardPricebookId();
            testQuote.TeliaSE_Approval_Flag__c = False; 
            insert testQuote;
            
            List<QuoteLineItem> qliList = new List<QuoteLineItem>();
            QuoteLineItem qli1 = new QuoteLineItem();
            qli1.QuoteId = testQuote.Id;
            qli1.Product2Id = prod.Id;
            qli1.UnitPrice = 0;
            qli1.Quantity = 1;
            qli1.vlocity_cmt__Product2Id__c=prod.Id;
            qli1.TeliaSE_Root_Product__c=prod.Id;
            qli1.TeliaSE_Base_Quantity__c = '22';
            qli1.PricebookEntryId = objpricebookentry.Id;
            qli1.vlocity_cmt__AssetReferenceId__c ='test-asset-ref1';
            qliList.add(qli1);
            
            QuoteLineItem qli2 = new QuoteLineItem();
            qli2.QuoteId = testQuote.Id;
            qli2.Product2Id = prod2.Id;
            qli2.UnitPrice = 0;
            qli2.Quantity = 1;
            qli2.vlocity_cmt__Product2Id__c=prod2.Id;
            qli2.TeliaSE_Root_Product__c=prod.Id;
            qli2.TeliaSE_ParentClusterCode__c = 'small';
            qli2.PricebookEntryId = objpricebookentry.Id;
            qli2.vlocity_cmt__AssetReferenceId__c ='test-asset-ref2';
            qliList.add(qli2);
            
            QuoteLineItem qli3 = new QuoteLineItem();
            qli3.QuoteId = testQuote.Id;
            qli3.Product2Id = prod2.Id;
            qli3.UnitPrice = 0;
            qli3.Quantity = 1;
            qli3.vlocity_cmt__Product2Id__c=prod2.Id;
            qli3.TeliaSE_Root_Product__c=prod.Id;
            qli3.MC_Sales_FrameworkPricingMaster__c = pm.Id;
            qli3.PricebookEntryId = objpricebookentry.Id;
            qli3.vlocity_cmt__AssetReferenceId__c ='test-asset-ref3';
            qliList.add(qli3);
            
            QuoteLineItem qli4 = new QuoteLineItem();
            qli4.QuoteId = testQuote.Id;
            qli4.Product2Id = prod2.Id;
            qli4.UnitPrice = 0;
            qli4.Quantity = 1;
            qli4.vlocity_cmt__Product2Id__c=prod2.Id;
            qli4.TeliaSE_Root_Product__c=prod.Id;
            qli4.MC_Sales_FrameworkPricingMaster__c = pm.Id;
            qli4.TeliaSE_ParentClusterCode__c = 'large';
            qli4.PricebookEntryId = objpricebookentry.Id;
            qli4.vlocity_cmt__AssetReferenceId__c ='test-asset-ref4';
            qliList.add(qli4);
            
            insert qliList;
            qli1.vlocity_cmt__RootItemId__c = qli1.vlocity_cmt__AssetReferenceId__c;
            qli2.vlocity_cmt__RootItemId__c = qli1.vlocity_cmt__AssetReferenceId__c;
            qli3.vlocity_cmt__RootItemId__c = qli1.vlocity_cmt__AssetReferenceId__c;
            qli4.vlocity_cmt__RootItemId__c = qli1.vlocity_cmt__AssetReferenceId__c;
            qli2.vlocity_cmt__ParentItemId__c = qli1.vlocity_cmt__AssetReferenceId__c;
            qli3.vlocity_cmt__ParentItemId__c = qli1.vlocity_cmt__AssetReferenceId__c;
            qli4.vlocity_cmt__ParentItemId__c = qli1.vlocity_cmt__AssetReferenceId__c;
            update qliList;
        }
    }
    
    @isTest
    public static void invokeMethod()
    {
        User salesManager;        
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        Map<String, Object> inputMap = new Map<String, Object> ();
        Map<String, Object> outMap = new Map<String, Object> ();
        Map<String, Object> options = new Map<String, Object> ();
        MC_Sales_FrameworkPricingClass MCSales= new MC_Sales_FrameworkPricingClass();
        MCSales.invokeMethod('processPricePlanExtract',inputMap,outMap,options);
        MCSales.invokeMethod('savePricesAndFlags',inputMap,outMap,options);
        inputMap.put('attr',JSON.deserializeUntyped('[{"code":"ATT_RT_NoU","userValues":30},{"code":"ATT_RT_CMTP","userValues":"24s month"}]'));
        
        MCSales.invokeMethod('saveDefaultPricePlan',inputMap,outMap,options);
    }
    
    @isTest
    public static void processPricePlanExtract(){
        String productCodesAvaiable;
        User salesManager;        
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        Map<String, Object> outMap = new Map<String, Object> ();
        Map<String, Object> options = new Map<String, Object> ();
        
        String jsonString = '{"GroupItems":[{"StandardPrice":19,"ProductName":"Res Söderut","ProductCode":"MOB_CALL_TRAVEL_SOUTH","Id":"0QL9E0000019TrLWAU"},{"StandardPrice":19,"ProductName":"Res Västerut","ProductCode":"MOB_CALL_TRAVEL_WEST","Id":"0QL9E0000019TrNWAU"}],"PricePlans":[{"isDefaultPricePlan":true,"ProductCodesAvailable":"MOB_CALL_TRAVEL_SOUTH;MOB_CALL_TRAVEL_EAST;MOB_CALL_TRAVEL_WEST","Prices":"19,19,19","PricePlanId":"aBf9E000000076cSAA","CustomerSegment":"ALL","Cluster":"ALL","Approver":"AM","AgreementControlServices":"Optional;optional;optional"},{"isDefaultPricePlan":false,"ProductCodesAvailable":"MOB_CALL_TRAVEL_SOUTH;MOB_CALL_TRAVEL_EAST;MOB_CALL_TRAVEL_WEST","Prices":"15,15,15","PricePlanId":"aBf9E000000076dSAA","CustomerSegment":"ALL","Cluster":"ALL","Approver":"SM","AgreementControlServices":"Optional;optional;optional"}],"selectedPricePlan":"","qliId":"0QL9E0000019TrM"}';
        Map<String,Object> inputMap = (Map<String,Object>) json.deserializeUntyped(jsonString);
        List<Object> productCodesAvailableInFAJson = (List<Object>)inputMap.get('PricePlans');
        List<Object> groupInJson = (List<Object>)inputMap.get('GroupItems');
        List<Map<String,Object>> productCodesAvailableInFA = new List<Map<String,Object>>();
        List<Map<String,Object>> groupInJsonFA = new List<Map<String,Object>>();
        
        for(Object obj:productCodesAvailableInFAJson)
        {
            Map<String,Object> temp = (Map<String,Object>)obj;    
            productCodesAvailableInFA.add(temp);
        }
        for(Object obj:groupInJson)
        {
            Map<String,Object> temp = (Map<String,Object>)obj;    
            groupInJsonFA.add(temp);
        }
        inputMap.put('PricePlans',productCodesAvailableInFA);
        inputMap.put('GroupItems',groupInJsonFA);
       
        Test.startTest();
        MC_Sales_FrameworkPricingClass mc = new MC_Sales_FrameworkPricingClass();
        mc.invokeMethod('processPricePlanExtract', inputMap, inputMap, inputMap);  
        Test.stopTest();
        
    }        
    
    @isTest
    public static void savePricesAndFlags(){
        String productCodesAvaiable;
        User salesManager;        
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        string jsonData = '{"productsInFA":"0QL5r000000eMi0GAE,0QL5r000000eMi1GAE,0QL5r000000eMi2GAE,0QL5r000000eMi3GAE,0QL5r000000eMi4GAE","approver":"AM","prices":"0.990,1.190,2.190,4.990,9.990","pricePlanIdSelected":"aC25r0000004GdvCAE","approvedPriceId":"","rootId":"0QL5r000000eMhTGAU","rootLineStatus":"Added","salesFlowIdentifier":"New Sales","qliNegotiability":"Minute_Based","oneTimeMinuteBasedFee":"0.590","minBasedStandardPrice":"0.990,1.190,2.190,4.990,9.990"}';
          Map<String, Object> inputMapMinuteBased = (Map<String,Object>) json.deserializeUntyped(jsonData);
        Map<String, Object> inputMap = new Map<String, Object> ();
        Map<String, Object> outMap = new Map<String, Object> ();
        Map<String, Object> options = new Map<String, Object> ();
        List<String> productsInFA = new List<String>();
        
        inputMap.put('productsInFA','0QL25000000Me0OGAS,0QL25000000Me0PGAS,0QL25000000Me0QGAS');
        inputMap.put('approver','SM');
        inputMap.put('prices','89,49,5');
        inputMap.put('pricePlanIdSelected','aA4250000004GfVCAU');
        inputMap.put('approvedPriceId','');
        Map<String, Object> inputMap1 = new Map<String, Object> ();
        
        inputMap1.put('productsInFA','0QL25000000Me0OGAS,0QL25000000Me0PGAS,0QL25000000Me0QGAS');
        inputMap1.put('approver','SD');
        inputMap1.put('prices','89,49,5');
        inputMap1.put('pricePlanIdSelected','aA4250000004GfVCAU');
        inputMap1.put('approvedPriceId','aA4250000004GfVCAU');
        Map<String, Object> inputMap2 = new Map<String, Object> ();
        
        inputMap2.put('productsInFA','0QL25000000Me0OGAS,0QL25000000Me0PGAS,0QL25000000Me0QGAS');
        inputMap2.put('approver','CM');
        inputMap2.put('prices','89,49,5');
        inputMap2.put('pricePlanIdSelected','aA4250000004GfVCAU');
        inputMap2.put('approvedPriceId','aA4250000004GfVCAU');
        Map<String, Object> inputMap3 = new Map<String, Object> ();
        
        inputMap3.put('productsInFA','0QL25000000Me0OGAS,0QL25000000Me0PGAS,0QL25000000Me0QGAS');
        inputMap3.put('approver','PM');
        inputMap3.put('prices','89,49,5');
        inputMap3.put('pricePlanIdSelected','aA4250000004GfVCAU');
        inputMap3.put('approvedPriceId','aA4250000004GfVCAU');
        
        Test.startTest();
        //Test 1
        MC_Sales_FrameworkPricingClass mc = new MC_Sales_FrameworkPricingClass();
        mc.invokeMethod('savePricesAndFlags', inputMap, inputMap, inputMap);  
        mc.invokeMethod('savePricesAndFlags', inputMap1, inputMap1, inputMap1);
        mc.invokeMethod('savePricesAndFlags', inputMap2, inputMap2, inputMap2);
        mc.invokeMethod('savePricesAndFlags', inputMap3, inputMap3, inputMap3);
        mc.invokeMethod('savePricesAndFlags', inputMapMinuteBased, inputMap3, inputMap3);
        Test.stopTest();
        
    }
    
   
    @isTest
    public static void test_sparaCallFrameworkPrice(){
        
        QuoteLineItem qli = [SELECT Id,vlocity_cmt__RootItemId__c,QuoteId FROM QuoteLineItem LIMIT 1];
        Map<String, Object> inputMap = new Map<String, Object> ();
        Map<String, Object> outMap = new Map<String, Object> ();
        Map<String, Object> options = new Map<String, Object> ();
        inputMap.put('quoteId',qli.QuoteId);
        inputMap.put('rootItemId',qli.vlocity_cmt__RootItemId__c);
        inputMap.put('attr',JSON.deserializeUntyped('[{"code":"ATT_RT_NoU","userValues":30},{"code":"ATT_RT_CMTP","userValues":"24 months"}]'));
        
        Test.startTest();
        MC_Sales_FrameworkPricingClass mc = new MC_Sales_FrameworkPricingClass();
        mc.invokeMethod('sparaCallFrameworkPrice', inputMap, outMap, options);
        Test.stopTest();
    }
    
    @isTest
    public static void test_sparaCallFrameworkPrice2(){
        
        QuoteLineItem qli = [SELECT Id,vlocity_cmt__RootItemId__c,QuoteId FROM QuoteLineItem WHERE vlocity_cmt__ParentItemId__c = null LIMIT 1];
        Map<String, Object> inputMap = new Map<String, Object> ();
        Map<String, Object> outMap = new Map<String, Object> ();
        Map<String, Object> options = new Map<String, Object> ();
        qli.TeliaSE_Base_Quantity__c = '30';
        update qli;
        
        inputMap.put('quoteId',qli.QuoteId);
        inputMap.put('rootItemId',qli.vlocity_cmt__RootItemId__c);
        inputMap.put('attr',JSON.deserializeUntyped('[{"code":"ATT_RT_NoU","userValues":30},{"code":"ATT_RT_CMTP","userValues":"24 months"}]'));
        
        Test.startTest();
        MC_Sales_FrameworkPricingClass mc = new MC_Sales_FrameworkPricingClass();
        mc.invokeMethod('sparaCallFrameworkPrice', inputMap, outMap, options);
        Test.stopTest();
    }
   
    @isTest
    public static void test_resetPricePlans(){
        
        QuoteLineItem qli = [SELECT Id,QuoteId,vlocity_cmt__RootItemId__c FROM QuoteLineItem LIMIT 1];
        Map<String, Object> inputMap = new Map<String, Object> ();
        Map<String, Object> outMap = new Map<String, Object> ();
        Map<String, Object> options = new Map<String, Object> ();
        inputMap.put('rootItemId',qli.vlocity_cmt__RootItemId__c);
        
        Test.startTest();
        MC_Sales_FrameworkPricingClass mc = new MC_Sales_FrameworkPricingClass();
        mc.invokeMethod('resetPricePlans', inputMap, outMap, options);
        Test.stopTest();
    }    
    
    @isTest
    public static void test_valideraCallFrameworkPrice(){
        
        QuoteLineItem qli = [SELECT Id,QuoteId FROM QuoteLineItem LIMIT 1];
        Map<String, Object> inputMap = new Map<String, Object> ();
        Map<String, Object> outMap = new Map<String, Object> ();
        Map<String, Object> options = new Map<String, Object> ();
        inputMap.put('Id',qli.QuoteId);
        options.put('quoteType','Inforhandling');
        Test.startTest();
        MC_Sales_FrameworkPricingClass.valideraCallFrameworkPrice(inputMap,outMap);
        MC_CartRepricing mcp = new MC_CartRepricing();
        mcp.invokeMethod('updateFlag',inputMap,outMap,options);
        Test.stopTest();
    }
    
    @isTest
    public static void test_transformSummaryResponse(){
        Map<String, Object> inputMap = new Map<String, Object> ();
        Map<String, Object> outMap = new Map<String, Object> ();
        Map<String, Object> options = new Map<String, Object> ();
        
        List<Map<String,Object>> inputList = new List<Map<String,Object>>();
        String qliJSON = '[{"ProductCode":"MOB_SP_ADDON_ABROAD_CALL","Cluster":"plus","Name":"Samtaliutlandet"},{"ProductCode":"MOB_SP_ADDON_ABROAD_CALL","Cluster":"bas","Name":"Samtaliutlandet"},{"ProductCode":"MOB_SP_ADDON_ABROAD_CALL","Cluster":"small","Name":"Samtaliutlandet"},{"ProductCode":"MOB_SP_ADDON_ABROAD_SURF","Cluster":"medium","Name":"Surfiutlandet"},{"ProductCode":"MOB_SP_ADDON_ABROAD_CALL","Cluster":"medium","Name":"Samtaliutlandet"},{"ProductCode":"MOB_SP_ADDON_ABROAD_SURF","Cluster":"large","Name":"Surfiutlandet"},{"ProductCode":"MOB_SP_ADDON_ABROAD_CALL","Cluster":"large","Name":"Samtaliutlandet"},{"ProductCode":"MOB_SP_ADDON_ABROAD_SURF","Cluster":"xlarge","Name":"Surfiutlandet"},{"ProductCode":"MOB_SP_ADDON_ABROAD_CALL","Cluster":"xlarge","Name":"Samtaliutlandet"}]';
        for(Object obj :(List<Object>)json.deserializeUntyped(qliJSON)){
            Map<String,Object> jsonMap = (Map<String,Object>)obj;
            inputList.add(jsonMap);
        }
        inputMap.put('qli',inputList);
        
        Test.startTest();
        MC_Sales_FrameworkPricingClass mcObj = new MC_Sales_FrameworkPricingClass();
        mcObj.invokeMethod('transformSummaryResponse', inputMap, options, outMap);
        Test.stopTest();
    }
    
    @isTest
    public static void invokeMethod_filterPricePlans(){
        Map<String, Object> inputMap = new Map<String, Object> ();
        String testStr = 'LARGE';
        Map<String,Double> selectedCluster = new Map<String,Double>();
        selectedCluster.put('SMALL',2);
        Map<String,Object> pricePlans = new Map<String,Object>();
        pricePlans.put('SequenceNo',1);
        pricePlans.put('showRadio',true);
        List<Map<String,Object>> pricePlansList = new List<Map<String,Object>>();
        pricePlansList.add(pricePlans);
        Test.startTest();
        MC_Sales_FrameworkPricingClass.filterPricePlans(pricePlansList,selectedCluster,testStr);
        Test.stopTest();
    }
    
    @isTest
    public static void invokeMethod_IncorrectMethodName(){
        Map<String, Object> inputMap = new Map<String, Object> ();
        Test.startTest();
        MC_Sales_FrameworkPricingClass mcObj = new MC_Sales_FrameworkPricingClass();
        mcObj.invokeMethod('saveDefaultPricePlan2', inputMap, inputMap, inputMap);
        Test.stopTest();
    }
}