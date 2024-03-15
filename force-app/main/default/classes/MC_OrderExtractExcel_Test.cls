@isTest
private class MC_OrderExtractExcel_Test {
 @testSetup static void testDataSetup(){
        User salesManager;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
        objClass.Name = 'Broadband Pro Offering Spec';    
        objClass.vlocity_cmt__IsActive__c = True;
        objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass;
        
        vlocity_cmt__ObjectClass__c objClass2 = new vlocity_cmt__ObjectClass__c();
        objClass2.Name = 'Connected Office Offer Spec';    
        objClass2.vlocity_cmt__IsActive__c = True;
        objClass2.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass2;
        
        vlocity_cmt__ObjectClass__c objClass3 = new vlocity_cmt__ObjectClass__c();
        objClass3.Name = 'Broadband Datanet Offering Spec';    
        objClass3.vlocity_cmt__IsActive__c = True;
        objClass3.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass3;
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod.Name = 'Bredband Pro 100 mb';
        prodList.add(prod);
        
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod1.Name = 'Bredband Pro 1000 mb';
        prod1.ProductCode = 'B-SLA-C4';
        prodList.add(prod1);
        
        Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        prod2.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod2.Name = 'Bredband Pro SLA C4   ';
        prod2.ProductCode = 'CO-BBPRO-SLA-C4';
        prodList.add(prod2);
        
        Product2 prod3 = Test_DataFactory.createProducts(1)[0];
        prod3.vlocity_cmt__ObjectTypeId__c = objClass2.Id;
        prod3.Name = 'HERA XYZ';
        prod3.ProductCode = 'HERA';
        prodList.add(prod3);
        
        Product2 prod4 = Test_DataFactory.createProducts(1)[0];
        prod4.vlocity_cmt__ObjectTypeId__c = objClass3.Id;
        prod4.Name = 'Access Multi 100 mbits';
        prod4.ProductCode = 'A-SLA-C4';
        prodList.add(prod4);
        
        Product2 prod5 = Test_DataFactory.createProducts(1)[0];
        prod5.vlocity_cmt__ObjectTypeId__c = objClass3.Id;
        prod5.Name = 'Tilval non subscription offering';
        prod5.ProductCode = 'TILVAL';
        prod5.TeliaSE_Offer_Type__c = 'Non-SubscriptionOffering';
        prodList.add(prod5);
        
        Product2 prod6 = Test_DataFactory.createProducts(1)[0];
        prod6.vlocity_cmt__ObjectTypeId__c = objClass3.Id;
        prod6.Name = 'Access Multi Sekunder Access child';
        prod6.ProductCode = 'MULTI-SEKUNDER-ACCESS';
        prodList.add(prod6);
        
        insert prodList;
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        Opportunity opp = new Opportunity();
        System.runAs(salesManager){
            
                        
            Account acc=Test_DataFactory.createOneSMEAccount();
            acc.MC_Commercial_Setup__c = 'Forced RA';
            acc.Org_Nr__c  = '5564110665';
            acc.Name = 'R21.4_Test_CO_Acc_Grouping';
            insert acc;
            
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
            
            RecordType recType = [SELECT Id,DeveloperName FROM RecordType WHERE DeveloperName = 'Offer' AND SobjectType = 'Quote'];
            Quote qut2 = new Quote();
            qut2.Name='Offer QuoteA'; //grouping
            qut2.status = 'Draft';  
            qut2.RecordTypeId = recType.Id;
            qut2.opportunityId = opp.id;
            qut2.Pricebook2ID = stdPriceBookRecId;
            qut2.vlocity_cmt__ParentQuoteId__c = qut.Id; 
            qut2.TeliaSE_MC_Sales_Flow_Identifier__c = 'New Sales';
            insert qut2;
            
            Quote qut3 = new Quote();
            qut3.Name='Offer QuoteB';   //non grouping
            qut3.status = 'Cancelled';  
            qut3.RecordTypeId = recType.Id;
            qut3.opportunityId = opp.id;
            qut3.Pricebook2ID = stdPriceBookRecId;
            qut3.vlocity_cmt__ParentQuoteId__c = qut.Id; 
            qut3.TeliaSE_MC_Sales_Flow_Identifier__c = 'New Sales';
            insert qut3;
            
            
            List<vlocity_cmt__Premises__c> premiseList = new List<vlocity_cmt__Premises__c>();
            vlocity_cmt__Premises__c premise = new vlocity_cmt__Premises__c();
            premise.vlocity_cmt__City__c = 'solna';
            premise.vlocity_cmt__StreetAddress__c = 'Överskärargränd';
            premise.vlocity_cmt__PostalCode__c = '12111';
            premise.vlocity_cmt__Address1__c = '12111';
            premise.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            premiseList.add(premise);
            vlocity_cmt__Premises__c premise1 = new vlocity_cmt__Premises__c();
            premise1.vlocity_cmt__City__c = 'stockholm';
            premise1.vlocity_cmt__StreetAddress__c = 'Stjärntorget';
            premise1.vlocity_cmt__PostalCode__c = '12112';
            premise1.vlocity_cmt__Address1__c = '12112';
            premise1.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            premiseList.add(premise1);
            vlocity_cmt__Premises__c premise2 = new vlocity_cmt__Premises__c();
            premise2.vlocity_cmt__City__c = 'solna';
            premise2.vlocity_cmt__StreetAddress__c = 'Diktarvägen';
            premise2.vlocity_cmt__PostalCode__c = '12113';
            premise2.vlocity_cmt__Address1__c = '12113';
            premise2.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            premiseList.add(premise2);
            insert premiseList;
            
            List<vlocity_cmt__ServicePoint__c> spointList = new List<vlocity_cmt__ServicePoint__c>();
            vlocity_cmt__ServicePoint__c spoint = new vlocity_cmt__ServicePoint__c();
            spoint.vlocity_cmt__ServicePointNumber__c = '148573009';
            spoint.vlocity_cmt__PremisesId__c = premise.Id;
            spointList.add(spoint);
            vlocity_cmt__ServicePoint__c spoint1 = new vlocity_cmt__ServicePoint__c();
            spoint1.vlocity_cmt__ServicePointNumber__c = '1212123';
            spoint1.vlocity_cmt__PremisesId__c = premise1.Id;
            spointList.add(spoint1);
            vlocity_cmt__ServicePoint__c spoint2 = new vlocity_cmt__ServicePoint__c();
            spoint2.vlocity_cmt__ServicePointNumber__c = '1212124';
            spoint2.vlocity_cmt__PremisesId__c = premise2.Id;
            spointList.add(spoint2);
            insert spointList;
            
            List<vlocity_cmt__QuoteGroup__c> quoteGroupList = new List<vlocity_cmt__QuoteGroup__c>();
            vlocity_cmt__QuoteGroup__c quoteGroup = new vlocity_cmt__QuoteGroup__c();
            quoteGroup.Name = 'Group 1';
            quoteGroup.vlocity_cmt__Description__c = 'Group 1';
            quoteGroup.vlocity_cmt__QuoteId__c = qut2.id;
            quoteGroupList.add(quoteGroup);
            
            vlocity_cmt__QuoteGroup__c quoteGroup1 = new vlocity_cmt__QuoteGroup__c();
            quoteGroup1.Name = 'Group 2';
            quoteGroup1.vlocity_cmt__Description__c = 'Group 2';
            quoteGroup1.vlocity_cmt__QuoteId__c = qut2.id;
            quoteGroupList.add(quoteGroup1);
            vlocity_cmt__QuoteGroup__c quoteGroup2 = new vlocity_cmt__QuoteGroup__c();
            quoteGroup2.Name = 'Group 3';
            quoteGroup2.vlocity_cmt__Description__c = 'Group 3';
            quoteGroup2.vlocity_cmt__QuoteId__c = qut2.id;
            quoteGroupList.add(quoteGroup2);
            
            vlocity_cmt__QuoteGroup__c quoteGroup4 = new vlocity_cmt__QuoteGroup__c();
            quoteGroup4.Name = 'HERA GROUP';
            quoteGroup4.vlocity_cmt__Description__c = 'NO_GROUP';
            quoteGroup4.vlocity_cmt__QuoteId__c = qut2.id;
            quoteGroupList.add(quoteGroup4);
            insert quoteGroupList;
            
            //Creating quote members
            List<vlocity_cmt__QuoteMember__c> quoteMemList = new List<vlocity_cmt__QuoteMember__c>();
            vlocity_cmt__QuoteMember__c quoteMem = new vlocity_cmt__QuoteMember__c();
            quoteMem.vlocity_cmt__ServicePointId__c = spoint.Id;
            quoteMem.vlocity_cmt__QuoteGroupId__c = quoteGroup.Id;
            quoteMem.vlocity_cmt__QuoteId__c = qut2.id;
            quoteMemList.add(quoteMem);
            
            vlocity_cmt__QuoteMember__c quoteMem1 = new vlocity_cmt__QuoteMember__c();
            quoteMem1.vlocity_cmt__ServicePointId__c = spoint1.Id;
            quoteMem1.vlocity_cmt__QuoteGroupId__c = quoteGroup1.Id;
            quoteMem1.vlocity_cmt__QuoteId__c = qut2.id;
            quoteMemList.add(quoteMem1);
            
            vlocity_cmt__QuoteMember__c quoteMem2 = new vlocity_cmt__QuoteMember__c();
            quoteMem2.vlocity_cmt__ServicePointId__c = spoint2.Id;
            quoteMem2.vlocity_cmt__QuoteGroupId__c = quoteGroup2.Id;
            quoteMem2.vlocity_cmt__QuoteId__c = qut2.id;
            quoteMemList.add(quoteMem2);
            
            vlocity_cmt__QuoteMember__c quoteMem4 = new vlocity_cmt__QuoteMember__c();
            quoteMem4.vlocity_cmt__ServicePointId__c = spoint1.Id;
            quoteMem4.vlocity_cmt__QuoteGroupId__c = quoteGroup4.Id;
            quoteMem4.vlocity_cmt__QuoteId__c = qut2.id;
            quoteMemList.add(quoteMem4);
            insert quoteMemList;
            
            List<TeliaSE_SimplifiedQuoteLineItem__c> sliList = new List<TeliaSE_SimplifiedQuoteLineItem__c>();
            TeliaSE_SimplifiedQuoteLineItem__c sli1a = new TeliaSE_SimplifiedQuoteLineItem__c();
            sli1a.Product__c=prod.id;
            sli1a.QuoteId__c=qut.id;            
            sli1a.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sli1a.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sli1a.TeliaSE_MC_Binding_Time__c= '12';
            sli1a.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sli1a.TeliaSE_Aggregated_Quantity__c=5;
            sli1a.TeliaSE_Root_Product__c=null;
            sli1a.MC_TeliaExcludeQuoteItem__c=false;  
            sli1a.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sli1a);
            
            TeliaSE_SimplifiedQuoteLineItem__c sli2a = new TeliaSE_SimplifiedQuoteLineItem__c();
            sli2a.Product__c=prod1.id;
            sli2a.QuoteId__c=qut.id;
            sli2a.Quote_Member__c=quoteMem4.id;
            sli2a.Quote_Group__c=quoteGroup4.id;            
            sli2a.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sli2a.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sli2a.TeliaSE_MC_Binding_Time__c= '12';
            sli2a.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sli2a.TeliaSE_Aggregated_Quantity__c=1;
            sli2a.TeliaSE_Root_Product__c=null;
            sli2a.MC_TeliaExcludeQuoteItem__c=true;  
            sli2a.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sli2a);
            
