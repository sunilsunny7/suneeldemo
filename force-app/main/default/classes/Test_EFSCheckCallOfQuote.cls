@isTest
public class Test_EFSCheckCallOfQuote {
	testMethod public static void getSubscriptionsPricestest(){
    	User salesManager;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
                
        vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
        objClass.Name = 'Mobile Offer Specification';    
        objClass.vlocity_cmt__IsActive__c = True;
        objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass;
        	    
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
        prod2.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        insert prod2;
        Product2 prod3 = Test_DataFactory.createProducts(1)[0];
        prod3.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        insert prod3;
        		
		SubscriptionFilter__c sfilter = new SubscriptionFilter__c();
		sfilter.Name = prod.Name;
        insert sfilter;     
       	HardwareController hc = new HardwareController(); 	
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
            
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.QuoteId = qut.Id;
            oli1.Subscription__c = prod1.Name;
            oli1.Product2Id = prod2.Id;
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.UnitPrice = 0;
        	oli1.Quantity = 1;
            insert oli1;
            
            String JsonResponse = '{'+
				'\"ContextId\": \"'+qut.Id+'\",'+
				'\"Subscription\": ['+
				'{'+
				'\"Price\": 345,'+
				'\"Name\": \"'+prod.Name+'\"'+
				'},'+
				'{'+
				'\"Price\": 395,'+
				'\"Name\": \"'+prod1.Name+'\"'+
				'}'+
				'],'+
				'\"EFS\": ['+
				'{'+
				'\"pricePlanFee\": \"30.0\",'+
				'\"Subscriptions\": \"99\"'+
				'},'+
				'{'+
				'\"pricePlanFee\": \"30.0\",'+
				'\"Subscriptions\": \"98\"'+
				'}'+
				']'+
				'}';
        	Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
        	Map<String, Object> outMap = new Map<String, Object>();   
        	EFSCheckCallOfQuote.getSubscriptionsPrices(inputMap,outMap);
            EFSCheckCallOfQuote.updateSubscriptionsPrices(inputMap,outMap);
        }
	}
}