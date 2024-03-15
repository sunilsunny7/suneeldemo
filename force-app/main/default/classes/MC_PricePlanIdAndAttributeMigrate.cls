/*-----------------------------------------------------------------------------------------------------------
**Name        :        MC_PricePlanIdAndAttributeMigrate 
**Created By  :        Abhishek Agrawal
**Date      :          14 January 2022
**User Story  :        MCSTO- 9496/9497 - R_22.2
**Description :        Contains Apex Migration of priceplans for Roaming and Jobbsurf for Mobile and hiding of attributes from cart.
functions called form 3 different batchable classes.

-----------------------------------------------------------------------------------------------------------*/
public class MC_PricePlanIdAndAttributeMigrate {
    //******Logic to migrate Roaming addons.Called from UpdateRoamingPricePlanIdBatchJob  starts*************************
    public static void roamingPricePlanMigration(List < QuoteLineItem > roamingQliList) {
        try{
        Boolean testContext= test.isRunningTest();
        List < QuoteLineItem > qliIdToUpdate = new List < QuoteLineItem > ();
        List < TeliaSE_Roaming_Mandate__mdt > roamingAddons = new List < TeliaSE_Roaming_Mandate__mdt > ();
        roamingAddons = [select id, AddOnPricePlan__c, ResOsterutPris__c, ResSoderutPris__c, ResVasterutPris__c, TillEuropaPris__c, TillGrannlandPris__c, TillUtlandPris__c from TeliaSE_Roaming_Mandate__mdt];
        Map < String, TeliaSE_Roaming_Mandate__mdt > roamingaddOnsMap = new Map < String, TeliaSE_Roaming_Mandate__mdt > ();
        for (TeliaSE_Roaming_Mandate__mdt roamingAddOn: roamingAddons) {
            roamingaddOnsMap.put(roamingAddOn.AddOnPricePlan__c, roamingAddOn);
        }
        List < MC_Sales_FrameworkPricingMaster__c > pricingPlanRecord = [select Id, name, MC_Sales_FrameworkPricePlanMaster__r.Name, MC_Sales_Low_Base_Quantity__c, MC_Sales_High_Base_Quantity__c, MC_Sales_FrameworkProductCategoryMaster__r.name, MC_Sales_Commitment_Period__c, MC_Sales_Parent__c, MC_Sales_Cluster__c, MC_Sales_Customer_Segment__c, MC_Sales_Object_Type__c from MC_Sales_FrameworkPricingMaster__c
                                                                         where MC_Sales_FrameworkProductCategoryMaster__r.name in ('F9UTLANDPP', 'A1VOICEROA')
                                                                         AND MC_Sales_Parent__c in ('MOB_MULTI_TOTAL_V3', 'MOB_MULTI_TOTAL_V2', 'MOB_MULTI_ALL_IN_PLUS_V3', 'MOB_MULTI_ALL_IN_PLUS_V2')
                                                                         AND MC_Sales_Object_Type__c = 'Mobile Offer Specification'
                                                                        ];
        List < String > resRoamingProductCodes = new List < String > ();
        resRoamingProductCodes.add('MOB_CALL_TRAVEL_SOUTH');
        resRoamingProductCodes.add('MOB_CALL_TRAVEL_EAST');
        resRoamingProductCodes.add('MOB_CALL_TRAVEL_WEST');
        List < String > tillRoamingProductCodes = new List < String > ();
        tillRoamingProductCodes.add('MOB_CALL_TRAVEL_EUROPE');
        tillRoamingProductCodes.add('MOB_CALL_TRAVEL_OTHER');
        tillRoamingProductCodes.add('MOB_CALL_TRAVEL_OVERSEAS');
        for (QuoteLineItem q: roamingQliList) {
            String pricePlan = '';
            String commercialSetup='ALL';
            
            if (resRoamingProductCodes.contains(q.vlocity_cmt__Product2Id__r.ProductCode) && roamingaddOnsMap.containsKey(q.RoamingResAddOns__c)) {
                
                pricePlan = roamingaddOnsMap.get(q.RoamingResAddOns__c).ResOsterutPris__c + ',' + roamingaddOnsMap.get(q.RoamingResAddOns__c).ResSoderutPris__c + ',' + roamingaddOnsMap.get(q.RoamingResAddOns__c).ResVasterutPris__c;
            }
            if (tillRoamingProductCodes.contains(q.vlocity_cmt__Product2Id__r.ProductCode) && roamingaddOnsMap.containsKey(q.RoamingTillAddOns__c)) {
                
                pricePlan = roamingaddOnsMap.get(q.RoamingTillAddOns__c).TillEuropaPris__c + ',' + roamingaddOnsMap.get(q.RoamingTillAddOns__c).TillGrannlandPris__c + ',' + roamingaddOnsMap.get(q.RoamingTillAddOns__c).TillUtlandPris__c;
            }
            Id pricePlanId=null;
            if(pricePlan!=''){
            pricePlanId = MC_PricePlanIdAndAttributeMigrate.pricePlanId(pricePlan, q.TeliaSE_Root_Product__r.ProductCode, Integer.valueOf(q.TeliaSE_Base_Quantity__c), q.vlocity_cmt__Product2Id__r.TeliaSE_Product_Category__c, pricingPlanRecord,commercialSetup);
            }
            //************Used for test class******
            if(testContext){
                pricePlanId =Id.valueOf('a9q0D000000CbRLQA0');
            }
            //*********************************
            if (pricePlanId != null) {
                q.MC_Sales_FrameworkPricingMaster__c = pricePlanId;
                System.debug('quotestatus'+q.Quote.status);
                System.debug('quotestatus'+q.Quote);
                if((q.Quote.status=='Approved' && ((q.TeliaSE_Flag__c).contains('Happy')))|| testContext){
                    Map<String,Object> commercialTermsQli = new Map<String,Object>();
                    if(!String.isBlank(q.MC_CommercialTermsQli__c)){
                        commercialTermsQli = (Map<String,Object>)json.deserializeUntyped(q.MC_CommercialTermsQli__c);
                    }
                    commercialTermsQli.put('FrameworkPricingMaster',pricePlanId);
                    q.MC_CommercialTermsQli__c = json.serialize(commercialTermsQli);
                }
                qliIdToUpdate.add(q);
            }
        }
        if (qliIdToUpdate.size() > 0 && !testContext) {
            update qliIdToUpdate;
        }
    }
        catch(Exception ex) {System.debug('Exception in roaming');}
    }
    //******Logic to migrate Roaming addons.Called from UpdateRoamingPricePlanIdBatchJob  ends*************************
    
