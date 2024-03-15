@isTest

public class TestFiber_ConntractServices

{
    
    static void setup()
    {
        FiberDiscountMandate__c fb = new FiberDiscountMandate__c();
        fb.Role__c = 'Manager';
        fb.Name = 'Manager';
        fb.EBIT_Max_Mandate__c = 12;
        fb.EBIT_Min_Mandate__c = 1;
        fb.ProductDiscountMaxMandate__c = 12;
        fb.ProductDiscountMinMandate__c = 12;
        insert fb;
        
        FiberDiscountMandate__c fb1 = new FiberDiscountMandate__c();
        fb1.Role__c = 'Director';
        fb1.Name = 'Director';
        fb1.EBIT_Max_Mandate__c = 12;
        fb1.EBIT_Min_Mandate__c = 1;
        fb1.ProductDiscountMaxMandate__c = 12;
        fb1.ProductDiscountMinMandate__c = 12;
        insert fb1; 
        
    }
    
    public static testMethod void TestgetNewQuote()
        
    {
        Id AccRtid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SME/SOHO Organisation').getRecordTypeId();
        
        Account testAccount = new Account();
        testAccount.recordtypeid = AccRtid;
        testAccount.Name = 'Sangram test12';
        insert testAccount;
        
        
        Contact cont = new Contact();
        cont.FirstName='Test';
        cont.LastName='Test';
        cont.Accountid= testAccount.id;
        cont.Email='abc@abc.com';
        cont.Role__c='IT-chef/CTO';
        insert cont;
        
        
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.AccountId= testAccount.id;
        testOpportunity.Name = 'Test Opportunity';
        testOpportunity.StageName='closed last';
        testOpportunity.Expected_Opportunity_Type__c ='Soho test';
        testOpportunity.CloseDate=system.today(); 
        testOpportunity.StageName = 'Kvalificera'; 
        insert testOpportunity;
        
        Contract contr = new Contract();
        contr.AccountId = testAccount.Id;
        contr.StartDate = date.today();
        contr.Actionneeded__c = false;
        contr.Large_dataload__c = false;
        contr.vlocity_cmt__IsAutoRenew__c = false;
        contr.vlocity_cmt__IsFrameContract__c = false;
        contr.TeliaSE_Previous_Contract_Number__c= '000001';
        contr.TeliaSE_Fiber_Base_Contract_Number__c ='000002' ;
        insert contr;
        
        
        //Fiber_ConntractServices.getNewQuote(testOpportunity.Name,'Individual Quote',contr.id,testOpportunity.id);
        //Fiber_ConntractServices.updateContract(contr.id);
        
    }
    
    
    
