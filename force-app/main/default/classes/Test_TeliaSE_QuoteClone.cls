@isTest
public class Test_TeliaSE_QuoteClone {
    
    @testSetup static void setup()
    {
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        System.runAs(new User(Id = Userinfo.getUserId()))
        {
            salesManager = Test_DataFactory.createAdminUser();
            salesManager.Bypass_VR__c = true;
            salesManager.FirstName = 'TestRunUser';
            salesManager.IsActive = true;
            insert salesManager;
        }
        System.runAs(salesManager)
        {
            Account acc=Test_DataFactory.createOneSMEAccount();
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            opp.IsPreChecked__c = true;
            insert opp;
            
            Opportunity opp1 = new Opportunity();
            opp1.Name='opp2';
            opp1.AccountId=acc.Id;
            opp1.CloseDate = System.today();
            opp1.StageName='Needs Analysis';
            opp.IsPreChecked__c = false;
            opp1.Pricebook2Id=Test.getStandardPricebookId();
            insert opp1;
                        
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            insert prod;
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            insert objpricebookentry;
            
            vlocity_cmt__Premises__c premise2 = new vlocity_cmt__Premises__c();
            premise2.vlocity_cmt__City__c = 'solna';
            premise2.vlocity_cmt__StreetAddress__c = 'Stjärntorget';
            premise2.vlocity_cmt__PostalCode__c = '12113';
            premise2.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            insert premise2;
            
            vlocity_cmt__ServicePoint__c spoint = new vlocity_cmt__ServicePoint__c();
            spoint.vlocity_cmt__ServicePointNumber__c = '1212122';
            spoint.vlocity_cmt__PremisesId__c = premise2.Id;
            insert spoint;
            
            RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;  
            contract.recordtypeId = rt1.id;
            insert contract; 
            contract.Status = 'Active';
            update contract;
            acc.FA_Contract__c=contract.id;
            update acc;
            
            Quote qut1 = new Quote();
            qut1.Name='Test Version1';
            qut1.status = 'Draft';
            qut1.opportunityId = opp.id;
            qut1.Pricebook2ID = stdPriceBookRecId;
            qut1.TeliaSE_Approval_Flag__c = False; 
            qut1.TeliaSE_RenegotiatedAgreement__c=contract.id;
            qut1.TeliaSE_Type__c='Renegotiation';
            qut1.TeliaSE_MC_Sales_Flow_Identifier__c = 'New Sales';
            //   qut1.TeliaSE_Record_Type_Name__c = 'Contract';
            insert qut1; 
                        
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.QuoteId = qut1.id;
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
            
            MC_PreCheck_Result__c preresult = new MC_PreCheck_Result__c();
            preresult.Name = 'BredbandPro' ;
            preresult.MC_Product_Code__c= 'CO-BBPRO-1000MB';
            preresult.Price__c= 7300;
            preresult.MC_PriceParameter__c = 'P5' ;
            preresult.MC_PriceAverageFlag__c = true ;
            preresult.Opportunity__c= opp.Id;
            preresult.Service_Point__c = spoint.Id;
            preresult.RecordTypeId = Schema.SObjectType.MC_PreCheck_Result__c.getRecordTypeInfosByName().get('Netfraga Response').getRecordTypeId();
            insert preresult;
            
            MC_PreCheck_Result__c preresult1 = new MC_PreCheck_Result__c();
            preresult1.Name = 'BredbandPro' ;
            preresult1.MC_Product_Code__c= 'CO-BBPRO-1000MB';
            preresult1.Price__c= 7300;
            preresult1.MC_PriceParameter__c = 'P5' ;
            preresult1.MC_PriceAverageFlag__c = true ;
            preresult1.Opportunity__c= opp.Id;
            preresult1.RecordTypeId = Schema.SObjectType.MC_PreCheck_Result__c.getRecordTypeInfosByName().get('AveragePrice').getRecordTypeId();
            insert preresult1;               
        }        
    }
    
    @isTest
    public static void test()
    {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        Quote quote=[SELECT id,TeliaSE_Record_Type_Name__c,TeliaSE_MC_Sales_Flow_Identifier__c FROM Quote WHERE name='Test Version1' LIMIT 1];
        Contract con=[SELECT id FROM Contract LIMIT 1];
        Opportunity opp=[SELECT id FROM Opportunity LIMIT 1];
        QuoteLineItem item=[SELECT id FROM QuoteLineItem LIMIT 1];    
        Product2 prod=[SELECT id FROM Product2 LIMIT 1];
        inputMap.put('TeliaSE_MC_Sales_Flow_Identifier__c',quote.id);
        inputMap.put('ContextId',opp.id); 
        inputMap.put('QuoteId',quote.id); 
        inputMap.put('ContractId',con.id); 
        inputMap.put('Type',quote.TeliaSE_Record_Type_Name__c);
        inputMap.put('MCSalesFlowIdentifierNq',quote.TeliaSE_MC_Sales_Flow_Identifier__c);
        
        Quote q= [SELECT id,name,TeliaSE_Record_Type_Name__c FROM Quote WHERE id=:quote.id];
        User user=[SELECT id  FROM User WHERE Bypass_VR__c=true and FirstName = 'TestRunUser' LIMIT 1];
        System.runAs(user)
        {
            TeliaSE_QuoteClone obj=new TeliaSE_QuoteClone();
            test.startTest();
            obj.invokeMethod('cloneQuote',inputMap,outMap,options);
            
            obj.invokeMethod('dummy', inputMap, outMap, options);
            test.stopTest();
        }  
    }
    
