/*-----------------------------------------------------------------------------------------------------------
**Name        :        UpdateRoamingPricePlanIdBatchJob 
**Created By  :        Abhishek Agrawal
**Date      :          14 January 2022
**User Story  :        MCSTO- 9496 - R_22.2
**Description :        Contains Apex Migration of priceplans for Roaming

-----------------------------------------------------------------------------------------------------------*/
global class UpdateRoamingPricePlanIdBatchJob implements Database.Batchable<sObject>{
      global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([select id, vlocity_cmt__Product2Id__r.name, vlocity_cmt__Product2Id__r.ProductCode, TeliaSE_Root_Product__r.ProductCode, vlocity_cmt__RootItemId__c, vlocity_cmt__Product2Id__r.TeliaSE_Product_Category__c, TeliaSE_Product_Object_Type__c, MC_Sales_FrameworkPricingMaster__c,TeliaSE_CommitmentPeriod__c,RoamingResAddOns__c,RoamingTillAddOns__c,TeliaSE_Base_Quantity__c,MC_CommercialTermsQli__c,Quote.status,Quote.MC_Commercial_Setup__c,TeliaSE_Flag__c,MC_Approver__c from quotelineitem where vlocity_cmt__Product2Id__r.ProductCode like 'MOB_CALL_TRAVEL%'
         AND vlocity_cmt__Product2Id__r.Family <> 'Online Order' and Quote_Status__c <>'Cancelled' and TeliaSE_Quote_RecordType__c='Contract' and MC_Sales_FrameworkPricingMaster__c=null and (RoamingResAddOns__c!=null or RoamingTillAddOns__c!=null) and TeliaSE_Root_Product__r.productcode IN ('MOB_MULTI_TOTAL_V2','MOB_MULTI_TOTAL_V3','MOB_MULTI_ALL_IN_PLUS_V2', 'MOB_MULTI_ALL_IN_PLUS_V3')  and TeliaSE_Base_Quantity__c >'0']);
    }
    global void execute(Database.BatchableContext bc,List<quotelineitem> roamingQliList){
        try{
              MC_PricePlanIdAndAttributeMigrate.roamingPricePlanMigration(roamingQliList);
        }catch(Exception e){
            system.debug('Exception -- >'+ e);
        }
        
    }
    global void finish(Database.BatchableContext bc){
        
         System.debug('Excecuted-');
    }

}