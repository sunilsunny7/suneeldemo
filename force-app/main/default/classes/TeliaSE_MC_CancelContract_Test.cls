@isTest
public class TeliaSE_MC_CancelContract_Test 
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
            prod.ProductCode='C-OFFICE_365';
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
            contract.Status = 'Active';
            update contract;
            
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
            portfolio2.OldProductCode__c = 'C-OFFICE_365';
            portfolio2.NewProductCode__c = 'C-OFFICE_365';
            insert portfolio2; 
            
            Test.stopTest();   
        }
    }
    
    @isTest
    public static void testCreateSA()
    {
        List<Contract> conList = [Select id,AccountId, Account.FA_Contract__c from contract where status = 'Active'];
        Contract cont = conList[0];
        system.debug('List:' + conList);
        Account Acc = new Account();
        acc.id = cont.AccountId;
        acc.FA_Contract__c = cont.id;
        update acc;
        List<Id> newList = new List<Id>();
        for(Contract con: conList)
        {
            newList.add(con.id);
        }
        TeliaSE_MC_CancelContract.cancelContract(newList);
    }
    
}