/**
About
-----
Description: After trigger on the Account object
Create date: May 2015


Update History
--------------
Created May 2015 - T.R.
Updated Nov 2015 - A.N Trigge method for record type changes
Updated Dec 2015 - P.P Purpose : Roll Up on Account to count the number of Child Accounts as part of Data Cleansing
Updated Mar 2016 - P.P Purpose :Correction on RollUp Functionality - Code restructering 
Updated Apr 2016 - S.S Purpose : Calling of 'AccountCountUpdate' method is controlled by custom setting 'Skip_Trigger__c'.
Updated Sep 2016 - A.N Merged functionality into AccountTriggerHandler

Issues / TODOs

DELETE THIS TRIGGER
-------------- 

*/

trigger AccountAfter on Account (after insert, after update, after delete, after undelete) {
    /*
    System.debug('AN-TEST2 AccountAfter.trigger SOQLs so far start: '+Limits.getQueries());

    final Id organisationRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Sales_Organisation_Account' LIMIT 1][0].Id;
    
    //Filter 1 - If the Contacted__c field has been updated
    //Filter 2 - If it is a current customer, More_Than_10_Postpaid__c = true
    
    //Collections holding data to be processed
    Set<Account> contactedUpdatedAccounts = new Set<Account>();
    Set<Account> currentCustomerUpdatedAccounts = new Set<Account>();
    Set<Account> accountsWithNewRecordType = new Set<Account>();
    
     /*Added by PP
    Map<Id,List<Account>> childAccountAddMap = new Map<Id,List<Account>>();
    Map<id,List<Account>> childAccountRemoveMap = new Map<Id,List<Account>>();
    Set<Id> childCount = new Set<Id>();
    Set<Id> AddParentAccountIds = new Set<Id>();
    Set<Id> RemoveParentAccountIds = new Set<Id>();
    Map<Id,Decimal> RemoveParentAccountSize = new Map<Id,Decimal>();
    Skip_Trigger__c bypassaccounttriggermethod;
    Boolean skipmethod;
    
    //Gather up records to be processed
    if (Trigger.isInsert) {
        for (Account account : Trigger.new) {
            //Filter 1
            if(account.Contacted__c != null && account.ParentId != null && 
               account.Bearbetas_ej__c == false && account.RecordTypeId.equals(organisationRTId)) {
                   contactedUpdatedAccounts.add(account);
               }
            //Filter 2
            if(account.More_Than_10_Postpaid__c == true && account.ParentId != null && 
               account.Bearbetas_ej__c == false && account.RecordTypeId.equals(organisationRTId)) {
                   currentCustomerUpdatedAccounts.add(account);
               }
               
            /*Added by PP
            //Filter 4
            
            if(account.ParentId != Null){
                   system.debug('inside Insert Statement');
                   AddParentAccountIds.add(account.ParentId);
               }
            
        }
    }
    else if (Trigger.isUpdate) {
        for (Account account : Trigger.new) {
            //Filter 1
            if(account.Contacted__c != Trigger.oldMap.get(account.Id).Contacted__c && 
               account.ParentId != null && account.Bearbetas_ej__c == false && account.RecordTypeId.equals(organisationRTId)) {
                   contactedUpdatedAccounts.add(account);
               }
            //Filter 2
            if(account.More_Than_10_Postpaid__c != Trigger.oldMap.get(account.Id).More_Than_10_Postpaid__c && account.ParentId != null && 
               account.Bearbetas_ej__c == false && account.RecordTypeId.equals(organisationRTId)) {
                   currentCustomerUpdatedAccounts.add(account);
               }
            //Filter 3
            if(account.RecordTypeId != Trigger.oldMap.get(account.Id).RecordTypeId) {
                   accountsWithNewRecordType.add(account);
               }
               
            /*Added by PP
            //Filter 4 & 5         
            system.debug('inside Update Statement');
            Account oldAccountInst = trigger.oldMap.get(account.Id);   
            if(account.ParentId != Null){
                system.debug('inside Update Statement - earlier diff parent');
                List<Account> accountList = new List<Account>();
                List<Account> accountRemoveList = new List<Account>();
                        
                        if(account.ParentId != oldAccountInst.ParentId){
                            RemoveParentAccountIds.add(oldAccountInst.ParentId);
                            AddParentAccountIds.add(account.ParentId);
                            
                        }                   
             }                   
            else{
                system.debug('inside Update Statement - now no Parent');
                if(account.ParentId != oldAccountInst.ParentId){
                    RemoveParentAccountIds.add(oldAccountInst.ParentId);
                }
           }
            
            // Added by PP to handle the one time update
            //Filter 6
            
            system.debug('inside update statement');
            if(account.Has_Child_Account__c != True){
                childCount.add(account.Id);
            }
               
        }
    }
    else if (Trigger.isDelete) {
        for (Account account : Trigger.old) {
            //Filter 1
            if(account.Contacted__c != null && account.ParentId != null && 
               account.Bearbetas_ej__c == false && account.RecordTypeId.equals(organisationRTId)) {
                   contactedUpdatedAccounts.add(account);
               }
            //Filter 2
            if(account.More_Than_10_Postpaid__c == true && account.ParentId != null && 
               account.Bearbetas_ej__c == false && account.RecordTypeId.equals(organisationRTId)) {
                   currentCustomerUpdatedAccounts.add(account);
               }
            
            /* Added by PP
            //Filter 5
             
             if(account.ParentId != Null)  {
                 RemoveParentAccountIds.add(account.ParentId);
                 
             }          
        }
    }
    else if (Trigger.isUndelete) {
        for (Account account : Trigger.new) {
            //Filter 1
            if(account.Contacted__c != null && account.ParentId != null && 
               account.Bearbetas_ej__c == false && account.RecordTypeId.equals(organisationRTId)) {
                   contactedUpdatedAccounts.add(account);
               }
            //Filter 2
            if(account.More_Than_10_Postpaid__c == true && account.ParentId != null && 
               account.Bearbetas_ej__c == false && account.RecordTypeId.equals(organisationRTId)) {
                   currentCustomerUpdatedAccounts.add(account);
               }
            /*Added by PP
            //Filter 4   
            
            if(account.ParentId != Null){
                AddParentAccountIds.add(account.ParentId);
            }
                
        }
    }
    
    //Execute logic
    //Filter 1
    if (contactedUpdatedAccounts.size() > 0) {
        AccountServiceClass.calculateParentAccountContactedDate(contactedUpdatedAccounts);
    }
    //Filter 2
    if (currentCustomerUpdatedAccounts.size() > 0) {
        AccountServiceClass.calculateParentAccountCurrentCustomer(currentCustomerUpdatedAccounts);
    }
    //Filter 3
    if (accountsWithNewRecordType.size() > 0) {
        AccountServiceClass.updateSolutionSalesOutcome(accountsWithNewRecordType, Trigger.oldMap);
    }
      
    /*Added by PP
    //Filter 4
    
    if(AddParentAccountIds.size() > 0){
        AccountRollUp.AccountUpdateFlagTrue(AddParentAccountIds);
    }
    //Filter 5 - need to check this - test
    if(RemoveParentAccountIds.size() > 0){
        AccountRollUp.AccountUpdateFlagFalse(RemoveParentAccountIds);
    }
    
    //Filter 6
    if(childCount.size() > 0)
    {
        if(Skip_Trigger__c.getValues('AccountRollupTrigger') != null)
        {
            bypassaccounttriggermethod = Skip_Trigger__c.getValues('AccountRollupTrigger'); 
            if(bypassaccounttriggermethod != null)
            {
                skipmethod = bypassaccounttriggermethod.PassMethod__c;
            }
            if(skipmethod == true)
            {
                AccountRollUp.AccountCountUpdate(childCount);
            }
        }
    }
    System.debug('AN-TEST2 AccountAfter.trigger SOQLs so far end: '+Limits.getQueries());
    */
}