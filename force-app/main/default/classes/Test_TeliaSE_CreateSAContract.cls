@isTest
public with sharing class Test_TeliaSE_CreateSAContract {
    
    @testSetup static void setup(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            //salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager = Test_DataFactory.createAdminUser();
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            
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
            
            Contact c = Test_DataFactory.createOneContact();
            c.AccountId = acc.Id;
            insert c;
            
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            OpportunityContactRole ocr = new OpportunityContactRole();
            ocr.OpportunityId=opp.Id;
            ocr.IsPrimary=true;
            ocr.ContactId = c.Id;
            insert ocr;
            
            //ocr.Role= 'Avtaskteck'
            
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
            
            RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;
            contract.RecordTypeId = rt1.Id;
            insert contract;
            contract.Status='Active';
            update contract;
            
            Utilizer_Contract_Relationship__c uc = new Utilizer_Contract_Relationship__c();
            //uc.Name = ;
            uc.AccountId__c = acc.Id;
            uc.ContractNumber__c = contract.Id;
            uc.Status__c = 'Manual';
            uc.Org_Number__c = '5876698089';
            //uc.Status__c ='Manual';
            //uc.Utilizer_Contract_Name__c = 'abc';
            insert uc;
            
            
            
            Account acc1=Test_DataFactory.createOneSMEAccount();
            acc1.FA_Contract__c=contract.id;
            insert acc1;
            
            String masterQuote=System.Label.TeliaSE_Master_quote;
            
            Quote qut1 = new Quote();
            qut1.Name='Master Quote';
            qut1.status = 'Draft';
            qut1.opportunityId = opp.id;
            qut1.Pricebook2ID = stdPriceBookRecId;
            qut1.TeliaSE_Approval_Flag__c = False; 
            qut1.TeliaSE_RenegotiatedAgreement__c=contract.id;
            qut1.TeliaSE_Type__c='Renegotiation';
            qut1.TeliaSE_MC_Sales_Flow_Identifier__c='New Sales';
            
            insert qut1; 
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';
            qut.TeliaSE_RenegotiatedAgreement__c=contract.id;
            qut.TeliaSE_Type__c='Renegotiation';
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;        
            qut.TeliaSE_RevisedAgreement__c=contract.id;
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
            
            
            oli3.vlocity_cmt__AssetReferenceId__c = 'abc-abc';
            oli3.vlocity_cmt__RootItemId__c = oli3.vlocity_cmt__AssetReferenceId__c;
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
            
            oli1.vlocity_cmt__AssetReferenceId__c = 'abc-bcd';
            oli1.vlocity_cmt__RootItemId__c = oli1.vlocity_cmt__AssetReferenceId__c;
            update oli1;
            
            
            
            
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
            
            oli4.vlocity_cmt__AssetReferenceId__c = 'abc-cde';
            oli4.vlocity_cmt__RootItemId__c = oli4.vlocity_cmt__AssetReferenceId__c;
            update oli4;
            
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
            oli2.vlocity_cmt__PriorQuoteLineItemId__c = oli4.id;
            oli2.vlocity_cmt__RootItemId__c = oli1.vlocity_cmt__AssetReferenceId__c;
            oli2.vlocity_cmt__ParentItemId__c = oli1.vlocity_cmt__AssetReferenceId__c;
            
            insert oli2;
            
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
            
            vlocity_cmt__ContractLineItem__c cli=new vlocity_cmt__ContractLineItem__c();
            cli.name='Office';
            cli.vlocity_cmt__product2id__c=prod.id;
            cli.vlocity_cmt__ContractId__c=contract.id;
            cli.vlocity_cmt__QuoteLineItem__c = oli4.id;
            cli.TeliaSE_MC_Customer_Requested_Percentage__c=5;
            cli.vlocity_cmt__AssetReferenceId__c = oli4.vlocity_cmt__AssetReferenceId__c;
            insert cli;
            
            
            Contact con=new Contact();
            con.FirstName='Sunil';
            con.Email='suni@suni.com';
            con.Phone='121234214';
            con.Role__c='Annan';
            con.AccountId=acc.id;
            con.LastName='Sunil';
            insert con;
            
            OpportunityContactRole opc=new OpportunityContactRole();
            opc.Role='Avtalstecknare';
            opc.OpportunityId=opp.id;
            opc.IsPrimary = true;
            opc.ContactId=con.id;
            
            // insert opc;
            
            TeliaSE_PortfolioIdentifiers__c portfolio = new TeliaSE_PortfolioIdentifiers__c();
            portfolio.name = 'Mobile_allInPlus';
            portfolio.NewProductCode__c = 'MOB_MULTI_ALL_IN_PLUS_V2';
            portfolio.OldProductCode__c = 'MOB_MULTI_ALL_IN_PLUS';
            portfolio.ProductId__c = prod.id;
            insert portfolio;
            
            TeliaSE_PortfolioIdentifiers__c portfolio1 = new TeliaSE_PortfolioIdentifiers__c();
            portfolio1.name = 'Mobile_Total';
            portfolio1.NewProductCode__c = 'MOB_MULTI_TOTAL_V2';
            insert portfolio1;
            
            TeliaSE_PortfolioIdentifiers__c portfolio2 = new TeliaSE_PortfolioIdentifiers__c();
            portfolio2.name = 'Office365';
            //portfolio2.OldProductCode__c = 'C-OFFICE-365';
            portfolio2.NewProductCode__c = 'C-OFFICE-365';
            insert portfolio2;
            
            Test.stopTest();
        }
    }
    @isTest
    public static void testCreateSA()
    {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Map<String,Object> quoteMap=new Map<String,Object>();
        
        List<Map<String,String>> lines=new List<Map<String,String>>();
        
        Quote quote=[select id from Quote where name='Test Quote'][0];
        
        List<QuoteLineItem> item=[select id from QuoteLineItem limit 2];    
        Product2 prod=[select id from Product2 limit 1];
        
        TeliaSE_CreateSAContract obj=new TeliaSE_CreateSAContract();
        inputMap.put('ContextId',quote.id);
        inputMap.put('Type','Renegotiation');
        
        Map<String,String> line=new Map<String,String>();
        line.put('startDate','2018-01-16T18:30:00.000Z');
        line.put('endDate','2020-01-16T18:30:00.000Z');
        line.put('Id',item[0].id);
        line.put('RootProduct',prod.Id);
        //line.put('Type','Renegotiation');
        lines.add(line);
        
        Map<String,String> line1=new Map<String,String>();
        line1.put('startDate','2017-01-16T18:30:00.000Z');
        line1.put('endDate','2019-01-16T18:30:00.000Z');
        line1.put('Id',item[1].id);
        line1.put('RootProduct',prod.Id);
        lines.add(line1);
        
        quoteMap.put('Line',lines);
        inputMap.put('Quote',quoteMap);
        
        Map<String,Object> inputMap1=new Map<String,Object>();  
        Map<String,Object> outMap1=new Map<String,Object>();  
        Map<String,Object> options1=new Map<String,Object>();  
        Map<String,Object> quoteMap1=new Map<String,Object>();  
        quoteMap1.put('Line',lines);  
        inputMap1.put('Quote',quoteMap);  
        //WinputMap1.put('Type','Renegotiation');
        
        Test.startTest();
        obj.invokeMethod('createSA',inputMap,outMap,options);
        //obj.invokeMethod('createSA',inputMap1,outMap1,options1);
        Test.stopTest();
    }
    
    
    @isTest
    public static void testCreateSANew()
    {
        Map<String,Object> inputMap1=new Map<String,Object>();
        Map<String,Object> outMap1=new Map<String,Object>();
        Map<String,Object> options1=new Map<String,Object>();
        Map<String,Object> quoteMap=new Map<String,Object>();
        
        List<Map<String,String>> lines=new List<Map<String,String>>();
        
        Quote quote=[select id from Quote where TeliaSE_MC_Sales_Flow_Identifier__c='New Sales'];
        
        Product2 prod=[select id from Product2 where Name = 'Användarpaket'];
        List<QuoteLineItem> item=[select id from QuoteLineItem where Product2Id=:prod.id];    
        
        
        TeliaSE_CreateSAContract obj=new TeliaSE_CreateSAContract();
        inputMap1.put('ContextId',quote.id);
        
        Map<String,String> line=new Map<String,String>();
        line.put('startDate','2018-01-16T18:30:00.000Z');
        line.put('endDate','2020-01-16T18:30:00.000Z');
        line.put('Id',item[0].id);
        line.put('RootProduct',prod.Id);
        lines.add(line);
        
        /* Map<String,String> line1=new Map<String,String>();
line1.put('startDate','2017-01-16T18:30:00.000Z');
line1.put('endDate','2019-01-16T18:30:00.000Z');
line1.put('Id',item[1].id);
line1.put('RootProduct',prod.Id);
lines.add(line1);*/
        
        quoteMap.put('Line',lines);
        inputMap1.put('Quote',quoteMap);
        inputMap1.put('Type','Renegotiation');
        test.startTest();
        
        obj.invokeMethod('createSA',inputMap1,outMap1,options1);
        test.stopTest();    
    }
    
    @isTest
    public static void testCreateSANull()
    {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Map<String,Object> quoteMap=new Map<String,Object>();
        
        List<Map<String,String>> lines=new List<Map<String,String>>();
        TeliaSE_CreateSAContract obj=new TeliaSE_CreateSAContract();
        test.startTest();
        
        obj.invokeMethod(null,inputMap,outMap,options);
        test.stopTest();    
    }
    
    @isTest
    public static void testCreateSAUpdateRoot()
    {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Map<String,Object> quoteMap=new Map<String,Object>();
        
        List<Map<String,String>> lines=new List<Map<String,String>>();
        
        Quote quote=[select id from Quote where name='Test Quote'][0];
        
        List<QuoteLineItem> item=[select id from QuoteLineItem limit 2];    
        Product2 prod=[select id from Product2 limit 1];
        
        TeliaSE_CreateSAContract obj=new TeliaSE_CreateSAContract();
        inputMap.put('ContextId',quote.id);
        
        Map<String,String> line=new Map<String,String>();
        line.put('startDate','2018-01-16T18:30:00.000Z');
        line.put('endDate','2020-01-16T18:30:00.000Z');
        line.put('Id',item[0].id);
        line.put('RootProduct',prod.Id);
        lines.add(line);
        
        Map<String,String> line1=new Map<String,String>();
        line1.put('startDate','2017-01-16T18:30:00.000Z');
        line1.put('endDate','2019-01-16T18:30:00.000Z');
        line1.put('Id',item[1].id);
        line1.put('RootProduct',prod.Id);
        lines.add(line1);
        
        quoteMap.put('Line',lines);
        inputMap.put('Quote',quoteMap);
        inputMap.put('Type','Renegotiation');
        test.startTest();
        
        obj.invokeMethod('UpdateRootProductOffer',inputMap,outMap,options);
        obj.invokeMethod('createSA',inputMap,outMap,options);
        test.stopTest();    
    }  
    
    @isTest  
    public static void testUtilizerCheck(){  
        Map<String,Object> inputMap=new Map<String,Object>();  
        Map<String,Object> outMap=new Map<String,Object>();  
        Map<String,Object> options=new Map<String,Object>();  
        String JsonResponse = '{"CLIParent":[{"ProductCOde":"C-OFFICE-365","Status":"Active","ObjectType":"OFFICE365 Offer Spec"},{"ProductCOde":"C-OFFICE-365","Status":"Active","ObjectType":"Mobile Offer Specification"},{"ProductCOde":"C-OFFICE-365","Status":"Active","ObjectType":"Touch Point Offer Spec"}]}';  
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);  
        TeliaSE_CreateSAContract obj=new TeliaSE_CreateSAContract();  
        obj.invokeMethod('utilizerFlag',inputMap,outMap,options);
    }
    
    @isTest  
    public static void testSaveContractStartEndDates(){  
        Map<String,Object> inputMap=new Map<String,Object>();  
        Map<String,Object> outMap=new Map<String,Object>();  
        Map<String,Object> options=new Map<String,Object>();  
         QuoteLineItem item=[select id from QuoteLineItem limit 1];
        Account acc = [Select id from Account Limit 1];
        Quote quote = [Select id from Quote limit 1];
        Opportunity opp = [Select id, account.id from Opportunity Limit 1];
        
        product2 prod1 = new Product2();
        prod1.name = 'TestProduct2';
        insert prod1;
        
        Contract contract=new Contract();
        contract.Name='Test';
        contract.AccountId=acc.id;
        contract.Status='Draft';
        contract.StartDate=Date.today();
        contract.vlocity_cmt__QuoteId__c=quote.id;
        insert contract;
        
        vlocity_cmt__ContractLineItem__c cli1 = new vlocity_cmt__ContractLineItem__c();
        cli1.vlocity_cmt__ContractId__c = contract.id;
        cli1.vlocity_cmt__Product2Id__c = prod1.Id;
        cli1.Name ='Touchpoint';
        //cli1.TeliaSE_Product_Object_Type__c='TouchPoint Plus Offer Spec';
        cli1.vlocity_cmt__LineStatus__c = 'Added';
        //cli1.vlocity_cmt__QuoteId__c=
        cli1.TeliaSE_Base_Quantity__c =5;
        cli1.vlocity_cmt__QuoteLineItem__c=item.id;
        cli1.vlocity_cmt__RecurringCharge__c = 35;
        cli1.TeliaSE_Root_Product__c = 'testProduct2';
        insert cli1;
        
        inputMap.put('ContextId',contract.id);
        Map<String,Object> line = new Map<String,Object>();
        line.put('disableDate',false);
        line.put('RootProduct','testProduct2');
        line.put('quoteLineItemId',item.id);
        line.put('startDate',Date.today());
        line.put('endDate',Date.today());
        line.put('Id',cli1.id);
        
        List<Map<String,Object>> lineMapList = new list<Map<String,Object>>();
        lineMapList.add(line);
        Map<String,Object> lineMap = new Map<String,Object>();
        lineMap.put('Line',lineMapList);
        inputMap.put('SI_FilteredLines',lineMap);
        TeliaSE_CreateSAContract ts= new TeliaSE_CreateSAContract();
        boolean flag1 = ts.invokeMethod('saveContractDates',inputMap,outMap,options);
        
        
    }
    
}