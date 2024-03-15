@isTest
public class Test_AgreementValidations {
    
    testMethod public static void subscriptionMethodMadam(){
        //TeliaSE_AgreementValidations av = new TeliaSE_AgreementValidations();
         User salesManager;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        List<vlocity_cmt__ObjectClass__c> objectClassList = new List<vlocity_cmt__ObjectClass__c>();
        vlocity_cmt__ObjectClass__c prntObj = new vlocity_cmt__ObjectClass__c();
        prntObj.Name = 'Connected Office Offer Spec';    
        prntObj.vlocity_cmt__IsActive__c = True;
        prntObj.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert prntObj;
        
        //new object class
        vlocity_cmt__ObjectClass__c prntObj6 = new vlocity_cmt__ObjectClass__c();
        prntObj6.Name = 'Mobile Offer Specification';
        prntObj6.vlocity_cmt__IsActive__c = True;
        prntObj6.vlocity_cmt__ObjectApiName__c = 'Product2';
        objectClassList.add(prntObj6);
     vlocity_cmt__ObjectClass__c prntObj5 = new vlocity_cmt__ObjectClass__c();
        prntObj5.Name = 'Smart Connect Offer Spec'; 
        prntObj5.vlocity_cmt__IsActive__c = True;
        prntObj5.vlocity_cmt__ObjectApiName__c = 'Product2';
        objectClassList.add(prntObj5);
        
        vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
        objClass.Name = 'Broadband Plus Offering Spec';    
        objClass.vlocity_cmt__IsActive__c = True;
        objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
        objClass.vlocity_cmt__ParentObjectClassId__c =prntObj.Id;
        objectClassList.add(objClass);
        insert objectClassList;
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod.TeliaSE_Subscription_Type__c = '99';
        prod.ProductCode='CO-BBPRO-100MB';
        prod.TeliaSE_Price_Flag__c=true;
        prodList.add(prod);
        
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod1.TeliaSE_Subscription_Type__c = '98';
        prod1.ProductCode='CO-BBPRO-10MB';
        prodList.add(prod1);
        
        Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        prod2.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod2.TeliaSE_Subscription_Type__c = '97';
        prodList.add(prod2);
        Product2 prod3 = Test_DataFactory.createProducts(1)[0];
        prod3.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod3.TeliaSE_Subscription_Type__c = '96';
        prodList.add(prod3);
        Product2 prod4 = Test_DataFactory.createProducts(1)[0];
        prod4.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod4.TeliaSE_Subscription_Type__c = '95';
        prodList.add(prod4);
        Product2 prod5 = Test_DataFactory.createProducts(1)[0];
        prod5.vlocity_cmt__ObjectTypeId__c = prntObj5.Id;
        prod5.TeliaSE_Subscription_Type__c = '98';
        prod5.ProductCode='MOB_MULTI_TOTAL_V3';
        prodList.add(prod5);
        Product2 prod7 = Test_DataFactory.createProducts(1)[0];
        prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod.TeliaSE_Subscription_Type__c = '99';
        prod.ProductCode='SC_KLU_LARGE';
        prodList.add(prod7);
        
        insert prodList;
        
        SubscriptionFilter__c sfilter = new SubscriptionFilter__c();
        sfilter.Name = prod.Name;
        insert sfilter;  
        MC_AgreementsValidation  av = new MC_AgreementsValidation ();   
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            TeliaSE_PortfolioIdentifiers__c portfolioTotal=new TeliaSE_PortfolioIdentifiers__c();
            portfolioTotal.Name='Mobile_Total';
            portfolioTotal.ProductId__c='01t1p0000095vXVAAY';
            
            portfolioTotal.NewProductCode__c='MOB_MULTI_TOTAL_V3';
            portfolioTotal.OldProductCode__c='MOB_MULTI_TOTAL_V2';
            portfolioTotal.RetiredPortfolio__c='01t1p0000081yO6AAI';
            insert portfolioTotal;
            
            Opportunity opp = new Opportunity();
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
  
            //new price book entry
            PricebookEntry objpricebookentry5 =new PricebookEntry();
            objpricebookentry5.Product2ID = prod5.id;
            objpricebookentry5.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry5.UnitPrice=23.50;
            objpricebookentry5.UseStandardPrice=false;
            objpricebookentry5.isActive=true;//Add this line
            insert objpricebookentry5;
            
             PricebookEntry objpricebookentry6 =new PricebookEntry();
            objpricebookentry6.Product2ID = prod1.id;
            objpricebookentry6.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry6.UnitPrice=23.50;
            objpricebookentry6.UseStandardPrice=false;
            objpricebookentry6.isActive=true;//Add this line
            insert objpricebookentry6;
            
            
            RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'MC_PreCheck_Result__c' AND Name = 'AveragePrice'];
            