    @isTest
    public static void test1() {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        Quote quote=[SELECT id,TeliaSE_Record_Type_Name__c,TeliaSE_MC_Sales_Flow_Identifier__c FROM Quote WHERE name='Test Version1' LIMIT 1];
        Contract con=[SELECT id FROM Contract LIMIT 1];
        Opportunity opp=[SELECT id FROM Opportunity LIMIT 1];
        QuoteLineItem item=[SELECT id FROM QuoteLineItem LIMIT 1];    
        Product2 prod=[SELECT id FROM Product2 LIMIT 1];
        
        inputMap.put('TeliaSE_MC_Sales_Flow_Identifier__c',quote.id);
        inputMap.put('ContextId',opp.id); 
        inputMap.put('QuoteIDValue',quote.id); 
        inputMap.put('ContractId',con.id); 
        inputMap.put('Type',null);
        inputMap.put('MCSalesFlowIdentifier',quote.TeliaSE_MC_Sales_Flow_Identifier__c);
        
        Map<String,Object> contractMap = new Map<String,Object>();
        Map<String,Object> contractMap1 = new Map<String,Object>();
        Map<String,Object> quoteMap = new Map<String,Object>();
        Map<String,Object> opptyMap = new Map<String,Object>();        
        contractMap.put('QuoteId',quote.id);
        contractMap.put('ContractId',con.id);
        opptyMap.put('Name','TestOppty');
        inputMap.put('Opportunity',opptyMap);
        contractMap1.put('ParentAgreement','12345');
        contractMap1.put('AgreementNumber','123453');
        quoteMap.put('parentAgreement','123456');
        contractMap1.put('Quote',quoteMap);
        contractMap.put('Contract',contractMap1);        
        inputMap.put('ContractExtract',contractMap);
        inputMap.put('miniDebTPFunctionActive','Y');
        inputMap.put('miniDebTPAgreedPercentage','75');
        inputMap.put('miniDebMobileWarningPercentage','75');
        inputMap.put('miniDebTPWarningPercentage','75');
        inputMap.put('miniDebTPWarningActive','Y');
        inputMap.put('miniDebMobileAgreedPercentage','75');
        inputMap.put('miniDebMobileFunctionActive','75');
        inputMap.put('miniDebMobileWarningActive','75');
        User user = [SELECT Id  FROM User WHERE Bypass_VR__c=true and FirstName = 'TestRunUser' LIMIT 1];
        System.runAs(user)
        {
            TeliaSE_QuoteClone obj=new TeliaSE_QuoteClone();
            test.startTest();
            obj.invokeMethod('cloneQuote',inputMap,outMap,options);
            test.stopTest();
        }
    }
    
    @isTest
    public static void test_copyPrecheckData() {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Opportunity opp = [SELECT id,AccountId FROM Opportunity where IsPreChecked__c=false LIMIT 1];
        inputMap.put('ContextId',opp.id); 
        inputMap.put('AccountId',opp.AccountId);
        User user = [SELECT id  FROM User WHERE Bypass_VR__c = true AND FirstName = 'TestRunUser' LIMIT 1];
        System.runAs(user)
        {
            TeliaSE_QuoteClone obj=new TeliaSE_QuoteClone();
            test.startTest();
            obj.invokeMethod('copyPrecheckData',inputMap,outMap,options);
            test.stopTest();
        }
        
    }
    
    @isTest
    public static void test_checkOldProducts() {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Quote quote=[SELECT Id,TeliaSE_Record_Type_Name__c,TeliaSE_MC_Sales_Flow_Identifier__c FROM Quote WHERE name='Test Version1' LIMIT 1];
        inputMap.put('QuoteIDValue',quote.Id);
        User user=[SELECT Id  FROM User WHERE Bypass_VR__c = true AND FirstName = 'TestRunUser' LIMIT 1];
        System.runAs(user)
        {
            TeliaSE_QuoteClone obj=new TeliaSE_QuoteClone();
            test.startTest();
            obj.invokeMethod('checkOldProducts',inputMap,outMap,options);
            test.stopTest();
        }        
    }
}