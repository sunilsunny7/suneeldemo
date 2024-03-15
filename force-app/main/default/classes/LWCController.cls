public with sharing class LWCController {

    @AuraEnabled(cacheable=true)
    public static String getJSONValue(String opptyId) {
        if (String.isNOTBlank(opptyId)) {
            Opportunity oppVal = [select Id,Name,Account_Org_Nr__c,Opportunity_id__c from Opportunity where id =: opptyId LIMIT 1];
            return EncodingUtil.urlEncode(JSON.serialize(oppVal),'UTF-8');
        }
        return null;
    }
    @AuraEnabled
    public static Boolean checkIfSandbox() {
        return [SELECT Id,IsSandbox FROM Organization].IsSandbox;
    }
}