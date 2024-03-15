/*-----------------------------------------------------------------------------------------------------------
**Name        :        UpdateJobbsurfPricePlanIdBatchJob 
**Created By  :        Abhishek Agrawal
**Date      :          14 January 2022
**User Story  :        MCSTO- 9496 - R_22.2
**Description :        Contains Apex Migration of priceplans for Jobbsurf

-----------------------------------------------------------------------------------------------------------*/
global class UpdateJobbsurfPricePlanIdBatchJob implements Database.Batchable<sObject>{
      global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([select id,MC_Sales_FrameworkPricingMaster__c,vlocity_cmt__Product2Id__r.name, vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__Product2Id__r.TeliaSE_Product_Category__c,TeliaSE_PriceTypeCategory__c,TeliaSE_Root_Product__r.ProductCode,TeliaSE_Base_Quantity__c, MC_CommercialTermsQli__c,Quote.status,Quote.MC_Commercial_Setup__c,TeliaSE_Flag__c,MC_Approver__c,TeliaSE_MC_Customer_Requested_Price__c,vlocity_cmt__RecurringCharge__c from quotelineitem where  vlocity_cmt__Product2Id__r.family <> 'Online Order'
               and vlocity_cmt__Product2Id__r.ProductCode like 'MOB_SURF_%_V2' and TeliaSE_PriceTypeCategory__c<>null and Quote.Status<>'Cancelled' and TeliaSE_Quote_RecordType__c='Contract' and MC_Sales_FrameworkPricingMaster__c=null and TeliaSE_Root_Product__r.productcode IN ('MOB_MULTI_TOTAL_V2','MOB_MULTI_TOTAL_V3') and TeliaSE_Base_Quantity__c >'0']);
    }
    global void execute(Database.BatchableContext bc,List<quotelineitem> jobbsurfQliList){
        try{
              MC_PricePlanIdAndAttributeMigrate.jobbsurfPlanMigration(jobbsurfQliList);
        }catch(Exception e){
            system.debug('Exception -- >'+ e);
        }
      
    }
    global void finish(Database.BatchableContext bc){
        
         System.debug('Excecuted-');
    }

}