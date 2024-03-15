@isTest
public with sharing class Scart_ContractMigarteApex_Test 
{
/*
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
            insert prod;
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            insert prod1;
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
            
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            insert objpricebookentry;
            
            
            
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
            oli2.Product2Id = prod.id;
            oli2.vlocity_cmt__Product2Id__c = prod.id;    
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
    public static void TestScartContract()
    {
        Contract con = [Select id,vlocity_cmt__QuoteId__c from contract where name = 'Test123' LIMIT 1];
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Map<String,Object> contractInfo = new Map<String,Object>();
        contractInfo.put('contractid',(String)con.id);
        contractInfo.put('FAQuote',con.vlocity_cmt__QuoteId__c);
        inputMap.put('OriginialContract',contractInfo);
        
        Scart_ContractMigrateOmniscript obj = new Scart_ContractMigrateOmniscript();
        boolean flag = obj.invokeMethod((String)'backupContract',inputMap,outMap,options);
        flag = obj.invokeMethod((String)'contractLinesMigrate',inputMap,outMap,options);
        
        string originalContract = (String)con.id;
        string backupContract = String.valueOf(OutMap.get('backupContractId'));
        options.put('OriginalContract',originalContract);
        options.put('BackupContract',backupContract);
        test.startTest();
        flag = obj.invokeMethod((String)'mergeStatusContractLines',inputMap,outMap,options);
        flag = obj.invokeMethod((String)'revertChanges',inputMap,outMap,options); 
        test.stopTest();
    }
    
    @isTest
    public static void TestScartContract12()
    {
        Contract con = [Select id,vlocity_cmt__QuoteId__c from contract where name = 'Test123' LIMIT 1];
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Map<String,Object> contractInfo = new Map<String,Object>();
        contractInfo.put('contractid',(String)con.id);
        contractInfo.put('FAQuote',con.vlocity_cmt__QuoteId__c);
        inputMap.put('OriginialContract',contractInfo);
        
        Scart_ContractMigrateOmniscript obj = new Scart_ContractMigrateOmniscript();
        boolean flag = obj.invokeMethod((String)'backupContract',inputMap,outMap,options);
        flag = obj.invokeMethod((String)'mergeStatusContractLines',inputMap,outMap,options);
        flag = obj.invokeMethod((String)'revertChanges',inputMap,outMap,options); 
        
    }
    
    @isTest
    public static void TestScartContract123()
    {
        Contract con = [Select id,vlocity_cmt__QuoteId__c from contract where name = 'Test123' LIMIT 1];
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Map<String,Object> contractInfo = new Map<String,Object>();
        contractInfo.put('contractid',(String)con.id);
        contractInfo.put('FAQuote',con.vlocity_cmt__QuoteId__c);
        inputMap.put('OriginialContract',contractInfo);
        
        Scart_ContractMigrateOmniscript obj = new Scart_ContractMigrateOmniscript();
        boolean flag = obj.invokeMethod((String)'backupContracts',inputMap,outMap,options);
    }
    
    @isTest
    public static void TestScartContract1234()
    {
        Contract con = [Select id,vlocity_cmt__QuoteId__c from contract where name = 'Test123' LIMIT 1];
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Map<String,Object> contractInfo = new Map<String,Object>();
        
        Scart_ContractMigrateOmniscript obj = new Scart_ContractMigrateOmniscript();
        boolean flag = obj.invokeMethod((String)'backupContract',inputMap,outMap,options);
    }
    
    @isTest
    public static void TestScartContract12345()
    {
        Contract con = [Select id,vlocity_cmt__QuoteId__c from contract where name = 'Test123' LIMIT 1];
        List<vlocity_cmt__ContractLineItem__c> cliList = [Select id from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c=: con.id];
        system.debug('clilist'+cliList);
        
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Map<String,Object> contractInfo = new Map<String,Object>();
        
        Scart_ContractMigrateOmniscript obj = new Scart_ContractMigrateOmniscript();
        boolean flag = obj.invokeMethod((String)'backupContract',inputMap,outMap,options);
    }
    
    @isTest
    public static void TestScartContract123456()
    {
        Contract con = [Select id,vlocity_cmt__QuoteId__c from contract where name = 'Test123' LIMIT 1];
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Map<String,Object> contractInfo = new Map<String,Object>();
        contractInfo.put('contractid',(String)con.id);
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        qliList = [Select id,TeliaSE_EndDate__c,TeliaSE_StartDate__c,TeliaSE_Root_Product__c,vlocity_cmt__Product2Id__r.name,vlocity_cmt__Product2Id__r.TeliaSE_Product_Version__c,Product2Id,TeliaSE_Discount_Percentage__c,TeliaSE_CommitmentPeriod__c,TeliaSE_Base_Quantity__c,MC_Quarantine_Time__c,TeliaSE_Minimum_Value_Commit__c,TeliaSE_Approved_Price__c,TeliaSE_Approved__c,vlocity_cmt__ProductHierarchyPath__c,vlocity_cmt__ParentItemId__c,vlocity_cmt__RootItemId__c,vlocity_cmt__JSONAttribute__c,vlocity_cmt__Product2Id__c,Quantity,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__OneTimeTotal__c,vlocity_cmt__OneTimeDiscountPrice__c,vlocity_cmt__OneTimeManualDiscount__c,vlocity_cmt__RecurringTotal__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__RecurringDiscountPrice__c,vlocity_cmt__RecurringManualDiscount__c,TeliaSE_MC_Customer_Requested_Percentage__c,TeliaSE_MC_Customer_Requested_Price__c,TeliaSE_Comment__c,TeliaSE_Abroad_Call_Discount__c,TeliaSE_Invoice_Fee__c,TeliaSE_Product_Object_Type__c,TeliaSE_SubsidisedVoice__c,TeliaSE_MC_Campaign_Id__c,TeliaSE_MC_Mobile_WarningActive__c,TeliaSE_MC_Mobile_WarningPercentage__c,TeliaSE_MC_Mobile_AgreedPercentage__c,TeliaSE_MC_Mobile_FunctionActive__c,TeliaSE_MC_TP_WarningPercentage__c,TeliaSE_MC_TP_WarningActive__c,TeliaSE_MC_TP_AgreedPercentage__c,TeliaSE_MC_TP_FunctionActive__c from quoteLineItem where quote.name = 'Test Quote' LIMIT 1];
        Map<Id,Map<String,Object>> itemsMap=new Map<Id,Map<String,Object>>();
        QuoteLineItem qli = new QuoteLineItem();
        if(QliList!= Null && qliList.size()>0)
        {
            qli = qliList[0];
        }
        qli.TeliaSE_StartDate__c = date.today();
        qli.TeliaSE_EndDate__c = date.today();
        Map<String,Object> item = new Map<String,Object>();
        item.put('done','false');
        item.put('endDate',(Date)qli.TeliaSE_EndDate__c);
        item.put('startDate',(Date)qli.TeliaSE_StartDate__c);
        item.put('id',qli.id);
        itemsMap.put(qli.Product2Id,item);
        Map<String, Boolean> qlicalloffflagmap = new Map<String, Boolean>();
        qlicalloffflagmap.put(qli.TeliaSE_Root_Product__c,false);
        test.startTest();
        List<vlocity_cmt__ContractLineItem__c> cliList = Scart_ContractMigarteApex.contractLines(QliList,con.id,itemsMap,true,qlicalloffflagmap);
        test.stopTest();
    }
    
    @isTest
    public static void TestScartContract1234567()
    { 
        Quote quote = [Select id from quote where name = 'migartedQuote' Limit 1];
        Scart_ContractMigarteApex.repricingTP(quote.id);  
    }
    
    @isTest
    public static void TestScartContract12345678()
    {
        Quote qut = [Select id,AccountId from quote where name = 'Test Quote' Limit 1];
        Contract ContractId = [Select id from Contract where name ='Test123' Limit 1];
        Contract conObj = new Contract();
        conObj.vlocity_cmt__QuoteId__c=qut.id;
        conObj.name = 'Test_Backup1';
        conObj.TeliaSE_Type__c = 'Y';
        conObj.StartDate = system.today();
        conObj.accountId = qut.AccountId;
        conObj.TeliaSE_Case_Id__c = '12345';
        conObj.TeliaSE_is_combi__c = true;
        conObj.Status = 'Draft';
        insert conObj;
        
        vlocity_cmt__ContractLineItem__c cli = [Select id,vlocity_cmt__ContractId__c,vlocity_cmt__ProductId__c,vlocity_cmt__Status__c from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c =:ContractId.id Limit 1];
        vlocity_cmt__ContractLineItem__c itemCopy = cli.clone(false,true);
        itemCopy.vlocity_cmt__ContractId__c=conObj.Id;
        insert itemcopy;
        Scart_ContractMigarteApex.mergeStatusContractLines(ContractId,conObj);
    }
    */
}