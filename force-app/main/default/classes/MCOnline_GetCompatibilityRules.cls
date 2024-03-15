global class MCOnline_GetCompatibilityRules implements vlocity_cmt.VlocityOpenInterface2{
	global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) 
    {    
        if(methodName.equalsIgnoreCase('getCompatibilityRules'))
        {  
            getCompatibilityRules(inputMap, outMap, options);
        }
        return true;
    }
    
    private static void getCompatibilityRules(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options)
    {
        String ruleType;
        List<Map<String,Object>> rulesOutput = new List<Map<String,Object>>();       
        List<vlocity_cmt__ProductRelationship__c> rules1 = new List<vlocity_cmt__ProductRelationship__c>();       
        if(inputMap != null && inputMap.containsKey('ruleType')){
                ruleType= (string)inputMap.get('ruleType');                
                    if(ruleType.equalsIgnoreCase('All')){
                        rules1 = [SELECT id,vlocity_cmt__family__c,vlocity_cmt__relatedproductid__r.isactive,vlocity_cmt__product2id__r.isactive,vlocity_cmt__maxquantity__c,vlocity_cmt__product2id__r.productcode,vlocity_cmt__relatedproductid__r.productcode,vlocity_cmt__relationshiptype__c FROM vlocity_cmt__ProductRelationship__c WHERE (vlocity_cmt__Family__c = 'Online' AND vlocity_cmt__Product2Id__r.IsActive = true AND vlocity_cmt__RelatedProductId__r.IsActive = true) WITH SECURITY_ENFORCED];                       
                            for(vlocity_cmt__ProductRelationship__c pr:rules1){
                                mapfields(pr,rulesOutput);
                            }
                                outMap.put('rules',rulesOutput);
                            
                        }                    
                    else{
                        List<vlocity_cmt__ProductRelationship__c> rules = [SELECT id,vlocity_cmt__family__c,vlocity_cmt__relatedproductid__r.isactive,vlocity_cmt__product2id__r.isactive,vlocity_cmt__relationshiptype__c,vlocity_cmt__maxquantity__c,vlocity_cmt__product2id__r.productcode,vlocity_cmt__relatedproductid__r.productcode FROM vlocity_cmt__ProductRelationship__c WHERE (vlocity_cmt__Family__c = 'Online' AND vlocity_cmt__Product2Id__r.IsActive = true AND vlocity_cmt__RelatedProductId__r.IsActive = true AND vlocity_cmt__RelationshipType__c =: ruleType) WITH SECURITY_ENFORCED];
                       
                            for(vlocity_cmt__ProductRelationship__c pr:rules){
                                mapfields(pr,rulesOutput);
                             }
                                 outMap.put('rules',rulesOutput);
                            	outMap.put('StatusCode',200);
                        }
        }
    }
    
    private static void mapfields(vlocity_cmt__ProductRelationship__c pr,List<Map<String,Object>> rulesOutput){
        Map<String,Object> rulesAll = new Map<String,Object>();
                                 rulesAll.put('ruleType',pr.vlocity_cmt__RelationshipType__c);
                                 rulesAll.put('relatedProductCode',pr.vlocity_cmt__RelatedProductId__r.ProductCode);
                                 rulesAll.put('productCode',pr.vlocity_cmt__Product2Id__r.ProductCode);
                                 rulesAll.put('maxQuantity',pr.vlocity_cmt__MaxQuantity__c);
                                rulesOutput.add(rulesAll);
    }
}