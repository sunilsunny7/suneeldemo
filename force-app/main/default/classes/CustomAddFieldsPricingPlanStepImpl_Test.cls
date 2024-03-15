/* Author: Abhinav Gupta on 17.04.2021
Description:This is the Test class for CustomAddFieldsPricingPlanStepImpl*/

@isTest
public with sharing class CustomAddFieldsPricingPlanStepImpl_Test 
{
    @testSetup static void setup(){
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        System.runAs(Test_DataFactory.getByPassUser())
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
            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.ProductCode = 'MOB_SURF_BAS_V2';
            insert prod;
            pricebookId = stdPriceBookRecId;

            
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
            qut.TeliaSE_Type__c='Renegotiation';
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;        
            qut.TeliaSE_MC_Sales_Flow_Identifier__c='Omforhandling';
            insert qut;
            
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.PricebookEntryId = objpricebookentry.Id;
            oli3.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli3.QuoteId = qut.id;
            oli3.UnitPrice = 200;
            oli3.Quantity = 4;
            oli3.Product2Id = prod.id;
            oli3.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli3.TeliaSE_Approved__c = null;
            oli3.vlocity_cmt__RecurringCharge__c  = 200;
            oli3.TeliaSE_Ceiling_Price__c = 400;
            oli3.TeliaSE_Root_Product__c=prod.id;
            oli3.vlocity_cmt__LineNumber__c = '001.002';
            insert oli3;
        }    
    }
    @isTest
    public static void testmethod1()
    {
        Quote qut = [Select id from quote where Name= 'Test Quote' Limit 1];
        String qliQuery=queryBuilder('QuoteLineItem');
        qliQuery+=' FROM QuoteLineItem WHERE '+'quoteid=\'' + String.escapeSingleQuotes((String)qut.Id)+'\'' ;
        list<QuoteLineItem> itemsData =  Database.query(qliQuery);                
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList',itemsData);
        Map<String,Object> inputMap = new Map<String,Object>(); 
        CustomAddFieldsPricingPlanStepImpl capl = new CustomAddFieldsPricingPlanStepImpl();
        Boolean flag = capl.invokeMethod('QueryCustomFieldValues',inputMap,inputMap,inputMap);
    }
    
    @isTest
    public static void testmethod2()
    {
        List<Quote> qut = [Select id from quote where Name= 'Test Quote'];             
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList',qut);
        Map<String,Object> inputMap = new Map<String,Object>(); 
        CustomAddFieldsPricingPlanStepImpl capl = new CustomAddFieldsPricingPlanStepImpl();
        Boolean flag = capl.invokeMethod('QueryCustomFieldValues',inputMap,inputMap,inputMap);
        flag = capl.invokeMethod('QueryCustomFieldValues1',inputMap,inputMap,inputMap);
    }
    
    @isTest
    public static void testmethod3()
    {
        Map<String,Object> inputMap = new Map<String,Object>(); 
        CustomAddFieldsPricingPlanStepImpl capl = new CustomAddFieldsPricingPlanStepImpl();
        Boolean flag = capl.invokeMethod('QueryCustomFieldValues',inputMap,inputMap,inputMap);
    }
    
    @isTest
    public static void testMethod4()
    {
        Quote qut = [Select id from quote where Name= 'Test Quote' Limit 1];
        String qliQuery=queryBuilder('QuoteLineItem');
        qliQuery+=' FROM QuoteLineItem WHERE '+'quoteid=\'' + String.escapeSingleQuotes((String)qut.Id)+'\'' ;
        list<QuoteLineItem> itemsData =  Database.query(qliQuery);
        if(itemsData != null && itemsData.size()>0)
        {
            QuoteLineItem qli = itemsData[0];
            Set<Id> newSet = new Set<Id>();
            newSet.add(qli.id);
            vlocity_cmt.FlowStaticMap.flowMap.put('MC_Sales_AdjustmentID_Filter',newSet);
        }            
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList',itemsData);
        Map<String,Object> inputMap = new Map<String,Object>(); 
        CustomAddFieldsPricingPlanStepImpl capl = new CustomAddFieldsPricingPlanStepImpl();
        Boolean flag = capl.invokeMethod('FilterLineItems',inputMap,inputMap,inputMap);
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