            TeliaSE_SimplifiedQuoteLineItem__c sli3a = new TeliaSE_SimplifiedQuoteLineItem__c();
            sli3a.Product__c=prod2.id;
            sli3a.QuoteId__c=qut.id;
            sli3a.Quote_Member__c=null;
            sli3a.Quote_Group__c=null;            
            sli3a.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sli3a.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sli3a.TeliaSE_MC_Binding_Time__c= '12';
            sli3a.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sli3a.TeliaSE_Aggregated_Quantity__c=1;
            sli3a.TeliaSE_Root_Product__c=null;
            sli3a.MC_TeliaExcludeQuoteItem__c=true;  
            sli3a.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sli3a);
            
            TeliaSE_SimplifiedQuoteLineItem__c sli4a = new TeliaSE_SimplifiedQuoteLineItem__c();
            sli4a.Product__c=prod3.id;
            sli4a.QuoteId__c=qut2.id;
            sli4a.Quote_Member__c=quoteMem4.id;
            sli4a.Quote_Group__c=quoteGroup4.id;            
            sli4a.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sli4a.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sli4a.TeliaSE_MC_Binding_Time__c= '12';
            sli4a.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sli4a.TeliaSE_Aggregated_Quantity__c=1;
            sli4a.TeliaSE_Root_Product__c=null;
            sli4a.MC_TeliaExcludeQuoteItem__c=false;  
            sli4a.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sli4a);
            
            TeliaSE_SimplifiedQuoteLineItem__c sli5a = new TeliaSE_SimplifiedQuoteLineItem__c();
            sli5a.Product__c=prod4.id;
            sli5a.QuoteId__c=qut2.id;          
            sli5a.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sli5a.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sli5a.TeliaSE_MC_Binding_Time__c= '12';
            sli5a.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sli5a.TeliaSE_Aggregated_Quantity__c=1;
            sli5a.TeliaSE_Root_Product__c=null;
            sli5a.MC_TeliaExcludeQuoteItem__c=false;  
            sli5a.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sli5a);
            
            TeliaSE_SimplifiedQuoteLineItem__c sli6a = new TeliaSE_SimplifiedQuoteLineItem__c();
            sli6a.Product__c=prod5.id;
            sli6a.QuoteId__c=qut2.id;            
            sli6a.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sli6a.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sli6a.TeliaSE_MC_Binding_Time__c= '12';
            sli6a.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sli6a.TeliaSE_Aggregated_Quantity__c=1;
            sli6a.TeliaSE_Root_Product__c=null;
            sli6a.MC_TeliaExcludeQuoteItem__c=false;  
            sli6a.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sli6a);
            
            TeliaSE_SimplifiedQuoteLineItem__c sli7a = new TeliaSE_SimplifiedQuoteLineItem__c();
            sli7a.Product__c=prod6.id;
            sli7a.QuoteId__c=qut2.id;            
            sli7a.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sli7a.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sli7a.TeliaSE_MC_Binding_Time__c= '12';
            sli7a.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sli7a.TeliaSE_Aggregated_Quantity__c=1;
            sli7a.TeliaSE_Root_Product__c=null;
            sli7a.MC_TeliaExcludeQuoteItem__c=false;  
            sli7a.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sli7a);
            
            TeliaSE_SimplifiedQuoteLineItem__c sli8a = new TeliaSE_SimplifiedQuoteLineItem__c();
            sli8a.Product__c=prod6.id;
            sli8a.QuoteId__c=qut2.id;          
            sli8a.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sli8a.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sli8a.TeliaSE_MC_Binding_Time__c= '12';
            sli8a.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sli8a.TeliaSE_Aggregated_Quantity__c=1;
            sli8a.TeliaSE_Root_Product__c=null;
            sli8a.MC_TeliaExcludeQuoteItem__c=false;  
            sli8a.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sli8a);
            
            Insert sliList;
            
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.vlocity_cmt__OpportunityId__c = opp.id;
            contract.Status='Draft';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;
            contract.vlocity_cmt__QuoteId__c = qut.id;
            insert contract;
            
            vlocity_cmt__ContractLineItem__c cli = new vlocity_cmt__ContractLineItem__c();
            cli.vlocity_cmt__ContractId__c = contract.id;
            cli.vlocity_cmt__Product2Id__c = prod.Id;
            cli.Name ='Telia Bredband Pro';
            cli.TeliaSE_Product_Object_Type__c = objClass.Name;
            cli.TeliaSE_Base_Quantity__c =5;
            cli.TeliaSE_ParentClusterCode__c = 'small';
            cli.vlocity_cmt__RecurringCharge__c = 35;
            insert cli;
        }
    }
    
    @isTest
    static void testValidation(){
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        Contract con = [SELECT id FROM Contract LIMIT 1];
        inputMap.put('contextId',con.Id);
        Test.startTest();
        MC_OrderExtractExcel orderExtract = new MC_OrderExtractExcel();
        orderExtract.invokeMethod('checkOfferQuote', inputMap, outMap, options);
        Test.stopTest();
        System.assertNotEquals(null,outMap.get('Warning'));
    }
    
    @isTest
    static void testExcelGrouping(){
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        Contract con = [SELECT id FROM Contract LIMIT 1];
        inputMap.put('ContractId',con.Id);
        Test.startTest();
        MC_OrderExtractExcel orderExtract = new MC_OrderExtractExcel();
        orderExtract.invokeMethod('generateExcel', inputMap, outMap, options);
        Test.stopTest();
        System.assertNotEquals(null,outMap.get('downloadLink'));
    }
    
    @isTest
    static void testExcelNonGrouping(){
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        List<Quote> quotes = [SELECT Id,name from Quote Order BY Name];
        quotes[0].Status = 'Cancelled';
        quotes[1].Status = 'Draft';
        update quotes;
        
        Contract con = [SELECT id FROM Contract LIMIT 1];
        inputMap.put('ContractId',con.Id);
        Test.startTest();
        MC_OrderExtractExcel orderExtract = new MC_OrderExtractExcel();
        orderExtract.invokeMethod('generateExcel', inputMap, outMap, options);
        Test.stopTest();
        System.assertNotEquals(null,outMap.get('downloadLink'));
    }
        
    @isTest
    static void testIncorrectMethodName(){
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        Test.startTest();
        MC_OrderExtractExcel orderExtractValidate = new MC_OrderExtractExcel();
        Boolean result = orderExtractValidate.invokeMethod('test', inputMap, outMap, options);
        Test.stopTest();
        System.assertEquals(false,result);
    }
}