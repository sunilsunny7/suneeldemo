/****************************************************************************************************************************
* @author                 Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @modifiedBy             Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @maintainedBy           Suneel Shivanna
* @version                1.0
* @description            Gets rules from Salesforce database
* @Created                20-03-2023
******************************************************************************************************************************/
global with sharing class MCONL_GetRules implements vlocity_cmt.VlocityOpenInterface2 {
global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
    if(methodName.equalsIgnoreCase('getRules'))
    {
        getRules(inputMap,outMap);
    }
    return true;
}

private static void getRules(Map<String,Object> inputMap, Map<String,Object> outMap){
    String ruleType=String.valueOf(inputMap.get('ruleType'));
    List<vlocity_cmt__ProductRelationship__c> items;
    List<Object> rules= new List<Object>();
    Map<String,Object> item;
    if(ruleType == 'All'){
        items=[SELECT vlocity_cmt__maxquantity__c,vlocity_cmt__product2id__r.productcode,vlocity_cmt__relatedproductid__r.productcode,vlocity_cmt__relationshiptype__c FROM vlocity_cmt__ProductRelationship__c WHERE (Id != null AND vlocity_cmt__Family__c = 'Online' AND vlocity_cmt__Product2Id__r.IsActive = true AND vlocity_cmt__RelatedProductId__r.IsActive = true) WITH SECURITY_ENFORCED];
    }
    else if (ruleType == 'Compatible' || ruleType == 'Recommends' || ruleType == 'Excludes')
    {
        items=[SELECT vlocity_cmt__relationshiptype__c,vlocity_cmt__maxquantity__c,vlocity_cmt__product2id__r.productcode,vlocity_cmt__relatedproductid__r.productcode FROM vlocity_cmt__ProductRelationship__c WHERE (vlocity_cmt__Family__c = 'Online' AND vlocity_cmt__Product2Id__r.IsActive = true AND vlocity_cmt__RelatedProductId__r.IsActive = true AND vlocity_cmt__RelationshipType__c =:ruleType) WITH SECURITY_ENFORCED];
    }
    if(items!= null && items.size()>0)
    {
        for(vlocity_cmt__ProductRelationship__c ruleItem:items)
        {
            item=new Map<String,Object>{'ruleType'=>ruleItem.vlocity_cmt__relationshiptype__c,'relatedProductCode'=>ruleItem.vlocity_cmt__relationshiptype__c,'productCode' =>ruleItem.vlocity_cmt__product2id__r.productcode,'maxQuantity'=>ruleItem.vlocity_cmt__maxquantity__c};
            rules.add(item);
        }
    }
    else {
        outMap.put('rules',null);
    }
    outMap.put('rules',rules);
}
}