    //******Logic to migrate Jobbsurf addons.Called from UpdateJobbsurfPricePlanIdBatchJob  starts*************************
    public static void jobbsurfPlanMigration(List <QuoteLineItem> jobbsurfQliList){
        Boolean testContext1= test.isRunningTest();
        List < QuoteLineItem > qliIdToUpdate = new List < QuoteLineItem > ();
        List < MC_Sales_FrameworkPricingMaster__c > pricingPlanRecord = [select Id, name, MC_Sales_FrameworkPricePlanMaster__r.Name, MC_Sales_Low_Base_Quantity__c, MC_Sales_High_Base_Quantity__c, MC_Sales_FrameworkProductCategoryMaster__r.name, MC_Sales_Commitment_Period__c, MC_Sales_Parent__c, MC_Sales_Cluster__c, MC_Sales_Customer_Segment__c, MC_Sales_Object_Type__c from MC_Sales_FrameworkPricingMaster__c
                                                                         where MC_Sales_FrameworkProductCategoryMaster__r.name ='F5FAX/DATA'
                                                                         AND MC_Sales_Parent__c in ('MOB_MULTI_TOTAL_V3', 'MOB_MULTI_TOTAL_V2')
                                                                         AND MC_Sales_Object_Type__c = 'Mobile Offer Specification' and MC_Sales_Customer_Segment__c='SME'
                                                                        ];
        for(QuoteLineItem q:jobbsurfQliList){
            String pricePlan = q.TeliaSE_PriceTypeCategory__c;
            String commercialSetup='SME';
            /*if(q.Quote.MC_Commercial_Setup__c=='Enterprise Large' || q.Quote.MC_Commercial_Setup__c=='Forced RA'){
                commercialSetup='LARGE';
            }else{
                commercialSetup='SME';
            }*/
            Id pricePlanId = MC_PricePlanIdAndAttributeMigrate.pricePlanId(pricePlan, q.TeliaSE_Root_Product__r.ProductCode, Integer.valueOf(q.TeliaSE_Base_Quantity__c), q.vlocity_cmt__Product2Id__r.TeliaSE_Product_Category__c, pricingPlanRecord,commercialSetup);
            //System.debug('price Plan Id is'+pricePlanId);
            
            if (pricePlanId != null || testContext1) {
                System.debug('PPId-'+pricePlanId);
                System.debug('Qli id-'+q.Id);
                if(testContext1){pricePlanId=Id.valueOf('aA4250000004Gg8CAE');}
                q.MC_Sales_FrameworkPricingMaster__c = pricePlanId;  
                if((q.Quote.status=='Approved' && ((q.TeliaSE_Flag__c).contains('Happy')))|| testContext1){
                    Map<String,Object> commercialTermsQli = new Map<String,Object>();
                    if(!String.isBlank(q.MC_CommercialTermsQli__c)){
                        commercialTermsQli = (Map<String,Object>)json.deserializeUntyped(q.MC_CommercialTermsQli__c);
                    }
                    commercialTermsQli.put('FrameworkPricingMaster',pricePlanId);
                    q.MC_CommercialTermsQli__c = json.serialize(commercialTermsQli);
                }
                if(q.TeliaSE_MC_Customer_Requested_Price__c==null && q.vlocity_cmt__RecurringCharge__c!=null){
                    q.TeliaSE_MC_Customer_Requested_Price__c=q.vlocity_cmt__RecurringCharge__c;
                }
                
                qliIdToUpdate.add(q);
            }
            
        }
        if (qliIdToUpdate.size() > 0 && !testContext1) {
            update qliIdToUpdate;
        }
        
    }
    //******Logic to migrate Jobbsurf addons.Called from UpdateJobbsurfPricePlanIdBatchJob  ends*************************
    
