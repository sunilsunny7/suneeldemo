@isTest
public class TeliaSE_DraftContract_Test 
{
     @testSetup static void setup()
    {
   		User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();

       
        System.runAs(new User(Id = Userinfo.getUserId()))
        {
        	salesManager = Test_DataFactory.createAdminUser();
        	salesManager.Bypass_VR__c = true;
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
        insert opp;
            
         
        Product2 prod = Test_DataFactory.createProduct('Jobbmobil Add-In Plus');
        insert prod;
        String prodID = prod.id;
        prod.ProductCode = 'MOB_MULTI_ALL_IN_PLUS';
        upsert prod;
            
		Product2 prod1 = Test_DataFactory.createProduct('Jobbmobil Total');
        insert prod1;
        String prodID1 = prod.id;
        prod.ProductCode = 'MOB_MULTI_Total';
        upsert prod1;
            
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
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;
				
            insert contract;  
            
            
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
      
        //Setup Custom field to test the deletion of products from CLI with the same productID as in custom setting.
        List<TeliaSE_PortfolioIdentifiers__c> oldProducts = new List<TeliaSE_PortfolioIdentifiers__c>();
        TeliaSE_PortfolioIdentifiers__c OPFeilds=new TeliaSE_PortfolioIdentifiers__c(); //Custom Setting for Contact Fields
			OPFeilds.Add__c=True;
            OPFeilds.Name = 'MOB_MULTI_ALL_IN_PLUS';
            OPFeilds.ProductId__c = prodID;
			oldProducts.add(OPFeilds);
            
         TeliaSE_PortfolioIdentifiers__c OPFeilds1=new TeliaSE_PortfolioIdentifiers__c(); //Custom Setting for Contact Fields
			OPFeilds1.Add__c=True;
            OPFeilds1.Name = 'MOB_MULTI_Total';
            OPFeilds1.ProductId__c = prodID1;
			oldProducts.add(OPFeilds1);
            
            
          insert oldProducts;
            
            
        }

	}
    
     @isTest
    public static void test()
    {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Map<String,Object> quoteMap=new Map<String,Object>();
    
     	Quote quote=[select id,TeliaSE_Record_Type_Name__c,TeliaSE_MC_Sales_Flow_Identifier__c from Quote where name='Test Version1' limit 1];
        Contract con=[select id from Contract limit 1];
        Opportunity opp=[select id from Opportunity limit 1];
        QuoteLineItem item=[select id from QuoteLineItem limit 1];    
        Product2 prod=[select id from Product2 limit 1];
        inputMap.put('TeliaSE_MC_Sales_Flow_Identifier__c',quote.TeliaSE_MC_SALES_FLOW_IDENTIFIER__C);
        inputMap.put('ContextId',opp.id); 
        inputMap.put('QuoteId',quote.id); 
        inputMap.put('ContractId',con.id); 
        inputMap.put('Type',quote.TeliaSE_Record_Type_Name__c);
        inputMap.put('MCSalesFlowIdentifierNq',quote.TeliaSE_MC_Sales_Flow_Identifier__c);
        
        Quote q= [Select id,name,TeliaSE_Record_Type_Name__c from Quote where id=:quote.id];
        System.debug('quote details'+q);
        
        TeliaSE_DraftContract obj=new TeliaSE_DraftContract();
        obj.invokeMethod('deleteOldPortfolio',inputMap,outMap,options);
        List<QuotelineItem> obj1 = [Select id from quotelineitem LIMIT 2];
        TeliaSE_DraftContract.deleteQuoteLineItems(obj1);
        
        System.debug('inputmap test'+inputMap);

    }    
    
}