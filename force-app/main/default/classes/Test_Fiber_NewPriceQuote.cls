@isTest
public with sharing class Test_Fiber_NewPriceQuote {
    
    @isTest()
    public static void testNewFiberPriceQuote(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;

        System.runAs(salesManager){
        }
        
        
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        outMap.put('Warning','Är du säker på att du vill gå vidare?');
        
        inputMap.put('ContextId', contract.id);
        test.startTest();
        Fiber_NewPriceQuote NewPriceQuoteClass = new Fiber_NewPriceQuote();
        NewPriceQuoteClass.invokeMethod('validateFiberRevisedContract', inputMap, outMap, options);
         test.stopTest();

    }
}