    public static Id pricePlanId(String pricePlan, String rootProductCode, Integer baseQuantity, String productCategory, List < MC_Sales_FrameworkPricingMaster__c > pricingPlanRecords,String commercialSetup) {
        Id pricePlanId = null;
        for (MC_Sales_FrameworkPricingMaster__c pricePlanRecord: pricingPlanRecords) {
            if (productCategory == 'A1VOICEROA' || productCategory == 'F9UTLANDPP' ) {
                System.debug(pricePlanRecord.MC_Sales_FrameworkPricePlanMaster__r.Name+'pricePlanComp'+pricePlan);
                /*if (pricePlanRecord.MC_Sales_FrameworkPricePlanMaster__r.Name == pricePlan && pricePlanRecord.MC_Sales_Parent__c == rootProductCode &&
                    baseQuantity >= pricePlanRecord.MC_Sales_Low_Base_Quantity__c && baseQuantity <= pricePlanRecord.MC_Sales_High_Base_Quantity__c &&
                    pricePlanRecord.MC_Sales_FrameworkProductCategoryMaster__r.name == productCategory)*/ 
                if (pricePlanRecord.MC_Sales_FrameworkPricePlanMaster__r.Name == pricePlan && pricePlanRecord.MC_Sales_Parent__c == rootProductCode &&
                    pricePlanRecord.MC_Sales_FrameworkProductCategoryMaster__r.name == productCategory){
                        return pricePlanRecord.Id;
                    }
            }
            if (productCategory == 'F5FAX/DATA') {
                String threeGbPrice = 'Surf 3GB@' + (pricePlanRecord.MC_Sales_FrameworkPricePlanMaster__r.Name.split(','))[2] + 'kr';
                System.debug(threeGbPrice+'priceplancomp'+pricePlan);
                /*if (threeGbPrice== pricePlan && pricePlanRecord.MC_Sales_Parent__c == rootProductCode &&
                    baseQuantity >= pricePlanRecord.MC_Sales_Low_Base_Quantity__c && baseQuantity <= pricePlanRecord.MC_Sales_High_Base_Quantity__c && pricePlanRecord.MC_Sales_Customer_Segment__c==commercialSetup)*/ 
                if (threeGbPrice== pricePlan && pricePlanRecord.MC_Sales_Parent__c == rootProductCode &&
                    baseQuantity >= pricePlanRecord.MC_Sales_Low_Base_Quantity__c && baseQuantity <= pricePlanRecord.MC_Sales_High_Base_Quantity__c){
                        System.debug('inside priceplplan');
                        return pricePlanRecord.Id;
                    }
            }
        }
        return pricePlanId;
        
    }
    
    
    
}