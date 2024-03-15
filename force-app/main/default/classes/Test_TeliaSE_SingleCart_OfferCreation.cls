@isTest
public class Test_TeliaSE_SingleCart_OfferCreation {
    
    //Static String teliaPricebook;    
    
    @isTest()
    static void createTestData(){
        User salesManager;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
                
        vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
        objClass.Name = 'Mobile Handset Product Specification';    
        objClass.vlocity_cmt__IsActive__c = True;
        objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass;

        vlocity_cmt__ObjectClass__c objClass1 = new vlocity_cmt__ObjectClass__c();
        objClass1.Name = 'Personal Technician Offer Specification';    
        objClass1.vlocity_cmt__IsActive__c = True;
        objClass1.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass1;        

        vlocity_cmt__ObjectClass__c objClass2 = new vlocity_cmt__ObjectClass__c();
        objClass2.Name = 'Hardware Offer Spec';    
        objClass2.vlocity_cmt__IsActive__c = True;
        objClass2.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass2;        

        vlocity_cmt__ObjectClass__c objClass3 = new vlocity_cmt__ObjectClass__c();
        objClass3.Name = 'Mobile Offer Specification';    
        objClass3.vlocity_cmt__IsActive__c = True;
        objClass3.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass3;         
        
        
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod.Name = 'Jobbmobil 15 GB';
        prod.TeliaSE_Subscription_Type__c = '99';
        insert prod;
        
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod1.Name = 'Jobbmobil 40 GB';
        prod1.TeliaSE_Subscription_Type__c = '98';
        insert prod1;
        
        Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        prod2.vlocity_cmt__ObjectTypeId__c = objClass1.Id;
        prod2.Name = 'Test';
        insert prod2;
        
        Product2 prod3 = Test_DataFactory.createProducts(1)[0];
        prod3.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        insert prod3;
        
        Product2 prod4 = Test_DataFactory.createProducts(1)[0];
        prod4.vlocity_cmt__ObjectTypeId__c = objClass1.Id;
        prod4.Name = 'Mobiltelefoner';
        prod4.ProductCode = 'MOB_HARDWARE_OFFER';
        insert prod4;

        Product2 prod5 = Test_DataFactory.createProducts(1)[0];
        prod5.vlocity_cmt__ObjectTypeId__c = objClass2.Id;
        prod5.Name = 'Mobiltelefoner';
        prod5.ProductCode = 'MOB_HARDWARE_OFFER';
        insert prod5;

        Product2 prod6 = Test_DataFactory.createProducts(1)[0];
        prod6.vlocity_cmt__ObjectTypeId__c = objClass3.Id;
        prod6.Name = 'Jobbsurf 50 GB';
        prod6.ProductCode = 'MOB_SURF_50';
        insert prod6;
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
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
                       
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';  
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;        
            insert qut;
            
            Quote offerQt = new Quote();
            offerQt.Name='Test Quote_offer';
            offerQt.status = 'Draft';  
            offerQt.opportunityId = opp.id;
            offerQt.Pricebook2ID = stdPriceBookRecId;
            offerQt.TeliaSE_Approval_Flag__c = False;        
            insert offerQt;

            QuoteLineItem offQli1 = new QuoteLineItem();
            offQli1.QuoteId = offerQt.Id;
            offQli1.Subscription__c = prod1.Name;
            offQli1.Product2Id = prod2.Id;
            offQli1.PricebookEntryId = objpricebookentry.Id;
            offQli1.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id);
            offQli1.UnitPrice = 0;
            offQli1.TeliaSE_MC_FACallOffQuantity__c = 3;
            //oli1.TeliaSE_Product_Object_Type__c = 'Personal Technician Offer Specification';
            offQli1.Quantity = 1;
            insert offQli1;

