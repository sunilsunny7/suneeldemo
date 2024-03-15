/*
Created by P.S on Sep-2020
----
SALEF-3605 -  To Customize Fiber quote approval request page.
*/
public without sharing class FiberProcessInstanceCustomController {
    @AuraEnabled
    public static  List <Wrapper> getQuoteLineItem(Id ProcessInstanceStepId) {
     List<QuoteLineItem> qliList;
     system.debug('ProcessInstanceStepId' +ProcessInstanceStepId);
     
     List <ProcessInstanceworkitem> prInsList = [SELECT Id, ProcessInstanceId FROM ProcessInstanceworkitem where id=:ProcessInstanceStepId];
      system.debug('****prInsList ' +prInsList);
     //Wrapper wr = new Wrapper();
     List <Wrapper > wpr = new List <Wrapper >();
      if(prInsList != null && prInsList.size()>0) {
            
            ProcessInstanceworkitem ProcessInstanceStepObj = (ProcessInstanceworkitem)prInsList.get(0);
            ProcessInstance ProcessInstanceObj = [SELECT Id, Status, TargetObjectId FROM ProcessInstance where id=:ProcessInstanceStepObj.ProcessInstanceId];
            qliList = [select id, vlocity_cmt__RecurringCharge__c,Product2.name,TeliaSE_fiber_Rabatt__c,Fiber_Customer_Requested_Price__c,TeliaSE_Product_Object_Type__c,QuoteId,vlocity_cmt__ParentItemId__c,Quantity,vlocity_cmt__OneTimeCharge__c from QuoteLineItem where QuoteId  =:ProcessInstanceObj.TargetObjectId];
             System.debug('*****qliList:'+qliList);
            for(QuoteLineItem qli: qliList){
            // if(qli.TeliaSE_fiber_Rabatt__c != null && qli.TeliaSE_fiber_Rabatt__c > 10)
             //{
              Wrapper wr = new Wrapper();
               wr.ProductName = qli.Product2.name;
               wr.Quantity = qli.Quantity;
               wr.OneTimeCharge = qli.vlocity_cmt__OneTimeCharge__c; 
               wr.RecurringCharge = ''+qli.vlocity_cmt__RecurringCharge__c;
                
               if (qli.Fiber_Customer_Requested_Price__c == null)
               {
                    wr.CustomerRequestedPrice = '';
               }else
               {
                   wr.CustomerRequestedPrice = ''+qli.Fiber_Customer_Requested_Price__c;
               }
               if (qli.TeliaSE_fiber_Rabatt__c == null)
               {
                    wr.FiberRabatt = '';
               }
               else
               {
                    wr.FiberRabatt = ''+qli.TeliaSE_fiber_Rabatt__c;
               }
               System.debug('*****QLI:'+qli.id);
               wpr.add(wr);
             //}
            }
            
           }
            System.debug('*****wpr :'+wpr);
           return wpr;
          
      }
      @AuraEnabled
       public static  List <Wrapper> getQuoteEbit(Id ProcessInstanceStepId) {
     Quote q;
     system.debug('ProcessInstanceStepId' +ProcessInstanceStepId);
     
     List <ProcessInstanceworkitem> prInsList = [SELECT Id, ProcessInstanceId FROM ProcessInstanceworkitem where id=:ProcessInstanceStepId];
      system.debug('****prInsList ' +prInsList);
     //Wrapper wr = new Wrapper();
     List <Wrapper > wpr = new List <Wrapper >();
      if(prInsList != null && prInsList.size()>0) {
            
            ProcessInstanceworkitem ProcessInstanceStepObj = (ProcessInstanceworkitem)prInsList.get(0);
            ProcessInstance ProcessInstanceObj = [SELECT Id, Status, TargetObjectId FROM ProcessInstance where id=:ProcessInstanceStepObj.ProcessInstanceId];
            q = [select id, TeliaSE_Fiber_EBIT_Percentage__c,TeliaSE_Fiber_Revenues__c,TeliaSE_Fiber_OPEX__c,TeliaSE_Fiber_Capex_Infra__c,TeliaSE_Fiber_Contract_Term_Y__c,TeliaSE_Fiber_Payback_Y__c,Account.Name, TeliaSE_Fiber_Total_Recurring_Charges__c, vlocity_cmt__EffectiveOneTimeTotal__c,TeliaSE_Fiber_Number_of_Households__c,TeliaSE_3Play_Pris_exkl_moms__c,Fiber_Total_MRC_HouseHold__c from Quote where Id  =:ProcessInstanceObj.TargetObjectId  limit 1];
            
               Wrapper wr = new Wrapper();
               wr.Fiber_EBIT_Percentage = ''+q.TeliaSE_Fiber_EBIT_Percentage__c;
               wr.Fiber_Revenues = ''+q.TeliaSE_Fiber_Revenues__c;
               wr.Fiber_OPEX = ''+q.TeliaSE_Fiber_OPEX__c;
               wr.Fiber_Capex_Infra = ''+q.TeliaSE_Fiber_Capex_Infra__c;
               wr.Fiber_Contract_Term_Y = ''+q.TeliaSE_Fiber_Contract_Term_Y__c;
               wr.Fiber_Payback_Y = ''+q.TeliaSE_Fiber_Payback_Y__c;
               wr.Fiber_RecurringTotal = ''+q.TeliaSE_Fiber_Total_Recurring_Charges__c;
               wr.Fiber_OneTimeTotal   = ''+q.vlocity_cmt__EffectiveOneTimeTotal__c;
               wr.Play_Pris_exkl_moms   = ''+q.TeliaSE_3Play_Pris_exkl_moms__c;
                                    
               if (q.Fiber_Total_MRC_HouseHold__c == null)
               {
                   wr.Fiber_Number_of_Households   = '0.00';
               }else
               {
                   wr.Fiber_Number_of_Households   = ''+q.Fiber_Total_MRC_HouseHold__c;
               }
               wpr.add(wr);
             }
            System.debug('*****wpr :'+wpr);
           return wpr;
          
      }
    public with sharing class  Wrapper{
        @AuraEnabled
        Public String ProductName{get; set;}
        
        @AuraEnabled
        Public Decimal Quantity {get; set;}
        
        @AuraEnabled
        Public Decimal OneTimeCharge {get; set;}
                
        @AuraEnabled
        Public String RecurringCharge {get; set;}
        
        @AuraEnabled
        Public String CustomerRequestedPrice {get; set;}
        
        @AuraEnabled
        Public String FiberRabatt {get; set;}
        
        @AuraEnabled
        Public String Fiber_EBIT_Percentage{get; set;}
        
        @AuraEnabled
        Public String Fiber_Revenues{get; set;}
        
        @AuraEnabled
        Public String Fiber_OPEX{get; set;}
        
        @AuraEnabled
        Public String Fiber_Capex_Infra{get; set;}
        
        @AuraEnabled
        Public String Fiber_Contract_Term_Y{get; set;}
        
        @AuraEnabled
        Public String Fiber_Payback_Y{get; set;}
               
        @AuraEnabled
        Public String Fiber_RecurringTotal{get; set;}
        
        @AuraEnabled
        Public String Fiber_OneTimeTotal{get; set;}
        
        @AuraEnabled
        Public String Play_Pris_exkl_moms{get; set;}
        
        @AuraEnabled
        Public String Fiber_Number_of_Households{get; set;}
    }
   
}