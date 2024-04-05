//LTAT-18596: AccountTriggerHandler to fix the issue to handle child accounts, Batch class to handle Child Records.
global class AccountChildUpdaterBatch implements Database.Batchable<sObject> {
    List<Id> parentIds;
    Map<Id, Account> newAccountList; 

    public AccountChildUpdaterBatch(List<Id> parentIds, Map<Id, Account> newAccList) {
        this.parentIds = parentIds; 
        this.newAccountList = newAccList; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query all child accounts that have a ParentId in the list of parentIds
        return Database.getQueryLocator([SELECT Id, Telia_Service_Manager__c, LifeCycle_Manager__c, Change_Manager__c, ParentId 
                                         FROM Account 
                                         WHERE ParentId IN :parentIds]);
    }

    global void execute(Database.BatchableContext bc, List<Account> childAccounts) {
        for(Account child : childAccounts) {
            Account parentAccount = newAccountList.get(child.ParentId); 
            if(parentAccount != null) { 
                child.Telia_Service_Manager__c = parentAccount.Telia_Service_Manager__c;
                child.LifeCycle_Manager__c = parentAccount.LifeCycle_Manager__c;
                child.Change_Manager__c = parentAccount.Change_Manager__c;
            }
        }
        update childAccounts;
    }

    global void finish(Database.BatchableContext bc) {
        
    }
}