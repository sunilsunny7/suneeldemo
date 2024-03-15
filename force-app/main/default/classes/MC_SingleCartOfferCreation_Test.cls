@isTest
public class MC_SingleCartOfferCreation_Test {

    @testSetup static void testDataSetup(){
        User salesManager;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        MC_OfferCreation_ObjSplit__c obj = new MC_OfferCreation_ObjSplit__c();
        obj.name = 'OFFICE365 Offer Spec';
        obj.fieldsToAdd__c = 'TeliaSE_MC_Binding_Time__c';
        obj.ObjType__c = 'OFFICE365 Offer Spec';
        insert obj;
        
        vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
        objClass.Name = 'Mobile Offer Specification';    
        objClass.vlocity_cmt__IsActive__c = True;
        objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass;
        
        vlocity_cmt__ObjectClass__c objClass2 = new vlocity_cmt__ObjectClass__c();
        objClass2.Name = 'Personal Technician Offer Specification';    
        objClass2.vlocity_cmt__IsActive__c = True;
        objClass2.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass2;
        
        vlocity_cmt__ObjectClass__c objClass3 = new vlocity_cmt__ObjectClass__c();
        objClass3.Name = 'OFFICE365 Offer Spec';    
        objClass3.vlocity_cmt__IsActive__c = True;
        objClass3.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass3;
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod.Name = 'Jobbmobil 15 GB';
        prodList.add(prod);
        
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod1.Name = 'Jobbmobil 40 GB';
        prodList.add(prod1);
        
        Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        prod2.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod2.Name = 'Test';
        prodList.add(prod2);
        
        Product2 prod3 = Test_DataFactory.createProducts(1)[0];
        prod3.vlocity_cmt__ObjectTypeId__c = objClass2.Id;
        prod3.Name = 'PT product';
        prodList.add(prod3);
        
        Product2 prod4 = Test_DataFactory.createProducts(1)[0];
        prod4.vlocity_cmt__ObjectTypeId__c = objClass2.Id;
        prod4.Name = 'PT test 2';
        prodList.add(prod4);
        
        Product2 prod5 = Test_DataFactory.createProducts(1)[0];
        prod5.vlocity_cmt__ObjectTypeId__c = objClass2.Id;
        prod5.Name = 'PT test 3';
        prodList.add(prod5);
        
        Product2 prod6 = Test_DataFactory.createProducts(1)[0];
        prod6.vlocity_cmt__ObjectTypeId__c = objClass3.Id;
        prod6.Name = 'Office 1';
        prodList.add(prod6);
        
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
            objpricebookentry2.Product2ID = prod3.id;
            objpricebookentry2.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry2.UnitPrice=23.50;
            objpricebookentry2.UseStandardPrice=false;
            objpricebookentry2.isActive=true;//Add this line
            insert objpricebookentry2;
            
            PricebookEntry objpricebookentry3 =new PricebookEntry();
            objpricebookentry3.Product2ID = prod5.id;
            objpricebookentry3.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry3.UnitPrice=23.50;
            objpricebookentry3.UseStandardPrice=false;
            objpricebookentry3.isActive=true;//Add this line
            insert objpricebookentry3;
            
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';  
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;
            qut.TeliaSE_MC_Sales_Flow_Identifier__c = 'New Sales';
            insert qut;
            
            Quote qut2 = new Quote();
            qut2.Name='Offer Quote';
            qut2.status = 'Draft';  
            qut2.opportunityId = opp.id;
            qut2.Pricebook2ID = stdPriceBookRecId;
            qut2.TeliaSE_MC_Sales_Flow_Identifier__c = 'New Sales';
            insert qut2;
            
            List<QuoteLineItem> qliList = new List<QuoteLineItem>();
            QuoteLineItem oli = new QuoteLineItem();
            oli.QuoteId = qut.Id;
            oli.Product2Id = prod1.Id;
            oli.vlocity_cmt__Product2Id__c = prod1.id;
            oli.PricebookEntryId = objpricebookentry.Id;
            oli.TeliaSE_MC_FACallOffQuantity__c = 2;
            oli.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id);
            oli.UnitPrice = 0;
            oli.Quantity = 1;
            qliList.add(oli);
            
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.QuoteId = qut.Id;
            oli1.Product2Id = prod2.Id;
            oli1.vlocity_cmt__Product2Id__c = prod2.id;
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.TeliaSE_MC_FACallOffQuantity__c = 2;
            oli1.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id);
            oli1.UnitPrice = 0;
            oli1.Quantity = 1;
            qliList.add(oli1);
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.QuoteId = qut.Id;
            oli2.Product2Id = prod3.Id;
            oli2.vlocity_cmt__Product2Id__c = prod3.id;
            oli2.PricebookEntryId = objpricebookentry.Id;
            oli2.TeliaSE_MC_FACallOffQuantity__c = 2;
            oli2.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod4.Id)+'<'+String.valueOf(prod3.Id);
            oli2.UnitPrice = 0;
            oli2.Quantity = 1;
            qliList.add(oli2);
            
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.QuoteId = qut.Id;
            oli3.Product2Id = prod5.Id;
            oli3.vlocity_cmt__Product2Id__c = prod5.id;
            oli3.PricebookEntryId = objpricebookentry.Id;
            oli3.TeliaSE_MC_FACallOffQuantity__c = 2;
            oli3.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod5.Id);
            oli3.UnitPrice = 0;
            oli3.Quantity = 1;
            qliList.add(oli3);
            
            QuoteLineItem oli4 = new QuoteLineItem();
            oli4.QuoteId = qut.Id;
            oli4.Product2Id = prod4.Id;
            oli4.vlocity_cmt__Product2Id__c = prod4.id;
            oli4.PricebookEntryId = objpricebookentry.Id;
            oli4.TeliaSE_MC_FACallOffQuantity__c = 2;
            oli4.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod4.Id);
            oli4.UnitPrice = 0;
            oli4.Quantity = 1;
            qliList.add(oli4);
                    
            QuoteLineItem oli5 = new QuoteLineItem();
            oli5.QuoteId = qut.Id;
            oli5.Product2Id = prod2.Id;
            oli5.vlocity_cmt__Product2Id__c = prod2.id;
            oli5.PricebookEntryId = objpricebookentry.Id;
            oli5.TeliaSE_MC_FACallOffQuantity__c = 2;
            oli5.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod.Id)+'<'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id);
            oli5.UnitPrice = 0;
            oli5.Quantity = 1;
            qliList.add(oli5);
            
            QuoteLineItem oli6 = new QuoteLineItem();
            oli6.QuoteId = qut.Id;
            oli6.Product2Id = prod6.Id;
            oli6.vlocity_cmt__Product2Id__c = prod6.id;
            oli6.PricebookEntryId = objpricebookentry.Id;
            oli6.TeliaSE_MC_FACallOffQuantity__c = 2;
            oli6.vlocity_cmt__ProductHierarchyPath__c =String.valueOf(prod6.id);
            oli6.UnitPrice = 0;
            oli6.Quantity = 1;
            oli6.TeliaSE_MC_Binding_Time__c = '36 months';
            qliList.add(oli6);
            
            QuoteLineItem oli7 = new QuoteLineItem();
            oli7.QuoteId = qut.Id;
            oli7.Product2Id = prod6.Id;
            oli7.vlocity_cmt__Product2Id__c = prod6.id;
            oli7.PricebookEntryId = objpricebookentry.Id;
            oli7.TeliaSE_MC_FACallOffQuantity__c = 2;
            oli7.vlocity_cmt__ProductHierarchyPath__c =String.valueOf(prod6.id);
            oli7.UnitPrice = 0;
            oli7.Quantity = 1;
            oli7.TeliaSE_MC_Binding_Time__c = '12 months';
            qliList.add(oli7);
            
            QuoteLineItem oli8 = new QuoteLineItem();
            oli8.QuoteId = qut.Id;
            oli8.Product2Id = prod6.Id;
            oli8.vlocity_cmt__Product2Id__c = prod6.id;
            oli8.PricebookEntryId = objpricebookentry.Id;
            oli8.TeliaSE_MC_FACallOffQuantity__c = 2;
            oli8.vlocity_cmt__ProductHierarchyPath__c =String.valueOf(prod.Id)+'<'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod6.id);
            oli8.UnitPrice = 0;
            oli8.Quantity = 1;
            qliList.add(oli8);
            
            QuoteLineItem oli9 = new QuoteLineItem();
            oli9.QuoteId = qut.Id;
            oli9.Product2Id = prod2.Id;
            oli9.vlocity_cmt__Product2Id__c = prod2.id;
            oli9.PricebookEntryId = objpricebookentry.Id;
            oli9.TeliaSE_MC_FACallOffQuantity__c = 21;
            oli9.vlocity_cmt__ProductHierarchyPath__c =String.valueOf(prod.Id)+'<'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod5.Id)+'<'+String.valueOf(prod6.id)+'<'+String.valueOf(prod2.Id);
            oli9.UnitPrice = 0;
            oli9.Quantity = 1;
            qliList.add(oli9);

            insert qliList;

            oli3.vlocity_cmt__ParentItemId__c = oli1.Id;
            update oli3;
        }
    }
    
    @isTest
    private static void testMethod1(){
        List<Quote> quoteList = [Select id from quote where name='Test Quote' LIMIT 1];
        
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();   
        Map<String,Object> options=new Map<String,Object>();
        
        inputMap.put('OfferQuoteId',quoteList[0].Id);
        inputMap.put('ContextId',quoteList[0].Id);
        
        Test.startTest();
        
        MC_SingleCartOfferCreation obj=new MC_SingleCartOfferCreation();        
        obj.invokeMethod('createSingleCartOffer',inputMap,outMap,options);
        
        Test.stopTest();
    }
    
    @isTest
    private static void testMethod2(){
        List<Quote> quoteList = [Select id from quote where name='Test Quote' LIMIT 1];
        List<Quote> offerQuote = [Select id from quote where name='Offer Quote' LIMIT 1];
        List<QuoteLineItem> qliList = [Select id,pricebookEntryId,product2.Id from QuoteLineItem where quoteId =:quoteList[0].Id];
          String requestMap = '{'+
        '  \"ContextId\": \"'+quoteList[0].Id+'\",'+
        '  \"OfferQuoteId\": \"'+offerQuote[0].Id+'\",'+
        '  \"requestProductList\": ['+
        '    {'+
        '      \"validate\": false,'+
        '      \"price\": false,'+
        '      \"methodName\": \"postCartsItems\",'+
        '      \"items\": ['+
        '        {'+
        '          \"parentRecord\": null,'+
        '          \"parentId\": \"'+String.valueOf(qliList[0].Product2.Id)+'\",'+
        '          \"itemId\": \"'+qliList[0].pricebookentryId+'\"'+
        '        }'+
        '      ],'+
        '      \"inputFields\": null,'+
        '      \"cartId\": \"'+offerQuote[0].Id+'\"'+
        '    },'+
        '    {'+
        '      \"validate\": false,'+
        '      \"price\": false,'+
        '      \"methodName\": \"postCartsItems\",'+
        '      \"items\": ['+
        '        {'+
        '          \"parentRecord\": null,'+
        '          \"parentId\": \"'+String.valueOf(qliList[0].Product2.Id)+'\",'+
        '          \"itemId\": \"'+qliList[0].pricebookentryId+'\"'+
        '        }'+
        '      ],'+
        '      \"inputFields\": null,'+
        '      \"cartId\": \"0Q04E000000aZw4SAE\"'+
        '    }'+
        '  ]'+
        '}';
        
        Map<String, Object> outMap = new Map<String, Object>();   
        Map<String,Object> options=new Map<String,Object>();
        Map<String, Object> inputMap = (Map<String, Object>)System.JSON.deserializeUntyped(requestMap);
        
        Test.startTest();
        
        MC_SingleCartOfferCreation obj=new MC_SingleCartOfferCreation();        
        obj.invokeMethod('updateAddToCartRequestList',inputMap,outMap,options);
        
        Test.stopTest();
    }
    
}