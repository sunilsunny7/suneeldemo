public class ProductDetailController {
    @AuraEnabled
    public static List<OpportunityLineItem> getRecord(String caseinputId) {
        system.debug('TTT'+caseinputId);
        CASE caseObj = new CASE();
        caseObj = [SELECT Id,Opportunity__c FROM CASE where Id =:caseinputId LIMIT 1];
        system.debug('###'+caseObj);
        if(caseObj !=null){
            return [SELECT Id, Name, Quantity, Sales_purpose__c, Total_Amount__c, OpportunityId FROM OpportunityLineItem where OpportunityId =:caseObj.Opportunity__c]; 
        }else
            return null;
    }
    
     @AuraEnabled
    public static Id getOpportunity(String caserecordId) {
        system.debug('TTT'+caserecordId);
        CASE caseObj = [SELECT Id,Opportunity__c FROM CASE where Id =:caserecordId LIMIT 1];
        if(caseObj !=null && caseObj.Opportunity__c != null){
            return caseObj.Opportunity__c;
        }else
            return null;
    }
}