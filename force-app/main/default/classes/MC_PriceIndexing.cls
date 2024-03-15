global class MC_PriceIndexing {
    @AuraEnabled
    public static List<vlocity_cmt__ContractLineItem__c> getPriceIndexingInfo(String contractId){
    
        List<vlocity_cmt__ContractLineItem__c> response2 = new List<vlocity_cmt__ContractLineItem__c>();
        try{
            String extractPricingInfo = 'Select id, MC_IndexationCriteria__r.MC_CurrentBaseValue__c, vlocity_cmt__Product2Id__r.Name, MC_IndexedDate__c, TOLABEL(MC_PriceUpdateType__c) from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c =:contractId AND TeliaSE_ParentItemId__c  = Null And MC_PriceUpdateType__c != Null ORDER BY MC_IndexedDate__c DESC NULLS LAST';
            response2 =  Database.query(extractPricingInfo);            
        }catch(Exception exp){         
            System.debug(exp.getStackTraceString());
            System.debug(exp.getLineNumber());
            System.debug(exp.getMessage());
        }
        
        return response2;
    }
}