            MC_PreCheck_Result__c pc = new MC_PreCheck_Result__c();
            pc.Opportunity__c= opp.Id;
            pc.RecordType = rt;
            pc.RecordTypeId = rt.Id;
            //pc.RecordTypeId= rt.Id;
            pc.MC_Product_Code__c='CO-BBPRO-100MB';
            pc.Price__c=0;
            insert pc;
             List<MC_RangeAttributePricingMatrixSettings__c> matrixsetting = new List<MC_RangeAttributePricingMatrixSettings__c>();
            MC_RangeAttributePricingMatrixSettings__c mcRange = new MC_RangeAttributePricingMatrixSettings__c();
            mcRange.Active__c = true;
            mcRange.Name = 'Large_Office365';
            mcRange.Customer_Segment__c = 'Enterprise Large';
            mcRange.Matrix_Name__c = 'PriceMatrix_Office365';
            mcRange.ProcedureName__c = 'Small_Office365_RangeAttributePricingProcedure';
            mcRange.Product_Family_Code__c = 'MOB_MULTI_TOTAL';    
            matrixsetting.add(mcRange);
            
            MC_RangeAttributePricingMatrixSettings__c mcRange1 = new MC_RangeAttributePricingMatrixSettings__c();
            mcRange1.Active__c = true;
            mcRange1.Name = 'ForcedBA_Mobile_Total_v1';
            mcRange1.Customer_Segment__c = 'Forced BA';
            mcRange1.Matrix_Name__c = 'PriceMatrix_Mobile_Total_1';
            mcRange1.ProcedureName__c = 'Small_Mobile_Total_1_RangeAttributePricingProcedure';
            mcRange1.Product_Family_Code__c = 'MOB_MULTI_TOTAL';    
            matrixsetting.add(mcRange1);
            insert matrixsetting;
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';  
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;        
            insert qut;
            
            List<QuoteLineItem> QliList = new List<QuoteLineItem>();
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.QuoteId = qut.Id;
            oli1.Product2Id = prod.Id;
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.AvgPriceFLag__c = true;
            oli1.UnitPrice = 0;
            oli1.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli1.Quantity = 1;
            oli1.vlocity_cmt__Product2Id__c=prod.Id;
            oli1.MC_Reprice_Required__c=true;
            oli1.TeliaSE_Root_Product__c=prod.Id;
            

            //oli1.MC_Matrix_Version__c=mcRange1.id
            //oli1.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__r.vlocity_cmt__ParentObjectClassId__r.Name='Connected Office Offer Spec';
            QliList.add(oli1); 
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.QuoteId = qut.Id;
            
            oli2.Product2Id = prod5.Id;
            oli2.PricebookEntryId = objpricebookentry.Id;
            oli2.AvgPriceFLag__c = true;
            oli2.UnitPrice = 0;
            oli2.Quantity = 1;
            oli2.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            //oli1.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__r.vlocity_cmt__ParentObjectClassId__r.Name='Connected Office Offer Spec';
            QliList.add(oli2);
            
            //new qli
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.QuoteId = qut.Id;
            oli3.Product2Id = prod5.Id;
            oli3.PricebookEntryId = objpricebookentry5.Id;
            oli3.AvgPriceFLag__c = true;
            oli3.UnitPrice = 0;
            oli3.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli3.Quantity = 1;
            
            oli3.MC_Line_Status__c = 'Added';

      
            
            //oli1.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__r.vlocity_cmt__ParentObjectClassId__r.Name='Connected Office Offer Spec';
            QliList.add(oli3);

    
            QuoteLineItem oli4 = new QuoteLineItem();
            oli4.QuoteId = qut.Id;
            oli4.Product2Id = prod1.Id;
            oli4.PricebookEntryId = objpricebookentry6.Id;
            oli4.AvgPriceFLag__c = true;
            oli4.UnitPrice = 0;
            oli4.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli4.Quantity = 1;
            oli4.vlocity_cmt__Product2Id__c=prod1.Id;
            oli4.MC_Reprice_Required__c=true;
            oli4.TeliaSE_Root_Product__c=prod1.Id;
            QliList.add(oli4);

            insert QliList;   
      
            Account acc = Test_DataFactory.createOneAccount();
            insert acc; 
            List<Quote> quoteList = [Select id from quote where name='Test Quote' LIMIT 1];
          List<quoteLineItem> qLIList1 = [Select id, vlocity_cmt__ParentItemId__c, TeliaSE_Product_Code__c from quoteLineItem Where QuoteId =:quoteList[0].Id ];
        
