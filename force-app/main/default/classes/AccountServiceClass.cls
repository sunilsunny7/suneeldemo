/**
About
-----
Description: Service Class for Account
Create date: March 2015

Update History
--------------
Created March 2015 - V.I
Updated May 2015 - V.I Purpose field removed from Activities. Changed from Winback/Retain contacted to only Contacted. 
Updated Sep 2015 - V.I AccountTargeted method should only update SME accounts
Updated Sep 2016 - A.N Merged functionality into AccountTriggerHandler

Issues / TODOs

DELETE THIS CLASS
-------------- 

*/

public without sharing class AccountServiceClass {
    
    /* Method that takes a map between accountID and a DateTime and updates the Contacted__c field on the Account according to the date field in the incoming map. 
    * Before updating the field a check is made that the date in the map is higher than the current Contacted__c date. Otherwise no update will be done. */
    
    /* A.N Moved to SEUtility and renamed to setAccountContactedDate
    public static void accountTargeted(Map<Id,DateTime> accIdtoDateMap){
        System.debug('accountTargeted method starts');
        
        final Id organisationRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Sales_Organisation_Account' LIMIT 1][0].Id;
        System.debug('organisationRTId: ' + organisationRTId);
        List<Account> targetedAccounts = new List<Account>();
        
        if(!accIdtoDateMap.isEmpty()){
            targetedAccounts = [SELECT Contacted__c, RecordTypeId FROM Account WHERE Id IN : accIdtoDateMap.keySet() AND RecordTypeId = : organisationRTId];         
        }
        
        if(!targetedAccounts.isEmpty()){
            
            for(Account a : targetedAccounts){
                if(a.Contacted__c < accIdtoDateMap.get(a.Id).date() || a.Contacted__c == null){
                    a.Contacted__c = accIdtoDateMap.get(a.Id).date();
                    System.debug('Contacted__c updated!');
                    System.debug('AccountRecordType: ' + a.RecordTypeId);
                }
                else{
                    System.debug('No update done');
                }
            }
            
            update targetedAccounts;
            
        }
        System.debug('accountTargeted method ends');    
    }
    */

    /* Merged into AccountTriggerHandler
    // Takes a list of child accounts to calculate the parent accounts latest contact date
    public static void calculateParentAccountContactedDate(Set<Account> childAccounts) {
        Set<Id> parentAccountIds = new Set<Id>();
        for (Account childAccount : childAccounts) {
            parentAccountIds.add(childAccount.ParentId);
        }
        
        List<AggregateResult> accountContactedDates = [SELECT ParentId accountId, MAX(Contacted__c) latestDate FROM Account
                                                       WHERE ParentId IN: parentAccountIds AND Bearbetas_Ej__c = false AND Contacted__c != null
                                                       GROUP BY ParentId];
        
        System.debug('@@ accountContactedDates: ' + accountContactedDates);
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        for (AggregateResult ar : accountContactedDates) {
            Account account = new Account();
            account.Id = (Id) ar.get('accountId');
            account.Contacted__c = (Date) ar.get('latestDate');
            accountsToUpdate.put(account.Id, account);
        }
        
        //If the parentAccount is not in the result list, meaning the last one was deleted, clear the Contacted__c on parent account
        for (Id parentAccountId : parentAccountIds) {
            if(!accountsToUpdate.containsKey(parentAccountId)) {
                Account account = new Account(Id = parentAccountId, Contacted__c = null);
                accountsToUpdate.put(parentAccountId, account);
            }
        }
        update accountsToUpdate.values();
    }

    // A.N Merged functionality into AccountTriggerHandler
    // Takes a list of child accounts to decide if the parent account is a current customer or not
    public static void calculateParentAccountCurrentCustomer(Set<Account> childAccounts) {
        Set<Id> parentAccountIds = new Set<Id>();
        for (Account childAccount : childAccounts) {
            parentAccountIds.add(childAccount.ParentId);
        }
        
        List<Account> accountCurrentCustomers = [SELECT Id, ParentId, More_Than_10_Postpaid__c FROM Account
                                               WHERE ParentId IN: parentAccountIds AND Bearbetas_Ej__c = false];
        System.debug('@@ accountCurrentCustomers: ' + accountCurrentCustomers);
        //Create a map of the accounts to be updated
        Map<Id, Account> accountIdToAccountToUpdate = new Map<Id, Account>();
        for (Account account : accountCurrentCustomers) {
            Boolean currentCustomer = account.More_Than_10_Postpaid__c;
            if (accountIdToAccountToUpdate.containsKey(account.ParentId)) {
                if (accountIdToAccountToUpdate.get(account.ParentId).Current_Customer__c == false && currentCustomer == true) {
                    accountIdToAccountToUpdate.put(account.ParentId, new Account(Id = account.ParentId, Current_Customer__c = true));
                }
            } else {
                accountIdToAccountToUpdate.put(account.ParentId, new Account(Id = account.ParentId, Current_Customer__c = currentCustomer));
            }
        }
        
        //If the parentAccount is not in the result list, meaning the last one was deleted, clear the Current_Customer__c on parent account
        for (Id parentAccountId : parentAccountIds) {
            if(!accountIdToAccountToUpdate.containsKey(parentAccountId)) {
                Account account = new Account(Id = parentAccountId, Current_Customer__c = false);
                accountIdToAccountToUpdate.put(parentAccountId, account);
            }
        }
        update accountIdToAccountToUpdate.values();
    }

    // A.N Merged functionality into AccountTriggerHandler
    public static void updateSolutionSalesOutcome(Set<Account> accountIds, Map<Id, Account> oldMap){
        List<Account> accountList = [SELECT Id, RecordTypeId, (SELECT Id, IsWon, OwnerId, CloseDate, AccountId From Opportunities) FROM Account WHERE id IN: accountIds];
        List<Opportunity> smeToLargeAccountsOpps = new List<Opportunity>();
        List<Opportunity> largeToSmeAccountsOpps = new List<Opportunity>();

        for(Account acc : accountList){
            Account oldAcc = oldMap.get(acc.Id);
            if(SEUtility.isSmeAccountRecordType(acc.RecordTypeId) && SEUtility.isLargeAccountRecordType(oldAcc.RecordTypeId)){
                // If old record type is Large and new is SME, add opps to list
                largeToSmeAccountsOpps.addAll(acc.Opportunities);
            } else if(SEUtility.isLargeAccountRecordType(acc.RecordTypeId) && SEUtility.isSmeAccountRecordType(oldAcc.RecordTypeId)){
                // If old record type is SME and new is Large, add opps to list
                smeToLargeAccountsOpps.addAll(acc.Opportunities);
            }
        }

        if(largeToSmeAccountsOpps.size() > 0){
            // Deletes all Sales_Outcome_Solutions__c for the opportunities
            SolutionsSalesOutcomeServiceClass.deleteExistingRecords(largeToSmeAccountsOpps);
        }
        if(smeToLargeAccountsOpps.size() > 0){
            // Create Sales_Outcome_Solutions__c for the opportunities
            OpportunityTriggerHandler.createSolutionSalesOutcomeRecords(smeToLargeAccountsOpps);
        }
    }
    */
}