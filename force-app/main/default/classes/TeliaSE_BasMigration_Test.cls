@isTest
public with sharing class TeliaSE_BasMigration_Test 
{
    
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
            prod.ProductCode = 'MOB_SURF_BAS_V2';
            insert prod;
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.productCode = 'MOB_DATA_PORTFOLIO';
            insert prod1;
            
            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            prod2.productCode = 'MOB_DATA';
            insert prod2;
            pricebookId = stdPriceBookRecId ;
            
            vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
            objClass.Name = 'Touch Point Offer Spec';    
            objClass.vlocity_cmt__IsActive__c = True;
            objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
            insert objClass;
            Product2 prodTouchpoint = Test_DataFactory.createProducts(1)[0];
            prodTouchpoint.vlocity_cmt__ObjectTypeId__c = objClass.Id;
            insert prodTouchpoint;    
            pricebookId = stdPriceBookRecId ;
            
            Account acc=Test_DataFactory.createOneSMEAccount();
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            List<PricebookEntry> pbelist = new List<PricebookEntry>();
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            pbeList.add(objpricebookentry);
            
            PricebookEntry objpricebookentry1 =new PricebookEntry();
            objpricebookentry1.Product2ID = prod1.id;
            objpricebookentry1.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry1.UnitPrice=23.50;
            objpricebookentry1.UseStandardPrice=false;
            objpricebookentry1.isActive=true;//Add this line
            pbeList.add(objpricebookentry1);
            
            PricebookEntry objpricebookentry2 =new PricebookEntry();
            objpricebookentry2.Product2ID = prod2.id;
            objpricebookentry2.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry2.UnitPrice=23.50;
            objpricebookentry2.UseStandardPrice=false;
            objpricebookentry2.isActive=true;//Add this line
            pbeList.add(objpricebookentry2);
            
            insert pbeList;
            
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Active';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;
            
            insert contract;
            
            vlocity_cmt__ContractLineItem__c cli=new vlocity_cmt__ContractLineItem__c();
            cli.name='Office';
            cli.vlocity_cmt__product2id__c=prod.id;
            cli.vlocity_cmt__ContractId__c=contract.id;
            cli.TeliaSE_MC_Customer_Requested_Percentage__c=5;
            
            insert cli;
            
            
            Account acc1=Test_DataFactory.createOneSMEAccount();
            acc1.FA_Contract__c=contract.id;
            insert acc1;
            
            String masterQuote=System.Label.TeliaSE_Master_quote;
            
            test.startTest();
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
            
            Quote qut2 = new Quote();
            qut2.Name='migartedQuote';
            qut2.status = 'Draft';
            qut2.TeliaSE_RenegotiatedAgreement__c=contract.id;
            qut2.TeliaSE_Type__c='Renegotiation';
            qut2.opportunityId = opp.id;
            qut2.Pricebook2ID = stdPriceBookRecId;
            qut2.TeliaSE_Approval_Flag__c = False;        
            qut2.TeliaSE_RevisedAgreement__c=contract.id;
            qut2.TeliaSE_MC_Sales_Flow_Identifier__c='Omforhandling';
            insert qut2;
            
            Quote qut3 = new Quote();
            qut3.Name='migartedQuote_backup1';
            qut3.status = 'Draft';
            qut3.vlocity_cmt__ParentQuoteId__c = qut2.id;
            qut3.TeliaSE_RenegotiatedAgreement__c=contract.id;
            qut3.TeliaSE_Type__c='Renegotiation';
            qut3.opportunityId = opp.id;
            qut3.Pricebook2ID = stdPriceBookRecId;
            qut3.TeliaSE_Approval_Flag__c = False;        
            qut3.TeliaSE_RevisedAgreement__c=contract.id;
            qut3.TeliaSE_MC_Sales_Flow_Identifier__c='Omforhandling';
            insert qut3;
            
            
            Contract conObj1 = new Contract();
            conObj1.vlocity_cmt__QuoteId__c=qut.id;
            conObj1.name = 'Test1234';
            conObj1.TeliaSE_Type__c = 'Y';
            conObj1.StartDate = system.today();
            conObj1.accountId = acc.Id;
            conObj1.TeliaSE_Case_Id__c = '12345';
            conObj1.TeliaSE_is_combi__c = true;
            conObj1.Status = 'draft';
            insert conObj1;
            
            qut.TeliaSE_RenegotiatedAgreement__c = conObj1.id;
            qut.TeliaSE_RevisedAgreement__c=conObj1.id;
            update qut;
            
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
            
            QuoteLineItem oli4 = new QuoteLineItem();
            oli4.PricebookEntryId = objpricebookentry.Id;
            oli4.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli4.QuoteId = qut2.id;
            oli4.UnitPrice = 200;
            oli4.Quantity = 4;
            oli4.vlocity_cmt__Product2Id__c = prodTouchpoint.id;
            oli4.Product2Id = prodTouchpoint.id;
            oli4.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli4.TeliaSE_Approved__c = null;
            oli4.vlocity_cmt__RecurringCharge__c  = 200;
            oli4.TeliaSE_Ceiling_Price__c = 400;
            oli4.TeliaSE_Root_Product__c=prodTouchpoint.id;
            insert oli4; 
            
            QuoteLineItem oli5 = new QuoteLineItem();
            oli5.PricebookEntryId = objpricebookentry.Id;
            oli5.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli5.QuoteId = qut3.id;
            oli5.UnitPrice = 200;
            oli5.Quantity = 4;
            oli5.vlocity_cmt__Product2Id__c = prodTouchpoint.id;
            oli5.Product2Id = prodTouchpoint.id;
            oli5.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli5.TeliaSE_Approved__c = null;
            oli5.vlocity_cmt__RecurringCharge__c  = 200;
            oli5.TeliaSE_Ceiling_Price__c = 400;
            oli5.TeliaSE_Root_Product__c=prodTouchpoint.id;
            insert oli5; 
            
            
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
            oli1.vlocity_cmt__ParentItemId__c = null;
            insert oli1;
            oli1.vlocity_cmt__RootItemId__c=oli1.Id;
            
            update oli1;
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.PricebookEntryId = objpricebookentry.Id;
            oli2.QuoteId = qut.id;
            oli2.UnitPrice = 200;
            oli2.Quantity = 4;
            oli2.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli2.Product2Id = prod1.id;
            oli2.vlocity_cmt__Product2Id__c = prod1.id;    
            oli2.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli2.TeliaSE_Approved__c = null;
            oli2.vlocity_cmt__RecurringCharge__c  = 200;
            oli2.TeliaSE_Ceiling_Price__c = 400;
            oli2.TeliaSE_Root_Product__c=prod.id;
            oli2.vlocity_cmt__RootItemId__c=oli1.Id;
            oli2.vlocity_cmt__ParentItemId__c = oli1.Id;            
            insert oli2;
            
            
            
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
            opc.ContactId=con.id;
            
            insert opc;
            
            Contract conObj = new Contract();
            conObj.vlocity_cmt__QuoteId__c=qut.id;
            conObj.name = 'Test123';
            conObj.TeliaSE_Type__c = 'Y';
            conObj.StartDate = system.today();
            conObj.accountId = acc.Id;
            conObj.TeliaSE_Case_Id__c = '12345';
            conObj.TeliaSE_is_combi__c = true;
            conObj.Status = 'Draft';
            insert conObj;
            
            
            
            vlocity_cmt__ContractLineItem__c cli1 = new vlocity_cmt__ContractLineItem__c();
            cli1.vlocity_cmt__ContractId__c = conObj.id;
            cli1.TeliaSE_Start_Date__c = system.today();
            cli1.vlocity_cmt__ProductId__c = prod.id;
            cli1.vlocity_cmt__Status__c = 'Active';
            
            
            vlocity_cmt__ContractLineItem__c cli2 = new vlocity_cmt__ContractLineItem__c();
            cli2.vlocity_cmt__ContractId__c = conObj.id;
            cli2.TeliaSE_Start_Date__c = system.today();
            cli2.vlocity_cmt__ProductId__c = prod1.id;
            cli2.vlocity_cmt__Status__c = 'Updated';
            
            insert cli1;
            insert cli2;
            
            qut.TeliaSE_RenegotiatedAgreement__c = conObj.id;
            update qut;
            Test.stopTest();    
        }
    }
    
    @isTest
    public static void testBasMigration()
    {
        Contract con = [Select id,vlocity_cmt__QuoteId__c from contract where name = 'Test123' LIMIT 1];
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Id quoteId = (Id)con.vlocity_cmt__QuoteId__c;
        inputMap.put('QuoteId',quoteId);
        boolean flag = TeliaSE_BasMigration.invokeMethod((String)'createBackUp',inputMap,outMap,options);
        //flag = obj.invokeMethod((String)'contractLinesMigrate',inputMap,outMap,options);
        flag = TeliaSE_BasMigration.invokeMethod((String)'deleteJobSurf',inputMap,outMap,options);        
    }
    
    
    @isTest
    public static void testBasMigration1()
    {
        Contract con = [Select id,vlocity_cmt__QuoteId__c from contract where name = 'Test123' LIMIT 1];
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Id quoteId = (Id)con.vlocity_cmt__QuoteId__c;
        inputMap.put('NewTotal',true);
        inputMap.put('cartId',quoteId);
        QuoteLineItem qli = [Select id from quoteLineItem where quoteId =: quoteId LIMIT 1];
        inputMap.put('parentItemId',null);
        inputMap.put('hierarchy',qli.Id);
        boolean flag = TeliaSE_BasMigration.invokeMethod((String)'addDataPaket',inputMap,outMap,options);
        inputMap.put('NewTotal',false);
        flag = TeliaSE_BasMigration.invokeMethod((String)'addDataPaket',inputMap,outMap,options);
        
    }
    
    @isTest
    public static void testBasMigration2()
    {
        System.runAs(Test_DataFactory.getByPassUser())
        {
            Contract con = [Select id,vlocity_cmt__QuoteId__c from contract where name = 'Test123' LIMIT 1];
            Map<String,Object> inputMap=new Map<String,Object>();
            Map<String,Object> outMap=new Map<String,Object>();
            Map<String,Object> options=new Map<String,Object>();
            Id quoteId = (Id)con.vlocity_cmt__QuoteId__c;
            options.put('QuoteId',quoteId);
            String quoteQuery=queryBuilder('Quote');
            quoteQuery+=' FROM Quote WHERE '+'Id=\'' + String.escapeSingleQuotes(quoteId)+'\'' ;
            List<Quote> data=  Database.query(quoteQuery);
            Quote quote1=data.get(0);
            Quote quoteClone = quote1.clone(false,true);
            insert quoteClone;
            String qliQuery=queryBuilder('QuoteLineItem');
            qliQuery+=' FROM QuoteLineItem WHERE '+'quoteid=\'' + String.escapeSingleQuotes(quoteId)+'\'' ;
            list<QuoteLineItem> itemsData =  Database.query(qliQuery);
            List<QuoteLineItem> qliListnew = new List<QuoteLineItem>();
            for(QuoteLineItem qli:itemsData)
            {
                QuoteLineItem qliClone = qli.clone(false,true);
                qliClone.QuoteId = quoteClone.id;
                qlilistnew.add(qliClone);
            }
            insert qliListnew;
            options.put('BackupQuoteId',quoteClone.id);
            options.put('Contractid',con.id); 
            options.put('NewTotal',true);
            boolean flag = TeliaSE_BasMigration.invokeMethod((String)'mergeFromBackup',inputMap,outMap,options); 
            flag = TeliaSE_BasMigration.invokeMethod((String)'mergeFromBackupContract',inputMap,outMap,options); 
        }
    }
    
    @isTest
    public static void testBasMigration3()
    {
        Contract con = [Select id,vlocity_cmt__QuoteId__c from contract where name = 'Test123' LIMIT 1];
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Id quoteId = (Id)con.vlocity_cmt__QuoteId__c;
        options.put('Contractid',con.Id);
        boolean flag = TeliaSE_BasMigration.invokeMethod((String)'createBackupContract',inputMap,outMap,options);        
    }
    
    
    //return dynamic query for the Object    
    private static String queryBuilder(String obj)
    {
        SObjectType quoteObj = Schema.getGlobalDescribe().get(obj);
        Map<String,Schema.SObjectField> objfields = quoteObj.getDescribe().fields.getMap();
        String query = 'Select ';
        Boolean firstField = true;
        List<Sobject> quoteList=new List<Sobject>();
        
        for (String field : objfields.keySet())
        {
            if(firstField)
                query += field;
            else{
                query +=' , ';
                query += field;
            }
            
            firstField = false;
        }
        return query;
    }
}