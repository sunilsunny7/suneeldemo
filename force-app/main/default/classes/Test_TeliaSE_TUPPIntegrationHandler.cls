/****************************************************************************************************************************
* @author                 Abhinav gupta     <abhinav.gupta@capgemini.com>
* @modifiedBy             Abhinav gupta     <abhinav.gupta@capgemini.com>
* @maintainedBy           
* @version                1.0
* @created                2021-04-16
* @modified               2021-04-16
* @Covers Apex Classes:   TeliaSE_TUPPIntegrationHandler , TeliaSE_UpdateContract_TUPP
******************************************************************************************************************************/
@isTest
public class Test_TeliaSE_TUPPIntegrationHandler 
{
    @testSetup static void setup(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        System.runAs(Test_DataFactory.getByPassUser()){            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.ProductCode='C-OFFICE-365';
            prod.TeliaSE_MC_isCallOff_Flag__c = false;
            insert prod;
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            insert prod1;
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
            
            RecordType rec = [Select id from RecordType where Name = 'Ramavtal'];

            Contract contract=new Contract();
            contract.Name='Test';
            contract.recordTypeId = rec.id;
            contract.TeliaSE_Case_Id__c = '12345';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();            
            contract.ContractTerm=24;
            
            insert contract;
            
            Utilizer_Contract_Relationship__c utilizer = new Utilizer_Contract_Relationship__c();
            utilizer.Org_Number__c = acc.Org_Nr__c;
            utilizer.AccountId__c =acc.id;
            utilizer.ContractNumber__c =contract.Id;
            utilizer.Utilizer_Role__c ='';
            utilizer.Status__c ='Aktiv';
            insert utilizer;            
            
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
            
            contract.vlocity_cmt__QuoteId__c = qut.id;
            update contract;
                
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
            
            oli3.vlocity_cmt__RootItemId__c = oli3.id;
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
            
            oli1.vlocity_cmt__RootItemId__c = oli1.id;
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
            oli2.vlocity_cmt__RootItemId__c = oli1.id;
            oli2.vlocity_cmt__ParentItemId__c = oli1.Id;
            insert oli2;
            
            
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
            
            oli4.vlocity_cmt__RootItemId__c = oli4.id;
            update oli4;
            
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
    public static void testTUPPIntegration()
    {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Contract con = [Select id,vlocity_cmt__QuoteId__c from Contract where name ='Test'];
        TeliaSE_TUPPIntegrationHandler.callDeleteAgreemntCase(con.id);
        TeliaSE_TUPPIntegrationHandler obj = new TeliaSE_TUPPIntegrationHandler();
        obj.updateCallOffStatus(inputMap,con.vlocity_cmt__QuoteId__c);
        obj.RegisterCaseupdateContract('registerCase',inputMap,con.id);
    }
    
    @isTest
    public static void testTUPPIntegration1()
    {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Contract con = [Select id,vlocity_cmt__QuoteId__c from Contract where name ='Test'];
        TeliaSE_UpdateContract_TUPP obj = new TeliaSE_UpdateContract_TUPP();
        obj.invokeMethod('changeAgreementCase',inputMap,outMap,options);
        obj.invokeMethod('callOffSubmit',inputMap,outMap,options);
        obj.invokeMethod('callOffSubmit1',inputMap,outMap,options);
        obj.invokeMethod('RegisterCase',inputMap,outMap,options);
    }
    
    @isTest
    public static void testTUPPIntegration2()
    {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Contract con = [Select id,vlocity_cmt__QuoteId__c from Contract where name ='Test'];
        con.CustomerSignedDate = date.today();
        con.TeliaSE_Start_Date__c = date.today();
        update con;
        TeliaSE_UpdateContract_TUPP.sendEmail('abc.def@xyz.com',con.Id);
    }

    
    //Snow Agreement API Calling
    @isTest
    public static void testTUPPIntegration3()
    {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Contract con = [Select id,vlocity_cmt__QuoteId__c from Contract where name ='Test'];
        TeliaSE_TUPPIntegrationHandler.callDeleteAgreementDetailsSnow(con.Id);
        TeliaSE_TUPPIntegrationHandler.callPostAgreementDetailsSnow(con.id);
        TeliaSE_TUPPIntegrationHandler.callPostAgreementDetailsSpock(con.Id);
        TeliaSE_TUPPIntegrationHandler.callAgreementStateChangeEventSpock(con.Id);
		TeliaSE_TUPPIntegrationHandler.AutoTaskContractSync(con.Id);
    }
    
    
    @isTest
    public static void testTUPPIntegration4()
    {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Contract con = [Select id,vlocity_cmt__QuoteId__c from Contract where name ='Test'];
        List<Utilizer_Contract_Relationship__c> utilList = [Select id,Status__c from Utilizer_Contract_Relationship__c where ContractNumber__c=:con.Id]; 
        Map<String,Object> ResponseMap = new Map<String,object>();
        List<Map<String,Object>> subErrorlist = new List<Map<String,Object>>();
        Map<String,object> subError1 = new Map<String,Object>();
        subError1.put('error_code','NotEmpty');
        subError1.put('message','salesPersonId is Empty');
        subError1.put('rejectedValue',null);
        subError1.put('field','salespersonId');
        subError1.put('object','object');
        subErrorlist.add(subError1);
        ResponseMap.put('subErrors',subErrorlist);
        ResponseMap.put('status','BAD_REQUEST');
        ResponseMap.put('resultDesc','Error in request');
        ResponseMap.put('result','Error');
        Map<String,Object> ipResult = new Map<String,Object>();
        ipResult.put('Response',ResponseMap);
        test.startTest();
        TeliaSE_TUPPIntegrationHandler obj = new TeliaSE_TUPPIntegrationHandler();
        obj.updateContractSetUtilizers('setutilizers',ipResult, con.Id,utilList);
        test.stopTest();  
    }
    
    @isTest
    public static void testTUPPIntegration5()
    {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Contract con = [Select id,vlocity_cmt__QuoteId__c from Contract where name ='Test'];
        List<Utilizer_Contract_Relationship__c> utilList = [Select id,Status__c from Utilizer_Contract_Relationship__c where ContractNumber__c=:con.Id]; 
        Map<String,Object> ResponseMap = new Map<String,object>();
        ResponseMap.put('status','BAD_REQUEST');
        ResponseMap.put('resultDesc','Error in request');
        ResponseMap.put('result','Error');
        Map<String,Object> ipResult = new Map<String,Object>();
        ipResult.put('Response',ResponseMap);
        test.startTest();
        TeliaSE_TUPPIntegrationHandler obj = new TeliaSE_TUPPIntegrationHandler();
        obj.updateContractSetUtilizers('setutilizers',ipResult, con.Id,utilList);
        test.stopTest();  
    }
    
    @isTest
    public static void testTUPPIntegration6()
    {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Contract con = [Select id,vlocity_cmt__QuoteId__c from Contract where name ='Test'];
        List<Utilizer_Contract_Relationship__c> utilList = [Select id,Status__c from Utilizer_Contract_Relationship__c where ContractNumber__c=:con.Id]; 
        Map<String,Object> ResponseMap = new Map<String,object>();
        ResponseMap.put('status','Good_Request');
        ResponseMap.put('resultDesc','Error in request');
        ResponseMap.put('result','Ok');
        ResponseMap.put('caseId','12345');
        Map<String,Object> ipResult = new Map<String,Object>();
        ipResult.put('Response',ResponseMap);
        test.startTest();
        TeliaSE_TUPPIntegrationHandler obj = new TeliaSE_TUPPIntegrationHandler();
        obj.updateContractSetUtilizers('setutilizers',ipResult, con.Id,utilList);
		TeliaSE_TUPPIntegrationHandler.callPostAgreementDetailsSiebel(con.Id);
        TeliaSE_TUPPIntegrationHandler.AutoTaskContractSync(con.Id);
        test.stopTest();  
    }
}