    public  static testMethod void TestcreateQuoteLineItemFromContract()
    {
        
        
        Id AccRtid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SME/SOHO Organisation').getRecordTypeId();
        
        Account testAccount = new Account();
        testAccount.recordtypeid = AccRtid;
        testAccount.Name = 'Sangram test123';
        insert testAccount;
        
        
        Contact cont = new Contact();
        cont.FirstName='Test';
        cont.LastName='Test';
        cont.Accountid= testAccount.id;
        cont.Email='abc@abc.com';
        cont.Role__c='IT-chef/CTO';
        insert cont;
        
        Opportunity testOpportunity = Test_DataFactory.createSmeOpportunity();
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.Expected_Opportunity_Type__c ='Soho';
        testOpportunity.Name = 'Test Opportunity';
        insert testOpportunity;
        
        setup();
        
        
        
        //Opportunity testOpportunity = new Opportunity();
        //testOpportunity.AccountId= testAccount.id;
        //testOpportunity.Name = 'Test Opportunity';
        //testOpportunity.StageName='closed last';
        //testOpportunity.CloseDate=system.today();    
        //insert testOpportunity;
        
        
        
        
        
        //Contract CC = New Contract();
        //CC.Accountid = testAccount.Id;
        //CC.Status = 'Draft'; 
        //CC.CurrencyIsoCode = 'SEK';
        //CC.StartDate = Date.today();
        //CC.ContractTerm = 2;
        
        //insert CC;   
        /*   
Pricebook2 standardBook =  new Pricebook2(Id = Test.getStandardPricebookId(), Name = 'TestPricebook5', IsActive = true);

//Pricebook2 stdPb = [select Id from Pricebook2 where isStandard=true limit 1];

Product2 p = new product2(name='Mobile',family='Telecom',productcode='12345');
insert p;

PricebookEntry pbe = new PricebookEntry(pricebook2id=standardBook.id, product2id=p.id,
unitprice=1.0, isActive=true,UseStandardPrice=false);
insert pbe;
RecordType rt = [Select id,name, DeveloperName from RecordType where Name='Individual Quote'];
Id pricebookId;
Id stdPriceBookRecId = Test.getStandardPricebookId();

*/
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        insert prod;
        Id pricebookId = stdPriceBookRecId ;
        
        vlocity_cmt__PriceList__c objpricelist = new vlocity_cmt__PriceList__c();
        objpricelist.Name = 'MDU';
        objpricelist.vlocity_cmt__Code__c = 'Fiber';
        insert objpricelist;
        
        PricebookEntry objpricebookentry =new PricebookEntry();
        objpricebookentry.Product2ID = prod.id;
        objpricebookentry.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry.UnitPrice=23.50;
        objpricebookentry.UseStandardPrice=false;
        objpricebookentry.isActive=true;//Add this line
        insert objpricebookentry;
        RecordType rt = [Select id,name, DeveloperName from RecordType where Name='Individual Quote'];
        Quote q = new Quote();
        q.Name='Test Quote';
        q.status = 'Draft';
        q.Pricebook2Id=pricebookId ;
        q.RecordTypeId = rt.Id;
        
        q.opportunityId = testOpportunity.id;
        //q.Pricebook2ID = stdPriceBookRecId;
        q.TeliaSE_Approval_Flag__c = False;        
        insert q;
        
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.PricebookEntryId = objpricebookentry.Id;
        qli.QuoteId = q.id;
        //qli.TeliaSE_Quote_RecordType__c = [Select TeliaSE_Quote_RecordType__c from QuoteLineItem where TeliaSE_Quote_RecordType__c = 'Individual Quote'];
        qli.UnitPrice = 200;
        qli.Quantity = 4;
        qli.Product2Id = prod.id;
        qli.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
        qli.TeliaSE_Approved__c = null;
        qli.vlocity_cmt__RecurringCharge__c  = 200;
        qli.TeliaSE_Ceiling_Price__c = 400;
        insert qli; 
        
        
        
        
        //QuoteLineItem qli = new QuoteLineItem(quoteId=q.Id,pricebookentryid=pbe.id, unitprice=1.5, quantity=2);
        //insert qli;
        Contract CC= new Contract();
        
        CC.TeliaSE_Type__c = 'Renegotiation';
        CC.StartDate = system.today();
        CC.status = 'Draft';
        CC.accountId = testAccount.Id;
        CC.TeliaSE_Case_Id__c = '12345';
        CC.vlocity_cmt__PriceListId__c = objpricelist.Id;
        CC.vlocity_cmt__QuoteId__c=q.id;
        insert CC;
        
        Contract CC1= new Contract();
        
        CC1.TeliaSE_Type__c = 'Renegotiation';
        CC1.StartDate = system.today();
        CC1.status = 'Draft';
        CC1.accountId = testAccount.Id;
        CC1.TeliaSE_Case_Id__c = '12345';
        insert CC1;
        
       
        Contract CC2= new Contract();
        CC2.TeliaSE_Type__c = 'Renegotiation';
        CC2.StartDate = system.today();
        CC2.status = 'Draft';
        CC2.accountId = testAccount.Id;
        CC2.TeliaSE_Case_Id__c = '12345';
        CC2.TeliaSE_Previous_Contract_Number__c= [select id,contractnumber from contract where id=:CC.id].contractnumber;
        CC2.TeliaSE_Fiber_Base_Contract_Number__c =[select id,contractnumber from contract where id=:CC1.id].contractnumber;
        insert CC2;
        
        
        Fiber_ConntractServices ec =new Fiber_ConntractServices();
        
        Map<String,Object> inputMap = new Map<String,Object>();
        
        inputMap.put('DRId_Contract', CC2.Id);
        inputMap.put('contractId', CC.Id);
         system.debug('%%%%%%%%' +CC2.id);
        inputMap.put('OpportunityName', testOpportunity.Name);
        inputMap.put('OpportunityId',testOpportunity.Id);
        inputMap.put('cType', 'Individual Agreement');
        
        
        
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> optionMap = new Map<String, Object>();       
        
        ec.invokeMethod('createQuoteFromContract',inputMap,outputMap,optionMap);  
        
        ec.invokeMethod('createContractLineItemFromQuote',inputMap,outputMap,optionMap); 
        //Fiber_ConntractServices.createQuoteLineItemFromContract(inputMap,outputMap);
        
        
    }
    
    
    
}