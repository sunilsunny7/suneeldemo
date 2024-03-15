@isTest
public class Test_PriceMatrixAPICall {
    testMethod public static void test(){
        //calling a mock class which contains an http response
        //Test.setMock(HttpCalloutMock.class, new PriceMatrixAPICallMock());
        //PriceMatrixAPICall.callService('');
 
        PricematrixRanges__c range = new PricematrixRanges__c();
        range.High__c = 399;
        range.Low__c = 375;
        range.Name = '375-399';
        insert range;
        
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
            objClass.Name = 'Mobile Handset Product Specification';    
            objClass.vlocity_cmt__IsActive__c = True;
            objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
            insert objClass;
            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;
            insert prod;
                   
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
            oli1.Product2Id = prod.Id;
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.UnitPrice = 0;
            oli1.Quantity = 1;
            insert oli1;
        
            
        String JsonResponse = '{'+
		'  \"QLI\": ['+
		'    {'+
		'      \"procedureName\": \"Hardware_24M_RangeAttributePricingProcedure\",'+
		'      \"ProductCode\": \"9098690\",'+
		'      \"ProdName\": \"Apple iPhone 11 64GB Gul\",'+
		'      \"Memory\": \"64GB\",'+
		'      \"Id\": \"'+oli1.Id+'\",'+
		'      \"EFSPris\": \"375\",'+
		'      \"Color\": \"Yellow\",'+
        '      \"SAPID\": \"9098690\",'+
        '      \"Quantity\": \"2\",'+
		'      \"Brand\": \"Apple\"'+
		'    }'+
		'   '+
		'  ]'+
		'}';
        String jsonResponse1 = '{"9098690375-399": { "OTC": 0,"RTC": 40}}';
        Map<String,Decimal> prices = new Map<String,Decimal>();
        prices.put('recurringCharge', 1234);
        prices.put('oneTimeCharge', 399);
        Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
        Map<String, Object> outMap = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse1);
        
     //  PriceMatrixAPICall.UpdateQuoteprices(inputMap,outMap,prices);
        PriceMatrixAPICall pcall = new PriceMatrixAPICall();
        pcall.invokeMethod('updatePrices',inputMap,outMap,outMap);
        pcall.invokeMethod('',inputMap,outMap,outMap);    
        }
    }
}