            QuoteLineItem offQli2 = new QuoteLineItem();
            offQli2.QuoteId = offerQt.Id;
            //oli2.Subscription__c = prod2.Name;
            offQli2.Product2Id = prod2.Id;
            offQli2.PricebookEntryId = objpricebookentry.Id;
            offQli2.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id);
            offQli2.UnitPrice = 0;
            //offQli2.vlocity_cmt__ParentItemId__c = offQli1.Id;
            offQli2.TeliaSE_MC_FACallOffQuantity__c = 3;
            offQli2.Quantity = 1;
            insert offQli2;


            QuoteLineItem offQli3 = new QuoteLineItem();
            offQli3.QuoteId = offerQt.Id;
            //oli2.Subscription__c = prod2.Name;
            offQli3.Product2Id = prod3.Id;
            offQli3.PricebookEntryId = objpricebookentry.Id;
            offQli3.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id);
            offQli3.UnitPrice = 0;
            offQli3.vlocity_cmt__ParentItemId__c = offQli2.Id;
            offQli3.TeliaSE_MC_FACallOffQuantity__c = 3;
            offQli3.Quantity = 1;
            insert offQli3;

            QuoteLineItem offQli4 = new QuoteLineItem();
            offQli4.QuoteId = offerQt.Id;
            //oli2.Subscription__c = prod2.Name;
            offQli4.Product2Id = prod4.Id;
            offQli4.PricebookEntryId = objpricebookentry.Id;
            offQli4.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id)+'<'+String.valueOf(prod4.Id);
            offQli4.UnitPrice = 0;
            offQli4.vlocity_cmt__ParentItemId__c = offQli3.Id;
            offQli4.TeliaSE_MC_FACallOffQuantity__c = 3;
            offQli4.Quantity = 1;
            insert offQli4;

            QuoteLineItem offQli5 = new QuoteLineItem();
            offQli5.QuoteId = offerQt.Id;
            //oli2.Subscription__c = prod2.Name;
            offQli5.Product2Id = prod5.Id;
            offQli5.PricebookEntryId = objpricebookentry.Id;
            offQli5.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id)+'<'+String.valueOf(prod4.Id)+'<'+String.valueOf(prod5.Id);
            offQli5.UnitPrice = 0;
            offQli5.vlocity_cmt__ParentItemId__c = offQli4.Id;
            offQli5.TeliaSE_MC_FACallOffQuantity__c = 3;
            offQli5.Quantity = 1;
            insert offQli5;
            
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.QuoteId = qut.Id;
            oli1.Subscription__c = prod1.Name;
            oli1.Product2Id = prod2.Id;
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id);
            oli1.UnitPrice = 0;
            oli1.TeliaSE_MC_FACallOffQuantity__c = 3;
            //oli1.TeliaSE_Product_Object_Type__c = 'Personal Technician Offer Specification';
            oli1.Quantity = 1;
            insert oli1;

            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.QuoteId = qut.Id;
            //oli2.Subscription__c = prod2.Name;
            oli2.Product2Id = prod2.Id;
            oli2.PricebookEntryId = objpricebookentry.Id;
            oli2.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id);
            oli2.UnitPrice = 0;
            oli2.vlocity_cmt__ParentItemId__c = oli1.Id;
            oli2.TeliaSE_MC_FACallOffQuantity__c = 3;
            oli2.Quantity = 1;
            insert oli2;


            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.QuoteId = qut.Id;
            //oli2.Subscription__c = prod2.Name;
            oli3.Product2Id = prod3.Id;
            oli3.PricebookEntryId = objpricebookentry.Id;
            oli3.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id);
            oli3.UnitPrice = 0;
            oli3.vlocity_cmt__ParentItemId__c = oli2.Id;
            oli3.TeliaSE_MC_FACallOffQuantity__c = 3;
            oli3.Quantity = 1;
            insert oli3;

            QuoteLineItem oli4 = new QuoteLineItem();
            oli4.QuoteId = qut.Id;
            //oli2.Subscription__c = prod2.Name;
            oli4.Product2Id = prod4.Id;
            oli4.PricebookEntryId = objpricebookentry.Id;
            oli4.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id)+'<'+String.valueOf(prod4.Id);
            oli4.UnitPrice = 0;
            oli4.vlocity_cmt__ParentItemId__c = oli3.Id;
            oli4.TeliaSE_MC_FACallOffQuantity__c = 3;
            oli4.Quantity = 1;
            insert oli4;

            QuoteLineItem oli5 = new QuoteLineItem();
            oli5.QuoteId = qut.Id;
            //oli2.Subscription__c = prod2.Name;
            oli5.Product2Id = prod4.Id;
            oli5.PricebookEntryId = objpricebookentry.Id;
            oli5.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id)+'<'+String.valueOf(prod4.Id)+'<'+String.valueOf(prod5.Id);
            oli5.UnitPrice = 0;
            oli5.vlocity_cmt__ParentItemId__c = oli4.Id;
            oli5.TeliaSE_MC_FACallOffQuantity__c = 3;
            oli5.Quantity = 1;
            insert oli5;

        String json = '{'+
        '  \"ContextId\": \"'+qut.Id+'\",'+
        '  \"OfferCartId\": \"'+offerQt.Id+'\",'+
        '  \"secondLevelProdList\": ['+
        '    {'+
        '      \"prodIdToBeAdded\": \"'+prod2.Id+'\",'+
        '      \"priceBookEntryIdToBeAdded\": \"'+objpricebookentry.Id+'\",'+
        '      \"01t1w000003WsyfAACCallOffQty\": \"3\",'+
        '      \"productHierarchyPath\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'",'+
        '      \"productName\": \"Apple iPhone 8 64GB Rymdgrå\",'+
        '      \"01u1w000008Tl80AAC\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'",'+
        '      \"Quantity\": \"3\"'+
        '    },'+
        '    {'+
        '      \"prodIdToBeAdded\": \"'+prod3.Id+'\",'+
        '      \"priceBookEntryIdToBeAdded\": \"'+objpricebookentry.Id+'\",'+
        '      \"01t1p0000081yKPAAYCallOffQty\": null,'+
        '      \"productHierarchyPath\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'",'+
        '      \"productName\": \"Supportärende, Tekniker På Plats Plus (1 ärende)\",'+
        '      \"01u1p00000RX1JXAA1\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'"'+
        '    }'+
        '  ],'+
        '  \"secondLevelProdSet\": ['+
        '    \"01u1w000008Tl80AAC\",'+
        '    \"01u1p00000RX1JXAA1\"'+
        '  ],'+
        '  \"secondLevelProducts\": ['+
        '    {'+
        '      \"validate\": false,'+
        '      \"price\": false,'+
        '      \"methodName\": \"postCartsItems\",'+
        '      \"items\": ['+
        '        {'+
        '          \"parentRecord\": {'+
        '            \"records\": ['+
        '              {'+
        '                \"productHierarchyPath\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'",'+
        '                \"parentHierarchyPath\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'\"'+
        '              }'+
        '            ]'+
        '          },'+
        '          \"parentId\": \"'+oli1.Id+'\",'+
        '          \"itemId\": \"'+objpricebookentry.Id+'\"'+
        '        }'+
        '      ],'+
        '      \"inputFields\": null,'+
        '      \"cartId\": \"'+offerQt.Id+'\"'+
        '    },'+
        '    {'+
        '      \"validate\": false,'+
        '      \"price\": false,'+
        '      \"methodName\": \"postCartsItems\",'+
        '      \"items\": ['+
        '        {'+
        '          \"parentRecord\": {'+
        '            \"records\": ['+
        '              {'+
        '                \"productHierarchyPath\": \"01t1p0000081yNIAAY\",'+
        '                \"parentHierarchyPath\": \"01t1p0000081yNIAAY\"'+
        '              }'+
        '            ]'+
        '          },'+
        '          \"parentId\": \"0QL4E000000NEYAWA4\",'+
        '          \"itemId\": \"01u1p00000RX1JXAA1\"'+
        '        }'+
        '      ],'+
        '      \"inputFields\": null,'+
        '      \"cartId\": \"0Q04E000000aZw4SAE\"'+
        '    }'+
        '  ],'+
        '  \"error\": \"OK\",'+
        '  \"thirdLevelProdSet\": [],'+
        '  \"thirdLevelProdList\": [],'+
        '  \"thirdLevelProducts\": [],'+
        '  \"fourthLevelProdList\": ['+
        '    {'+
        '      \"prodIdToBeAdded\": \"'+prod4.Id+'\",'+
        '      \"priceBookEntryIdToBeAdded\": \"'+objpricebookentry.Id+'\",'+
        '      \"01t1p0000081yJvAAICallOffQty\": \"8\",'+
        '      \"productHierarchyPath\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id)+'<'+String.valueOf(prod4.Id)+'\",'+
        '      \"productName\": \"Tillkommande Supportärende på plats (per ärende)\",'+
        '      \"01u1p00000RX1JIAA1\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id)+'<'+String.valueOf(prod4.Id)+'\",'+
        '      \"Quantity\": \"8\"'+
        '    }'+
        '  ],'+
        '  \"fourthLevelProdSet\": ['+
        '    \"'+prod4.Id+'\"'+
        '  ],'+
        '  \"fourthLevelProducts\": ['+
        '    {'+
        '      \"validate\": false,'+
        '      \"price\": false,'+
        '      \"methodName\": \"postCartsItems\",'+
        '      \"items\": ['+
        '        {'+
        '          \"parentRecord\": {'+
        '            \"records\": ['+
        '              {'+
        '                \"productHierarchyPath\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id)+'<'+String.valueOf(prod4.Id)+'\",'+
        '                \"parentHierarchyPath\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id)+'<'+String.valueOf(prod4.Id)+'\"'+
        '              }'+
        '            ]'+
        '          },'+
        '          \"parentId\": \"'+offQli3.Id+'\",'+
        '          \"itemId\": \"'+prod4.Id+'\"'+
        '        }'+
        '      ],'+
        '      \"inputFields\": null,'+
        '      \"cartId\": \"'+offerQt.Id+'\"'+
        '    }'+
        '  ],'+
        '  \"fifthLevelProdSet\": [],'+
        '  \"fifthLevelProdList\": [],'+
        '  \"fifthLevelProducts\": []'+
        '}';
            
            String JsonResponse = '{'+
                '\"OfferQuoteId\": \"'+qut.Id+'\",'+
                '\"FAQLI\": ['+
                '{'+
                '\"TargetPercentage\": 4.0,'+
                 '\"RecurringPrice\": 345.0,'+
                  '\"ApprovedPercentage\": 0.0,'+
                  '\"RequestedPercentage\": 0.0,'+
                 '\"RecurringManualDiscount\": 345.0,'+
                 '\"Quantity\": 3.0,'+
                 '\"ProductType\": \"Price\",'+
                  '\"Subscription\": \"Jobbmobil 40 GB\",'+
                 '\"campaignId\": \"a641l0000004gZwAAI\",'+
                 '\"OneTimePrice\": 345.0,'+
                 '\"OneTimeManualDiscount\": 3.0,'+
                 '\"ApprovedPrice\": 79.0,'+
                '\"Name\": \"'+prod2.Name+'\"'+
                '},'+
                '{'+
                '\"TargetPercentage\": 4.0,'+
                 '\"RecurringPrice\": 345.0,'+
                  '\"ApprovedPercentage\": 0.0,'+
                  '\"RequestedPercentage\": 2.0,'+
                 '\"RecurringManualDiscount\": 345.0,'+
                 '\"Quantity\": 3.0,'+
                 '\"ProductType\": \"Percentage\",'+
                  '\"Subscription\": \"Jobbmobil 40 GB\",'+
                 '\"campaignId\": \"a641l0000004gZwAAI\",'+
                 '\"OneTimePrice\": 345.0,'+
                 '\"OneTimeManualDiscount\": 3.0,'+
                 '\"ApprovedPrice\": 79.0,'+
                '\"Name\": \"'+prod2.Name+'\"'+
                '},'+
                 '{'+
                '\"TargetPercentage\": 0.0,'+
                 '\"RecurringPrice\": 345.0,'+
                  '\"ApprovedPercentage\": 0.0,'+
                 '\"RecurringManualDiscount\": 345.0,'+
                 '\"Quantity\": 3.0,'+
                 '\"ProductType\": \"Percentage\",'+
                  '\"Subscription\": \"Jobbmobil 40 GB\",'+
                 '\"campaignId\": \"a641l0000004gZwAAI\",'+
                 '\"OneTimePrice\": 345.0,'+
                 '\"OneTimeManualDiscount\": 3.0,'+
                 '\"ApprovedPrice\": 79.0,'+
                '\"Name\": \"'+prod2.Name+'\"'+
                '},'+
                  '{'+
                '\"TargetPercentage\": 0.0,'+
                 '\"RecurringPrice\": 345.0,'+
                  '\"ApprovedPercentage\": 0.0,'+
                 '\"RecurringManualDiscount\": 345.0,'+
                 '\"Quantity\": 3.0,'+
                 '\"ProductType\": \"Price\",'+
                  '\"Subscription\": \"Jobbmobil 40 GB\",'+
                 '\"campaignId\": \"a641l0000004gZwAAI\",'+
                 '\"OneTimePrice\": 345.0,'+
                 '\"OneTimeManualDiscount\": 3.0,'+
                '\"Name\": \"'+prod2.Name+'\"'+
                '},'+
                 '{'+
                '\"TargetPercentage\": 0.0,'+
                 '\"RecurringPrice\": 345.0,'+
                  '\"ApprovedPercentage\": 0.0,'+
                 '\"RecurringManualDiscount\": 345.0,'+
                 '\"Quantity\": 3.0,'+
                 '\"ProductType\": \"Price\",'+
                  '\"Subscription\": \"Jobbmobil 40 GB\",'+
                 '\"campaignId\": \"a641l0000004gZwAAI\",'+
                 '\"OneTimePrice\": 345.0,'+
                 '\"OneTimeManualDiscount\": 3.0,'+
                '\"Name\": \"'+prod4.Name+'\"'+
                '}'+
                '],'+
                '\"HQLI\": ['+
                '{'+
                '\"Name\": \"Mobiltelefoner\",'+
                 '\"Name\": \"Månadsavgift\",'+
                '\"BindingTime\": \"24 Månader\"'+
                '}'+
                ']'+
                '}';
            String jsonInput = '{\n' +
                ' "description" :"An appliance",\n' +
                ' "accessories" : [ "powerCord", ' + 
                '{ "right":"door handle1", ' + 
                '"left":"door handle2" } ],\n' +
                ' "dimensions" : ' + 
                '{ "height" : 5.5 , ' + 
                '"width" : 3.0 , ' + 
                '"depth" : 2.2 },\n' +
                ' "type" : null,\n' +
                ' "inventory" : 2000,\n' +
                ' "price" : 1023.45,\n' +
                ' "isShipped" : true,\n' +
                ' "modelNumber" : "123"\n' +
                '}';
            
            Map<String, Object> m = (Map<String, Object>) System.JSON.deserializeUntyped(jsonInput);            
            Map<String, Object> inputMap = (Map<String, Object>)System.JSON.deserializeUntyped(Json);
            Map<String, Object> outMap = new Map<String, Object>();   
            Map<String,Object> options=new Map<String,Object>();
            
            Map<String, Object> offMap = new Map<String, Object>(); //( Map<String, Object>)inputMap.get('SV_SetOfferQuoteId');
            offMap.put('OfferQuoteId',offerQt.Id);
            inputMap.put('SV_SetOfferQuoteId', offMap);
            inputMap.put('ContextId',qut.Id);
            inputMap.put('OfferQuoteId',offerQt.Id);
            
            Test.startTest();

            TeliaSE_SingleCart_OfferCreation obj=new TeliaSE_SingleCart_OfferCreation();        
            obj.invokeMethod('createSingleCartOffer',inputMap,outMap,options);
            obj.invokeMethod('createSecondLevelProduct',inputMap,outMap,options);
            obj.invokeMethod('createThirdLevelProduct',inputMap,outMap,options);
            obj.invokeMethod('createFourthLevelProduct',inputMap,outMap,options);
            obj.invokeMethod('createFifthLevelProduct',inputMap,outMap,options);

            //toffer.invokeMethod('',inputMap,outMap,options);
            Test.stopTest();
        }
    }
    
    
    @isTest()
    static void createTestData1(){
        User salesManager;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
                
        vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
        objClass.Name = 'Mobile Offer Specification';    
        objClass.vlocity_cmt__IsActive__c = True;
        objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass;

        vlocity_cmt__ObjectClass__c objClass1 = new vlocity_cmt__ObjectClass__c();
        objClass1.Name = 'Personal Technician Offer Specification';    
        objClass1.vlocity_cmt__IsActive__c = True;
        objClass1.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass1;        

        vlocity_cmt__ObjectClass__c objClass2 = new vlocity_cmt__ObjectClass__c();
        objClass2.Name = 'Hardware Offer Spec';    
        objClass2.vlocity_cmt__IsActive__c = True;
        objClass2.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass2;        

        vlocity_cmt__ObjectClass__c objClass3 = new vlocity_cmt__ObjectClass__c();
        objClass3.Name = 'Mobile Offer Specification';    
        objClass3.vlocity_cmt__IsActive__c = True;
        objClass3.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass3;         
        
        
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod.Name = 'Jobbmobil 15 GB';
        prod.TeliaSE_Subscription_Type__c = '99';
        insert prod;
        
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod1.Name = 'Jobbmobil 40 GB';
        prod1.TeliaSE_Subscription_Type__c = '98';
        insert prod1;
        
        Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        prod2.vlocity_cmt__ObjectTypeId__c = objClass1.Id;
        prod2.Name = 'Test';
        insert prod2;
        
        Product2 prod3 = Test_DataFactory.createProducts(1)[0];
        prod3.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        insert prod3;
        
        Product2 prod4 = Test_DataFactory.createProducts(1)[0];
        prod4.vlocity_cmt__ObjectTypeId__c = objClass1.Id;
        prod4.Name = 'Jobbsurf 50 GB';
        prod4.ProductCode = 'MOB_SURF_50';
        insert prod4;

        Product2 prod5 = Test_DataFactory.createProducts(1)[0];
        prod5.vlocity_cmt__ObjectTypeId__c = objClass2.Id;
        prod5.Name = 'Mobiltelefoner';
        prod5.ProductCode = 'MOB_HARDWARE_OFFER';
        insert prod5;

        Product2 prod6 = Test_DataFactory.createProducts(1)[0];
        prod6.vlocity_cmt__ObjectTypeId__c = objClass3.Id;
        prod6.Name = 'Jobbsurf 50 GB';
        prod6.ProductCode = 'MOB_SURF_50';
        insert prod6;
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
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
                       
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';  
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;        
            insert qut;
            
            Quote offerQt = new Quote();
            offerQt.Name='Test Quote_offer';
            offerQt.status = 'Draft';  
            offerQt.opportunityId = opp.id;
            offerQt.Pricebook2ID = stdPriceBookRecId;
            offerQt.TeliaSE_Approval_Flag__c = False;        
            insert offerQt;

            QuoteLineItem offQli1 = new QuoteLineItem();
            offQli1.QuoteId = offerQt.Id;
            offQli1.Subscription__c = prod1.Name;
            offQli1.Product2Id = prod2.Id;
            offQli1.PricebookEntryId = objpricebookentry.Id;
            offQli1.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id);
            offQli1.UnitPrice = 0;
            offQli1.TeliaSE_MC_FACallOffQuantity__c = 3;
            //oli1.TeliaSE_Product_Object_Type__c = 'Personal Technician Offer Specification';
            offQli1.Quantity = 1;
            insert offQli1;

            QuoteLineItem offQli2 = new QuoteLineItem();
            offQli2.QuoteId = offerQt.Id;
            //oli2.Subscription__c = prod2.Name;
            offQli2.Product2Id = prod2.Id;
            offQli2.PricebookEntryId = objpricebookentry.Id;
            offQli2.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id);
            offQli2.UnitPrice = 0;
            //offQli2.vlocity_cmt__ParentItemId__c = offQli1.Id;
            offQli2.TeliaSE_MC_FACallOffQuantity__c = 3;
            offQli2.Quantity = 1;
            insert offQli2;


            QuoteLineItem offQli3 = new QuoteLineItem();
            offQli3.QuoteId = offerQt.Id;
            //oli2.Subscription__c = prod2.Name;
            offQli3.Product2Id = prod3.Id;
            offQli3.PricebookEntryId = objpricebookentry.Id;
            offQli3.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id);
            offQli3.UnitPrice = 0;
            offQli3.vlocity_cmt__ParentItemId__c = offQli2.Id;
            offQli3.TeliaSE_MC_FACallOffQuantity__c = 3;
            offQli3.Quantity = 1;
            insert offQli3;

            QuoteLineItem offQli4 = new QuoteLineItem();
            offQli4.QuoteId = offerQt.Id;
            //oli2.Subscription__c = prod2.Name;
            offQli4.Product2Id = prod6.Id;
            offQli4.PricebookEntryId = objpricebookentry.Id;
            offQli4.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id)+'<'+String.valueOf(prod6.Id);
            offQli4.UnitPrice = 0;
            offQli4.vlocity_cmt__ParentItemId__c = offQli3.Id;
            offQli4.TeliaSE_MC_FACallOffQuantity__c = 3;
            offQli4.Quantity = 1;
            insert offQli4;

            QuoteLineItem offQli5 = new QuoteLineItem();
            offQli5.QuoteId = offerQt.Id;
            //oli2.Subscription__c = prod2.Name;
            offQli5.Product2Id = prod5.Id;
            offQli5.PricebookEntryId = objpricebookentry.Id;
            offQli5.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id)+'<'+String.valueOf(prod4.Id)+'<'+String.valueOf(prod5.Id);
            offQli5.UnitPrice = 0;
            offQli5.vlocity_cmt__ParentItemId__c = offQli4.Id;
            offQli5.TeliaSE_MC_FACallOffQuantity__c = 3;
            offQli5.Quantity = 1;
            insert offQli5;
            
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.QuoteId = qut.Id;
            oli1.Subscription__c = prod1.Name;
            oli1.Product2Id = prod2.Id;
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id);
            oli1.UnitPrice = 0;
            oli1.TeliaSE_MC_FACallOffQuantity__c = 3;
            //oli1.TeliaSE_Product_Object_Type__c = 'Personal Technician Offer Specification';
            oli1.Quantity = 1;
            insert oli1;

            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.QuoteId = qut.Id;
            //oli2.Subscription__c = prod2.Name;
            oli2.Product2Id = prod2.Id;
            oli2.PricebookEntryId = objpricebookentry.Id;
            oli2.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id);
            oli2.UnitPrice = 0;
            oli2.vlocity_cmt__ParentItemId__c = oli1.Id;
            oli2.TeliaSE_MC_FACallOffQuantity__c = 3;
            oli2.Quantity = 1;
            insert oli2;


            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.QuoteId = qut.Id;
            //oli2.Subscription__c = prod2.Name;
            oli3.Product2Id = prod3.Id;
            oli3.PricebookEntryId = objpricebookentry.Id;
            oli3.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id);
            oli3.UnitPrice = 0;
            oli3.vlocity_cmt__ParentItemId__c = oli2.Id;
            oli3.TeliaSE_MC_FACallOffQuantity__c = 3;
            oli3.Quantity = 1;
            insert oli3;

            QuoteLineItem oli4 = new QuoteLineItem();
            oli4.QuoteId = qut.Id;
            //oli2.Subscription__c = prod2.Name;
            oli4.Product2Id = prod4.Id;
            oli4.PricebookEntryId = objpricebookentry.Id;
            oli4.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id)+'<'+String.valueOf(prod4.Id);
            oli4.UnitPrice = 0;
            oli4.vlocity_cmt__ParentItemId__c = oli3.Id;
            oli4.TeliaSE_MC_FACallOffQuantity__c = 3;
            oli4.Quantity = 1;
            insert oli4;

            QuoteLineItem oli5 = new QuoteLineItem();
            oli5.QuoteId = qut.Id;
            //oli2.Subscription__c = prod2.Name;
            oli5.Product2Id = prod4.Id;
            oli5.PricebookEntryId = objpricebookentry.Id;
            oli5.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id)+'<'+String.valueOf(prod4.Id)+'<'+String.valueOf(prod5.Id);
            oli5.UnitPrice = 0;
            oli5.vlocity_cmt__ParentItemId__c = oli4.Id;
            oli5.TeliaSE_MC_FACallOffQuantity__c = 3;
            oli5.Quantity = 1;
            insert oli5;

        String json = '{'+
        '  \"ContextId\": \"'+qut.Id+'\",'+
        '  \"OfferCartId\": \"'+offerQt.Id+'\",'+
        '  \"secondLevelProdList\": ['+
        '    {'+
        '      \"prodIdToBeAdded\": \"'+prod2.Id+'\",'+
        '      \"priceBookEntryIdToBeAdded\": \"'+objpricebookentry.Id+'\",'+
        '      \"01t1w000003WsyfAACCallOffQty\": \"3\",'+
        '      \"productHierarchyPath\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'",'+
        '      \"productName\": \"Apple iPhone 8 64GB Rymdgrå\",'+
        '      \"01u1w000008Tl80AAC\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'",'+
        '      \"Quantity\": \"3\"'+
        '    },'+
        '    {'+
        '      \"prodIdToBeAdded\": \"'+prod3.Id+'\",'+
        '      \"priceBookEntryIdToBeAdded\": \"'+objpricebookentry.Id+'\",'+
        '      \"01t1p0000081yKPAAYCallOffQty\": null,'+
        '      \"productHierarchyPath\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'",'+
        '      \"productName\": \"Supportärende, Tekniker På Plats Plus (1 ärende)\",'+
        '      \"01u1p00000RX1JXAA1\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'"'+
        '    }'+
        '  ],'+
        '  \"secondLevelProdSet\": ['+
        '    \"01u1w000008Tl80AAC\",'+
        '    \"01u1p00000RX1JXAA1\"'+
        '  ],'+
        '  \"secondLevelProducts\": ['+
        '    {'+
        '      \"validate\": false,'+
        '      \"price\": false,'+
        '      \"methodName\": \"postCartsItems\",'+
        '      \"items\": ['+
        '        {'+
        '          \"parentRecord\": {'+
        '            \"records\": ['+
        '              {'+
        '                \"productHierarchyPath\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'",'+
        '                \"parentHierarchyPath\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'\"'+
        '              }'+
        '            ]'+
        '          },'+
        '          \"parentId\": \"'+oli1.Id+'\",'+
        '          \"itemId\": \"'+objpricebookentry.Id+'\"'+
        '        }'+
        '      ],'+
        '      \"inputFields\": null,'+
        '      \"cartId\": \"'+offerQt.Id+'\"'+
        '    },'+
        '    {'+
        '      \"validate\": false,'+
        '      \"price\": false,'+
        '      \"methodName\": \"postCartsItems\",'+
        '      \"items\": ['+
        '        {'+
        '          \"parentRecord\": {'+
        '            \"records\": ['+
        '              {'+
        '                \"productHierarchyPath\": \"01t1p0000081yNIAAY\",'+
        '                \"parentHierarchyPath\": \"01t1p0000081yNIAAY\"'+
        '              }'+
        '            ]'+
        '          },'+
        '          \"parentId\": \"0QL4E000000NEYAWA4\",'+
        '          \"itemId\": \"01u1p00000RX1JXAA1\"'+
        '        }'+
        '      ],'+
        '      \"inputFields\": null,'+
        '      \"cartId\": \"0Q04E000000aZw4SAE\"'+
        '    }'+
        '  ],'+
        '  \"error\": \"OK\",'+
        '  \"thirdLevelProdSet\": [],'+
        '  \"thirdLevelProdList\": [],'+
        '  \"thirdLevelProducts\": [],'+
        '  \"fourthLevelProdList\": ['+
        '    {'+
        '      \"prodIdToBeAdded\": \"'+prod4.Id+'\",'+
        '      \"priceBookEntryIdToBeAdded\": \"'+objpricebookentry.Id+'\",'+
        '      \"01t1p0000081yJvAAICallOffQty\": \"8\",'+
        '      \"productHierarchyPath\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id)+'<'+String.valueOf(prod4.Id)+'\",'+
        '      \"productName\": \"Tillkommande Supportärende på plats (per ärende)\",'+
        '      \"01u1p00000RX1JIAA1\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id)+'<'+String.valueOf(prod4.Id)+'\",'+
        '      \"Quantity\": \"8\"'+
        '    }'+
        '  ],'+
        '  \"fourthLevelProdSet\": ['+
        '    \"'+prod4.Id+'\"'+
        '  ],'+
        '  \"fourthLevelProducts\": ['+
        '    {'+
        '      \"validate\": false,'+
        '      \"price\": false,'+
        '      \"methodName\": \"postCartsItems\",'+
        '      \"items\": ['+
        '        {'+
        '          \"parentRecord\": {'+
        '            \"records\": ['+
        '              {'+
        '                \"productHierarchyPath\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id)+'<'+String.valueOf(prod4.Id)+'\",'+
        '                \"parentHierarchyPath\": \"'+String.valueOf(prod1.Id)+'<'+String.valueOf(prod2.Id)+'<'+String.valueOf(prod3.Id)+'<'+String.valueOf(prod4.Id)+'\"'+
        '              }'+
        '            ]'+
        '          },'+
        '          \"parentId\": \"'+offQli3.Id+'\",'+
        '          \"itemId\": \"'+prod4.Id+'\"'+
        '        }'+
        '      ],'+
        '      \"inputFields\": null,'+
        '      \"cartId\": \"'+offerQt.Id+'\"'+
        '    }'+
        '  ],'+
        '  \"fifthLevelProdSet\": [],'+
        '  \"fifthLevelProdList\": [],'+
        '  \"fifthLevelProducts\": []'+
        '}';
            
            String JsonResponse = '{'+
                '\"OfferQuoteId\": \"'+qut.Id+'\",'+
                '\"FAQLI\": ['+
                '{'+
                '\"TargetPercentage\": 4.0,'+
                 '\"RecurringPrice\": 345.0,'+
                  '\"ApprovedPercentage\": 0.0,'+
                  '\"RequestedPercentage\": 0.0,'+
                 '\"RecurringManualDiscount\": 345.0,'+
                 '\"Quantity\": 3.0,'+
                 '\"ProductType\": \"Price\",'+
                  '\"Subscription\": \"Jobbmobil 40 GB\",'+
                 '\"campaignId\": \"a641l0000004gZwAAI\",'+
                 '\"OneTimePrice\": 345.0,'+
                 '\"OneTimeManualDiscount\": 3.0,'+
                 '\"ApprovedPrice\": 79.0,'+
                '\"Name\": \"'+prod2.Name+'\"'+
                '},'+
                '{'+
                '\"TargetPercentage\": 4.0,'+
                 '\"RecurringPrice\": 345.0,'+
                  '\"ApprovedPercentage\": 0.0,'+
                  '\"RequestedPercentage\": 2.0,'+
                 '\"RecurringManualDiscount\": 345.0,'+
                 '\"Quantity\": 3.0,'+
                 '\"ProductType\": \"Percentage\",'+
                  '\"Subscription\": \"Jobbmobil 40 GB\",'+
                 '\"campaignId\": \"a641l0000004gZwAAI\",'+
                 '\"OneTimePrice\": 345.0,'+
                 '\"OneTimeManualDiscount\": 3.0,'+
                 '\"ApprovedPrice\": 79.0,'+
                '\"Name\": \"'+prod2.Name+'\"'+
                '},'+
                 '{'+
                '\"TargetPercentage\": 0.0,'+
                 '\"RecurringPrice\": 345.0,'+
                  '\"ApprovedPercentage\": 0.0,'+
                 '\"RecurringManualDiscount\": 345.0,'+
                 '\"Quantity\": 3.0,'+
                 '\"ProductType\": \"Percentage\",'+
                  '\"Subscription\": \"Jobbmobil 40 GB\",'+
                 '\"campaignId\": \"a641l0000004gZwAAI\",'+
                 '\"OneTimePrice\": 345.0,'+
                 '\"OneTimeManualDiscount\": 3.0,'+
                 '\"ApprovedPrice\": 79.0,'+
                '\"Name\": \"'+prod2.Name+'\"'+
                '},'+
                  '{'+
                '\"TargetPercentage\": 0.0,'+
                 '\"RecurringPrice\": 345.0,'+
                  '\"ApprovedPercentage\": 0.0,'+
                 '\"RecurringManualDiscount\": 345.0,'+
                 '\"Quantity\": 3.0,'+
                 '\"ProductType\": \"Price\",'+
                  '\"Subscription\": \"Jobbmobil 40 GB\",'+
                 '\"campaignId\": \"a641l0000004gZwAAI\",'+
                 '\"OneTimePrice\": 345.0,'+
                 '\"OneTimeManualDiscount\": 3.0,'+
                '\"Name\": \"'+prod2.Name+'\"'+
                '},'+
                 '{'+
                '\"TargetPercentage\": 0.0,'+
                 '\"RecurringPrice\": 345.0,'+
                  '\"ApprovedPercentage\": 0.0,'+
                 '\"RecurringManualDiscount\": 345.0,'+
                 '\"Quantity\": 3.0,'+
                 '\"ProductType\": \"Price\",'+
                  '\"Subscription\": \"Jobbmobil 40 GB\",'+
                 '\"campaignId\": \"a641l0000004gZwAAI\",'+
                 '\"OneTimePrice\": 345.0,'+
                 '\"OneTimeManualDiscount\": 3.0,'+
                '\"Name\": \"'+prod4.Name+'\"'+
                '}'+
                '],'+
                '\"HQLI\": ['+
                '{'+
                '\"Name\": \"Mobiltelefoner\",'+
                 '\"Name\": \"Månadsavgift\",'+
                '\"BindingTime\": \"24 Månader\"'+
                '}'+
                ']'+
                '}';
            String jsonInput = '{\n' +
                ' "description" :"An appliance",\n' +
                ' "accessories" : [ "powerCord", ' + 
                '{ "right":"door handle1", ' + 
                '"left":"door handle2" } ],\n' +
                ' "dimensions" : ' + 
                '{ "height" : 5.5 , ' + 
                '"width" : 3.0 , ' + 
                '"depth" : 2.2 },\n' +
                ' "type" : null,\n' +
                ' "inventory" : 2000,\n' +
                ' "price" : 1023.45,\n' +
                ' "isShipped" : true,\n' +
                ' "modelNumber" : "123"\n' +
                '}';
            
            Map<String, Object> m = (Map<String, Object>) System.JSON.deserializeUntyped(jsonInput);            
            Map<String, Object> inputMap = (Map<String, Object>)System.JSON.deserializeUntyped(Json);
            Map<String, Object> outMap = new Map<String, Object>();   
            Map<String,Object> options=new Map<String,Object>();
            
            Map<String, Object> offMap = new Map<String, Object>(); //( Map<String, Object>)inputMap.get('SV_SetOfferQuoteId');
            offMap.put('OfferQuoteId',offerQt.Id);
            inputMap.put('SV_SetOfferQuoteId', offMap);
            inputMap.put('ContextId',qut.Id);
            inputMap.put('OfferQuoteId',offerQt.Id);
            
            Test.startTest();

            TeliaSE_SingleCart_OfferCreation obj=new TeliaSE_SingleCart_OfferCreation();        
            obj.invokeMethod('createSingleCartOffer',inputMap,outMap,options);
            obj.invokeMethod('createSecondLevelProduct',inputMap,outMap,options);
            obj.invokeMethod('createThirdLevelProduct',inputMap,outMap,options);
            obj.invokeMethod('createFourthLevelProduct',inputMap,outMap,options);
            obj.invokeMethod('createFifthLevelProduct',inputMap,outMap,options);

            //toffer.invokeMethod('',inputMap,outMap,options);
            Test.stopTest();
        }
    }
}