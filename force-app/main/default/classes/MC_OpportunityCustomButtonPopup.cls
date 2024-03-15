public with sharing class MC_OpportunityCustomButtonPopup {
	@AuraEnabled
    public static String getAccountId(String oppId){
        Opportunity opp = [Select Id,AccountId from Opportunity where Id =: oppId WITH SECURITY_ENFORCED];
        return opp.AccountId;
    }
}