            Map<String,Object> options = new Map<String,Object>();
            Map<String,Object> inputMap = new Map<string,Object>();
            inputMap.put('cartId',quoteList[0].Id);
            inputMap.put('rootItemId',oli1.id);      
            Map<String, Object> outMap = new Map<String, Object>();            
            MC_AgreementsValidation.COB2Bvalidation(qLIList1, outMap);
            av.invokeMethod('AgreementValidationforHeader',inputMap,outMap,options);
            av.invokeMethod('AgreementValidationforSpara',inputMap,outMap,options);
            av.invokeMethod('AgreementValidation',inputMap,outMap,options);  
            List<String> prodList1 = new List<String>{'CO-BBPRO-100MB'};
            string error1 = 'Test error1';
      MC_AgreementsValidation.PrecheckValidate((String)opp.Id,outMap,prodList1,error1,error1);
            
        }       
    }

    testMethod public static void oldportfolioError()
    {
        User salesManager;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        //Insert object Type
        vlocity_cmt__ObjectClass__c prntObj = new vlocity_cmt__ObjectClass__c();
        prntObj.Name = 'Mobile Offer Specification';    
        prntObj.vlocity_cmt__IsActive__c = True;
        prntObj.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert prntObj;
        
        //Insert Products
        List<Product2> prodList = new List<product2>();
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = prntObj.Id;
        prod1.TeliaSE_Subscription_Type__c = '98';
        prod1.ProductCode='MOB_MULTI_TOTAL_V3';
        
        Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        prod2.vlocity_cmt__ObjectTypeId__c = prntObj.Id;
        prod2.TeliaSE_Subscription_Type__c = '97';
        prod2.ProductCode='MOB_MULTI_TOTAL_V2';
        
        Product2 prod3 = Test_DataFactory.createProducts(1)[0];
        prod3.vlocity_cmt__ObjectTypeId__c = prntObj.Id;
        prod3.TeliaSE_Subscription_Type__c = '97';
        prod3.ProductCode='MOB_MULTI_TOTAL_V2';
        
        prodList.add(prod1);
        prodList.add(prod2);
        prodList.add(prod3);
        insert prodList;
        
        //Insert portfolio identifier
        TeliaSE_PortfolioIdentifiers__c portfolioTotal=new TeliaSE_PortfolioIdentifiers__c();
        portfolioTotal.Name='Mobile_Total';
        portfolioTotal.ProductId__c=prod2.id;
        portfolioTotal.NewProductCode__c='MOB_MULTI_TOTAL_V3';
        portfolioTotal.OldProductCode__c='MOB_MULTI_TOTAL_V2';
        portfolioTotal.RetiredPortfolio__c=prod3.id;
        insert portfolioTotal;
        
        //Insert Pricebook Entries
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        PricebookEntry objpricebookentry =new PricebookEntry();
        objpricebookentry.Product2ID = prod1.id;
        objpricebookentry.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry.UnitPrice=23.50;
        objpricebookentry.UseStandardPrice=false;
        objpricebookentry.isActive=true;//Add this line
        pbeList.add(objpricebookentry);
        
        PricebookEntry objpricebookentry1 =new PricebookEntry();
        objpricebookentry1.Product2ID = prod2.id;
        objpricebookentry1.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry1.UnitPrice=23.50;
        objpricebookentry1.UseStandardPrice=false;
        objpricebookentry1.isActive=true;//Add this line
        pbeList.add(objpricebookentry1);
        
        PricebookEntry objpricebookentry3 =new PricebookEntry();
        objpricebookentry3.Product2ID = prod3.id;
        objpricebookentry3.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry3.UnitPrice=23.50;
        objpricebookentry3.UseStandardPrice=false;
        objpricebookentry3.isActive=true;//Add this line
        pbeList.add(objpricebookentry3);
        
        insert pbeList;
        
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
            insert qut;
            
            //Insert quoteLineItems
            List<QuoteLineItem> QliList = new List<QuoteLineItem>();
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.QuoteId = qut.Id;
            oli1.vlocity_cmt__Product2Id__c = prod1.Id;
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.AvgPriceFLag__c = true;
            oli1.UnitPrice = 0;
            oli1.Quantity = 1;
            oli1.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli1.MC_Line_Status__c = 'Added';
            QliList.add(oli1); 
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.QuoteId = qut.Id;
            oli2.vlocity_cmt__Product2Id__c = prod2.Id;
            oli2.PricebookEntryId = objpricebookentry.Id;
            oli2.AvgPriceFLag__c = true;
            oli2.UnitPrice = 0;
            oli2.Quantity = 1;
            oli2.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli2.MC_Line_Status__c = 'Updated';
            QliList.add(oli2);
            
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.QuoteId = qut.Id;
            oli3.vlocity_cmt__Product2Id__c = prod2.Id;
            oli3.PricebookEntryId = objpricebookentry.Id;
            oli3.AvgPriceFLag__c = true;
            oli3.UnitPrice = 0;
            oli3.Quantity = 1;
            oli3.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli3.MC_Line_Status__c = 'Added';            
            QliList.add(oli3);               
            Insert QliList;
            
            oli3.vlocity_cmt__ParentItemId__c = oli2.id;
            update oli3;
            List<Quote> quoteList = [Select id,opportunityid from quote where name='Test Quote' LIMIT 1];
        
            Map<String,Object> inputMap = new Map<String,Object>();
            inputMap.put('cartId',quoteList[0].id);
            inputMap.put('OpportunityId',quoteList[0].opportunityid);
            test.startTest();
            //test 1
            MC_AgreementsValidation mc = new MC_AgreementsValidation();
            mc.invokeMethod('AgreementValidationforHeader', inputMap, inputMap, inputMap);      
            test.stopTest();
            
        }        
    }  
     testMethod public static void smartConnectValidations()
    {
        User salesManager;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        MC_OfferCreation_ObjSplit__c obj = new MC_OfferCreation_ObjSplit__c();
        obj.name = 'Mobile Offer Specification';
        obj.fieldsToAdd__c = 'TeliaSE_MC_Binding_Time__c';
        obj.ObjType__c = 'Mobile Offer Specificationc';
        insert obj;
        
        List<MC_RangeAttributePricingMatrixSettings__c> matrixsetting = new List<MC_RangeAttributePricingMatrixSettings__c>();
        MC_RangeAttributePricingMatrixSettings__c mcRange = new MC_RangeAttributePricingMatrixSettings__c();
        mcRange.Active__c = true;
        mcRange.Name = 'Large_Office365';
        mcRange.Customer_Segment__c = 'Enterprise Large';
        mcRange.Matrix_Name__c = 'PriceMatrix_Office365';
        mcRange.ProcedureName__c = 'Small_Office365_RangeAttributePricingProcedure';
        mcRange.Product_Family_Code__c = 'MOB_MULTI_TOTAL';    
        matrixsetting.add(mcRange);
        insert matrixsetting;
        
        //Insert object Type
        List<vlocity_cmt__ObjectClass__c> objectClassList = new List<vlocity_cmt__ObjectClass__c>();
        vlocity_cmt__ObjectClass__c objectClass1 = new vlocity_cmt__ObjectClass__c();
        objectClass1.Name = 'Mobile Offer Specification';    
        objectClass1.vlocity_cmt__IsActive__c = True;
        objectClass1.vlocity_cmt__ObjectApiName__c = 'Product2';
        objectClassList.add(objectClass1);
        
        vlocity_cmt__ObjectClass__c objectClass2 = new vlocity_cmt__ObjectClass__c();
        objectClass2.Name = 'Smart Connect Offer Spec';    
        objectClass2.vlocity_cmt__IsActive__c = True;
        objectClass2.vlocity_cmt__ObjectApiName__c = 'Product2';
        objectClassList.add(objectClass2);
        
        vlocity_cmt__ObjectClass__c objectClass3 = new vlocity_cmt__ObjectClass__c();
        objectClass3.Name = 'Virtual Offer Products';    
        objectClass3.vlocity_cmt__IsActive__c = True;
        objectClass3.vlocity_cmt__ObjectApiName__c = 'Product2';
        objectClassList.add(objectClass3);
        insert objectClassList;
        
        //Insert Products
        List<Product2> prodList = new List<product2>();
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = objectClass1.Id;
        prod1.TeliaSE_Subscription_Type__c = '98';
        prod1.ProductCode='MOB_MULTI_TOTAL_V3';
        
        Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        prod2.vlocity_cmt__ObjectTypeId__c = objectClass2.Id;
        prod2.ProductCode='SC_OFFER';
        //prod2.TeliaSE_Price_Flag__c = true;
        
        Product2 prod3 = Test_DataFactory.createProducts(1)[0];
        prod3.vlocity_cmt__ObjectTypeId__c = objectClass2.Id;
        prod3.TeliaSE_TemplateCategory__c ='UserPackages';
        prod3.ProductCode='SC_STANDARD';
        
        Product2 prod4 = Test_DataFactory.createProducts(1)[0];
        prod4.vlocity_cmt__ObjectTypeId__c = objectClass3.Id;
        prod4.ProductCode='MOB_ADDON_SUBS1';
        
        Product2 prod5 = Test_DataFactory.createProducts(1)[0];
        prod5.vlocity_cmt__ObjectTypeId__c = objectClass1.Id;
        //prod5.TeliaSE_Subscription_Type__c = '98';
        prod5.ProductCode='C-OFFICE-365';
        
        prodList.add(prod1);
        prodList.add(prod2);
        prodList.add(prod3);
        prodList.add(prod4);
        prodList.add(prod5);
        
        insert prodList;
        
        TeliaSE_PortfolioIdentifiers__c portfolioTotal=new TeliaSE_PortfolioIdentifiers__c();
        portfolioTotal.Name='Mobile_Total';
        portfolioTotal.ProductId__c='01t1p0000095vXVAAY';
        portfolioTotal.NewProductCode__c='MOB_MULTI_TOTAL_V3';
        portfolioTotal.OldProductCode__c='MOB_MULTI_TOTAL_V2';
        portfolioTotal.RetiredPortfolio__c='01t1p0000081yO6AAI';
        insert portfolioTotal;
        
        //Insert Pricebook Entries
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        PricebookEntry objpricebookentry =new PricebookEntry();
        objpricebookentry.Product2ID = prod1.id;
        objpricebookentry.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry.UnitPrice=23.50;
        objpricebookentry.UseStandardPrice=false;
        objpricebookentry.isActive=true;//Add this line
        pbeList.add(objpricebookentry);
        
        PricebookEntry objpricebookentry1 =new PricebookEntry();
        objpricebookentry1.Product2ID = prod2.id;
        objpricebookentry1.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry1.UnitPrice=23.50;
        objpricebookentry1.UseStandardPrice=false;
        objpricebookentry1.isActive=true;//Add this line
        pbeList.add(objpricebookentry1);
        
        PricebookEntry objpricebookentry2 =new PricebookEntry();
        objpricebookentry2.Product2ID = prod3.id;
        objpricebookentry2.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry2.UnitPrice=23.50;
        objpricebookentry2.UseStandardPrice=false;
        objpricebookentry2.isActive=true;//Add this line
        pbeList.add(objpricebookentry2);
        
        PricebookEntry objpricebookentry3 =new PricebookEntry();
        objpricebookentry3.Product2ID = prod4.id;
        objpricebookentry3.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry3.UnitPrice=23.50;
        objpricebookentry3.UseStandardPrice=false;
        objpricebookentry3.isActive=true;//Add this line
        pbeList.add(objpricebookentry3);
        
        insert pbeList;
        
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
            oli1.TeliaSE_MC_Binding_Time__c = '12 months';
            oli1.Quantity = 1;
            oli1.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli1.MC_Line_Status__c = 'Added';
            oli1.TeliaSE_Root_Product__c = prod1.Id;
            QliList.add(oli1); 
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.QuoteId = qut.Id;
            oli2.Product2Id = prod2.Id;
            oli2.vlocity_cmt__Product2Id__c = prod2.Id;
            oli2.PricebookEntryId = objpricebookentry1.Id;
            oli2.UnitPrice = 0;
            oli2.TeliaSE_MC_Binding_Time__c = '36 months';
            oli2.MC_Reprice_Required__c = true;
            oli2.Quantity = 1;
            oli2.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli1.MC_Line_Status__c = 'Added';
            oli2.TeliaSE_Root_Product__c = prod2.Id;
            QliList.add(oli2);
            
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.QuoteId = qut.Id;
            oli3.Product2Id = prod3.Id;
            oli3.vlocity_cmt__Product2Id__c = prod3.Id;
            oli3.PricebookEntryId = objpricebookentry2.Id;
            oli3.UnitPrice = 0;
            oli3.Quantity = 1;
            oli3.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli3.TeliaSE_MC_Customer_Requested_Price__c = 98;
            oli3.MC_Line_Status__c = 'Added';     
            oli3.TeliaSE_ParentClusterCode__c = 'SC_KLU_BAS';
            oli3.TeliaSE_Root_Product__c = prod2.Id;
            QliList.add(oli3);
            
            QuoteLineItem oli4 = new QuoteLineItem();
            oli4.QuoteId = qut.Id;
            oli4.Product2Id = prod4.Id;
            oli4.vlocity_cmt__Product2Id__c = prod4.Id;
            oli4.PricebookEntryId = objpricebookentry3.Id;
            oli4.UnitPrice = 0;
            oli4.Quantity = 1;
            oli4.MC_Line_Status__c = 'Added'; 
            oli4.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli4.TeliaSE_ParentClusterCode__c = 'bas';
            oli4.TeliaSE_Root_Product__c = prod1.Id;
            QliList.add(oli4);  
            
            QuoteLineItem oli5 = new QuoteLineItem();
            oli5.QuoteId = qut.Id;
            oli5.Product2Id = prod3.Id;
            oli5.vlocity_cmt__Product2Id__c = prod3.Id;
            oli5.PricebookEntryId = objpricebookentry2.Id;
            oli5.UnitPrice = 0;
            oli5.Quantity = 1;
            oli5.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli5.TeliaSE_MC_Customer_Requested_Price__c = 99;
            oli5.MC_Line_Status__c = 'Added';     
            oli5.TeliaSE_ParentClusterCode__c = 'SC_KLU_PLUS';
            oli5.TeliaSE_Root_Product__c = prod2.Id;
            QliList.add(oli5);
            
            QuoteLineItem oli6 = new QuoteLineItem();
            oli6.QuoteId = qut.Id;
            oli6.Product2Id = prod4.Id;
            oli6.vlocity_cmt__Product2Id__c = prod4.Id;
            oli6.PricebookEntryId = objpricebookentry3.Id;
            oli6.UnitPrice = 0;
            oli6.Quantity = 1;
            oli6.MC_Line_Status__c = 'Added'; 
            oli6.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli6.TeliaSE_ParentClusterCode__c = 'plus';
            oli6.TeliaSE_Root_Product__c = prod1.Id;
            QliList.add(oli6);
            
            QuoteLineItem oli7 = new QuoteLineItem();
            oli7.QuoteId = qut.Id;
            oli7.Product2Id = prod5.Id;
            oli7.vlocity_cmt__Product2Id__c = prod5.Id;
            oli7.PricebookEntryId = objpricebookentry3.Id;
            oli7.vlocity_cmt__ParentItemId__c = null;
            oli7.UnitPrice = 0;
            oli7.Quantity = 1;
            oli7.MC_Line_Status__c = 'Added'; 
            //oli7.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            //oli7.TeliaSE_ParentClusterCode__c = 'plus';
            oli7.TeliaSE_Root_Product__c = prod5.Id;
            QliList.add(oli7);
                         
            Insert QliList;
            
            oli3.vlocity_cmt__ParentItemId__c = oli2.id;
            update oli3;
            oli4.vlocity_cmt__ParentItemId__c = oli1.id;
            update oli4;
            

          List<Quote> quoteList = [Select id,opportunityid from quote where name='Test Quote' LIMIT 1];
            Map<String,Object> inputMap = new Map<String,Object>();
            Map<String,Object> outputMap = new Map<String,Object>();
            inputMap.put('cartId',quoteList[0].id);
            inputMap.put('OpportunityId',quoteList[0].opportunityid);
            inputMap.put('valideraFlag',true);
            test.startTest();
            MC_AgreementsValidation mc = new MC_AgreementsValidation();
            mc.invokeMethod('AgreementValidationforHeader', inputMap, inputMap, inputMap);  
            oli6.TeliaSE_ParentClusterCode__c = 'large';
            update oli6;
            prod2.TeliaSE_Price_Flag__c = true;
            update prod2;
            mc.invokeMethod('AgreementValidationforHeader', inputMap, inputMap, inputMap); 
            boolean valideraFlag=true;
            inputMap.put('valideraFlag',valideraFlag);
            //MC_AgreementsValidation.checkBasSubscriptionAndAttribute(QliList,outputMap,valideraFlag);
            oli7.TeliaSE_ParentClusterCode__c = 'plus';
            update oli7;
            mc.invokeMethod('AgreementValidationforHeader', inputMap, inputMap, inputMap); 
            test.stopTest();
            
        }        
    }   
    testMethod public static void test()
    {
        User salesManager;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        MC_OfferCreation_ObjSplit__c obj = new MC_OfferCreation_ObjSplit__c();
        obj.name = 'Mobile Offer Specification';
        obj.fieldsToAdd__c = 'TeliaSE_MC_Binding_Time__c';
        obj.ObjType__c = 'Mobile Offer Specificationc';
        insert obj;
        
        List<MC_RangeAttributePricingMatrixSettings__c> matrixsetting = new List<MC_RangeAttributePricingMatrixSettings__c>();
        MC_RangeAttributePricingMatrixSettings__c mcRange = new MC_RangeAttributePricingMatrixSettings__c();
        mcRange.Active__c = true;
        mcRange.Name = 'Large_Office365';
        mcRange.Customer_Segment__c = 'Enterprise Large';
        mcRange.Matrix_Name__c = 'PriceMatrix_Office365';
        mcRange.ProcedureName__c = 'Small_Office365_RangeAttributePricingProcedure';
        mcRange.Product_Family_Code__c = 'MOB_MULTI_TOTAL';    
        matrixsetting.add(mcRange);
        insert matrixsetting;
        
        //Insert object Type
        List<vlocity_cmt__ObjectClass__c> objectClassList = new List<vlocity_cmt__ObjectClass__c>();
        vlocity_cmt__ObjectClass__c objectClass1 = new vlocity_cmt__ObjectClass__c();
        objectClass1.Name = 'Mobile Offer Specification';    
        objectClass1.vlocity_cmt__IsActive__c = True;
        objectClass1.vlocity_cmt__ObjectApiName__c = 'Product2';
        objectClassList.add(objectClass1);
        
        vlocity_cmt__ObjectClass__c objectClass2 = new vlocity_cmt__ObjectClass__c();
        objectClass2.Name = 'Smart Connect Offer Spec';    
        objectClass2.vlocity_cmt__IsActive__c = True;
        objectClass2.vlocity_cmt__ObjectApiName__c = 'Product2';
        objectClassList.add(objectClass2);
        
        vlocity_cmt__ObjectClass__c objectClass3 = new vlocity_cmt__ObjectClass__c();
        objectClass3.Name = 'Broadband Datanet Offering Spec';    
        objectClass3.vlocity_cmt__IsActive__c = True;
        objectClass3.vlocity_cmt__ObjectApiName__c = 'Product2';
        objectClassList.add(objectClass3);
        
        vlocity_cmt__ObjectClass__c objectClass4 = new vlocity_cmt__ObjectClass__c();
        objectClass4.Name = 'Operator Connect Offer Spec';    
        objectClass4.vlocity_cmt__IsActive__c = True;
        objectClass4.vlocity_cmt__ObjectApiName__c = 'Product2';
        objectClassList.add(objectClass4);

        insert objectClassList;
        
        
        
        //Insert Products
        List<Product2> prodList = new List<product2>();
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = objectClass1.Id;
        prod1.TeliaSE_Subscription_Type__c = '98';
        prod1.ProductCode='MOB_MULTI_TOTAL_V3';
        
        Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        prod2.vlocity_cmt__ObjectTypeId__c = objectClass2.Id;
        prod2.ProductCode='SC_OFFER';
        //prod2.TeliaSE_Price_Flag__c = true;
        
        Product2 prod3 = Test_DataFactory.createProducts(1)[0];
        prod3.vlocity_cmt__ObjectTypeId__c = objectClass2.Id;
        prod3.TeliaSE_TemplateCategory__c ='UserPackages';
        prod3.ProductCode='SC_STANDARD';
        
        Product2 prod4 = Test_DataFactory.createProducts(1)[0];
        prod4.vlocity_cmt__ObjectTypeId__c = objectClass1.Id;
        prod4.ProductCode='MOB_ADDON_SUBS1';
        
        Product2 prod5 = Test_DataFactory.createProducts(1)[0];
        prod5.vlocity_cmt__ObjectTypeId__c = objectClass1.Id;
        //prod5.TeliaSE_Subscription_Type__c = '98';
        prod5.ProductCode='C-OFFICE-365';
        
        Product2 prod6 = Test_DataFactory.createProducts(1)[0];
        prod6.vlocity_cmt__ObjectTypeId__c = objectClass3.Id;
        prod6.ProductCode='B2B-DATANET-SEKUNDAR-ACCESS-FIBER-10MB';
        
        Product2 prod7 = Test_DataFactory.createProducts(1)[0];
        prod7.vlocity_cmt__ObjectTypeId__c = objectClass4.Id;
        prod7.ProductCode='OC_OFFER';
        
        prodList.add(prod1);
        prodList.add(prod2);
        prodList.add(prod3);
        prodList.add(prod4);
        prodList.add(prod5);
        prodList.add(prod6);
        prodList.add(prod7);
        
        
        insert prodList;
        System.debug('prod4__'+prod4.vlocity_cmt__ObjectTypeId__r.Name);
        System.debug('prod4__'+prod4.vlocity_cmt__ObjectTypeId__c);
        
        
        TeliaSE_PortfolioIdentifiers__c portfolioTotal=new TeliaSE_PortfolioIdentifiers__c();
        portfolioTotal.Name='Mobile_Total';
        portfolioTotal.ProductId__c='01t1p0000095vXVAAY';
        portfolioTotal.NewProductCode__c='MOB_MULTI_TOTAL_V3';
        portfolioTotal.OldProductCode__c='MOB_MULTI_TOTAL_V2';
        portfolioTotal.RetiredPortfolio__c='01t1p0000081yO6AAI';
        insert portfolioTotal;
        
        //Insert Pricebook Entries
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        PricebookEntry objpricebookentry =new PricebookEntry();
        objpricebookentry.Product2ID = prod1.id;
        objpricebookentry.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry.UnitPrice=23.50;
        objpricebookentry.UseStandardPrice=false;
        objpricebookentry.isActive=true;//Add this line
        pbeList.add(objpricebookentry);
        
        PricebookEntry objpricebookentry1 =new PricebookEntry();
        objpricebookentry1.Product2ID = prod2.id;
        objpricebookentry1.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry1.UnitPrice=23.50;
        objpricebookentry1.UseStandardPrice=false;
        objpricebookentry1.isActive=true;//Add this line
        pbeList.add(objpricebookentry1);
        
        PricebookEntry objpricebookentry2 =new PricebookEntry();
        objpricebookentry2.Product2ID = prod3.id;
        objpricebookentry2.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry2.UnitPrice=23.50;
        objpricebookentry2.UseStandardPrice=false;
        objpricebookentry2.isActive=true;//Add this line
        pbeList.add(objpricebookentry2);
        
        PricebookEntry objpricebookentry3 =new PricebookEntry();
        objpricebookentry3.Product2ID = prod4.id;
        objpricebookentry3.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry3.UnitPrice=23.50;
        objpricebookentry3.UseStandardPrice=false;
        objpricebookentry3.isActive=true;//Add this line
        pbeList.add(objpricebookentry3);
        
        PricebookEntry objpricebookentry4 =new PricebookEntry();
        objpricebookentry4.Product2ID = prod6.id;
        objpricebookentry4.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry4.UnitPrice=23.50;
        objpricebookentry4.UseStandardPrice=false;
        objpricebookentry4.isActive=true;//Add this line
        pbeList.add(objpricebookentry4);
        
        PricebookEntry objpricebookentry5 =new PricebookEntry();
        objpricebookentry5.Product2ID = prod7.id;
        objpricebookentry5.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry5.UnitPrice=23.50;
        objpricebookentry5.UseStandardPrice=false;
        objpricebookentry5.isActive=true;//Add this line
        pbeList.add(objpricebookentry5);
        
        insert pbeList;
        
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
            oli1.TeliaSE_MC_Binding_Time__c = '12 months';
            oli1.Quantity = 1;
            oli1.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli1.MC_Line_Status__c = 'Added';
            oli1.TeliaSE_Root_Product__c = prod1.Id;
            QliList.add(oli1); 
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.QuoteId = qut.Id;
            oli2.Product2Id = prod2.Id;
            oli2.vlocity_cmt__Product2Id__c = prod2.Id;
            oli2.PricebookEntryId = objpricebookentry1.Id;
            oli2.UnitPrice = 0;
            oli2.TeliaSE_MC_Binding_Time__c = '36 months';
            oli2.MC_Reprice_Required__c = true;
            oli2.Quantity = 1;
            oli2.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli1.MC_Line_Status__c = 'Added';
            oli2.TeliaSE_Root_Product__c = prod2.Id;
            QliList.add(oli2);
            
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.QuoteId = qut.Id;
            oli3.Product2Id = prod3.Id;
            oli3.vlocity_cmt__Product2Id__c = prod3.Id;
            oli3.PricebookEntryId = objpricebookentry2.Id;
            oli3.UnitPrice = 0;
            oli3.Quantity = 1;
            oli3.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli3.TeliaSE_MC_Customer_Requested_Price__c = 98;
            oli3.MC_Line_Status__c = 'Added';     
            oli3.TeliaSE_ParentClusterCode__c = 'SC_KLU_BAS';
            oli3.TeliaSE_Root_Product__c = prod2.Id;
            QliList.add(oli3);
            
            QuoteLineItem oli4 = new QuoteLineItem();
            oli4.QuoteId = qut.Id;
            oli4.Product2Id = prod4.Id;
            oli4.vlocity_cmt__Product2Id__c = prod4.Id;
            oli4.PricebookEntryId = objpricebookentry3.Id;
            oli4.UnitPrice = 0;
            oli4.Quantity = 1;
            oli4.MC_Line_Status__c = 'Added'; 
            oli4.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli4.TeliaSE_ParentClusterCode__c = 'bas';
            oli4.TeliaSE_Root_Product__c = prod1.Id;
            QliList.add(oli4);  
            
            QuoteLineItem oli5 = new QuoteLineItem();
            oli5.QuoteId = qut.Id;
            oli5.Product2Id = prod3.Id;
            oli5.vlocity_cmt__Product2Id__c = prod3.Id;
            oli5.PricebookEntryId = objpricebookentry2.Id;
            oli5.UnitPrice = 0;
            oli5.Quantity = 1;
            oli5.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli5.TeliaSE_MC_Customer_Requested_Price__c = 99;
            oli5.MC_Line_Status__c = 'Added';     
            oli5.TeliaSE_ParentClusterCode__c = 'SPLUS';
            oli5.TeliaSE_Root_Product__c = prod2.Id;
            QliList.add(oli5);
            
            QuoteLineItem oli6 = new QuoteLineItem();
            oli6.QuoteId = qut.Id;
            oli6.Product2Id = prod4.Id;
            oli6.vlocity_cmt__Product2Id__c = prod4.Id;
            oli6.PricebookEntryId = objpricebookentry3.Id;
            oli6.UnitPrice = 0;
            oli6.Quantity = 1;
            oli6.MC_Line_Status__c = 'Added'; 
            oli6.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            oli6.TeliaSE_ParentClusterCode__c = 'plus';
            oli6.TeliaSE_Root_Product__c = prod1.Id;
            QliList.add(oli6);
            
            QuoteLineItem oli7 = new QuoteLineItem();
            oli7.QuoteId = qut.Id;
            oli7.Product2Id = prod5.Id;
            oli7.vlocity_cmt__Product2Id__c = prod5.Id;
            oli7.PricebookEntryId = objpricebookentry3.Id;
            oli7.vlocity_cmt__ParentItemId__c = null;
            oli7.UnitPrice = 0;
            oli7.Quantity = 1;
            oli7.MC_Line_Status__c = 'Added'; 
            //oli7.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RT_PRECHECK":false,"ATT_RT_PRICEAVG":true,"ATT_RT_Bandwidth":100000,"ATT_RT_CMTP":"12 months","ATT_RT_NoU":776,"ATT_PRICE_ATTR":"CO"}';
            //oli7.TeliaSE_ParentClusterCode__c = 'plus';
            oli7.TeliaSE_Root_Product__c = prod5.Id;
            QliList.add(oli7);
                         
            QuoteLineItem oli8 = new QuoteLineItem();
            oli8.QuoteId = qut.Id;
            oli8.Product2Id = prod6.Id;
            oli8.vlocity_cmt__Product2Id__c = prod6.Id;
            oli8.PricebookEntryId = objpricebookentry4.Id;
            oli8.UnitPrice = 0;
            oli8.Quantity = 1;
            oli8.MC_Line_Status__c = 'Added'; 
            oli8.TeliaSE_Root_Product__c = prod6.Id;
            QliList.add(oli8);
            
            QuoteLineItem oli9 = new QuoteLineItem();
            oli9.QuoteId = qut.Id;
            oli9.Product2Id = prod6.Id;
            oli9.vlocity_cmt__Product2Id__c = prod7.Id;
            oli9.PricebookEntryId = objpricebookentry5.Id;
            oli9.UnitPrice = 0;
            oli9.Quantity = 1;
            oli9.MC_Line_Status__c = 'Added'; 
            oli9.TeliaSE_Root_Product__c = prod7.Id;
            QliList.add(oli9);
                         
            Insert QliList;
            
            oli3.vlocity_cmt__ParentItemId__c = oli2.id;
            update oli3;
            oli4.vlocity_cmt__ParentItemId__c = oli1.id;
            update oli4;
            

          List<Quote> quoteList = [Select id,opportunityid from quote where name='Test Quote' LIMIT 1];
            Map<String,Object> inputMap = new Map<String,Object>();
            Map<String,Object> outputMap = new Map<String,Object>();
            inputMap.put('cartId',quoteList[0].id);
            inputMap.put('OpportunityId',quoteList[0].opportunityid);
            inputMap.put('valideraFlag',true);
            test.startTest();
            MC_AgreementsValidation mc = new MC_AgreementsValidation();
            mc.invokeMethod('AgreementValidationforHeader', inputMap, inputMap, inputMap);  
            oli6.TeliaSE_ParentClusterCode__c = 'large';
            update oli6;
            prod2.TeliaSE_Price_Flag__c = true;
            update prod2;
            mc.invokeMethod('AgreementValidationforHeader', inputMap, inputMap, inputMap); 
            boolean valideraFlag=true;
            inputMap.put('valideraFlag',valideraFlag);
            //MC_AgreementsValidation.checkBasSubscriptionAndAttribute(QliList,outputMap,valideraFlag);
            oli7.TeliaSE_ParentClusterCode__c = 'plus';
            update oli7;
            mc.invokeMethod('AgreementValidationforHeader', inputMap, inputMap, inputMap); 
            test.stopTest();
            
        }        
    }
}