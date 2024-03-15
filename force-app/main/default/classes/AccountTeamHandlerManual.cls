/**
About
-----
Description: 
AccountTeamHandlerManual class can be run either as anonymous apex or scheduled, to update AccountTeamMember 
information for subordinate accounts to ultimate parent accounts from the AccountTeamMember information  
on the ultimate accounts.

The class implements the Batchable interface to be able to safely process all the AccountTeamMembers in the org.
This class was created as a complement to AccountTeamHandler to handle the exceptions that rise with certain accounts
that have many child accounts. Instead of batching AccountTeamMembers, child accounts are batched. The child accounts
processed are the ones being childs to parent accounts listed in the custom setting 'Excluded Records' and the record 
'actExcludedAccounts'.

In the same way as for AccountTeamHandler, this class first processes deletions of child account account teams, 
and then the creation of new account team members.

I.e. AccountTeamMember information and sharing details are first deleted for child accounts to ultimate parent accounts.
Then new AccountTeamMember information and sharing details are created/copied from the child accounts' parent accounts.
AccountShare's are set to default values except for AccountAccessLevel which is set to 'Read/Write'.

Create date: October 2015

The default operation is 'delete'. 
ID batchProcessId = Database.executeBatch(new AccountTeamHandlerManual('delete'), 200);

The AccountTeamHandlerManual batch job kicks in automatically when the AccountTeamHandler batch job has finished.
First it starts with the delete job and when that has finished the insert job starts.

The batch job is either started via Anonymous Apex or automatically when starting AccountTeamHandler.

Update History
--------------
Created Oct 2015 - N.W
Updated Feb 2016 - A.N Moved method SendExceptionEmail to SEUtility-class
Updated Feb 2016 - A.N Edited all AccountTeamMember queries to exclude TeamMemberRole Cygate Account Manager
Updated Sep 2016 - C.M Updated queries to exclude Cygate and PR TeamMemberRole
Updated Apr 2017 - V.A 2245; Added access to the cases that are related to the accounts

**/ 
public with sharing class AccountTeamHandlerManual implements Database.Batchable<SObject>, Database.Stateful {

public final String query;
public final String opType;
public final Id pAccId;
private Set<Id> setExcludedUltimateParentAccounts = new Set<Id>();  
private Integer numParentAccountTeamMembers = 0;    
private List<AccountTeamMember> parentAccountTeamMembers = new List<AccountTeamMember>();
private Boolean noBatchJob = false;
//private String BATCH_JOB_RESULTS_RECEIVER = 'mail@mail.com';
private String stringteamroles1;
private String stringteamroles2;
List<String> listteamroles = new List<String>();   
List<String> listteamroles2 = new List<String>();

public AccountTeamHandlerManual(String operation) {
if (operation != 'delete' && operation != 'insertATM') opType = 'delete';
else opType = operation;

ExcludedRecords__c excludedUltimateParentAccounts = ExcludedRecords__c.getInstance('actExcludedAccounts');
if (excludedUltimateParentAccounts.Excluded_records_list__c != null) {  

    String stringExcludedUltimateParentAccounts = excludedUltimateParentAccounts.Excluded_records_list__c;
    String stringExcludedAccs = '\'' + stringExcludedUltimateParentAccounts + '\'';
    String regExp = '[,]';
    String replacement = '\',\'';
    String stringExcludedUltimateParentAccountsAppostrophes = stringExcludedAccs.replaceAll(regExp, replacement);

    List<Id> listExcludedUltimateParentAccounts = new List<Id>();
    
    if (stringExcludedUltimateParentAccounts != null && stringExcludedUltimateParentAccounts.length() > 0) {
        listExcludedUltimateParentAccounts = stringExcludedUltimateParentAccounts.split(',');       
    }

    System.debug('stringExcludedUltimateParentAccountsAppostrophes: ' + stringExcludedUltimateParentAccountsAppostrophes);

    for (Id exclParentId : listExcludedUltimateParentAccounts) {
        setExcludedUltimateParentAccounts.add(exclParentId);
    }

    query = 'SELECT Id,ParentId from Account WHERE ParentId IN (' + stringExcludedUltimateParentAccountsAppostrophes + ')';
} else {
    query = 'SELECT Id,ParentId FROM Account LIMIT 0';
    noBatchJob = true;
}
CygateTeamRoles__c teamroles = CygateTeamRoles__c.getInstance('CygateRoles-1st Set'); 
if(teamroles!=null){
stringteamroles1  = teamroles.CygateRolesList__c;
} 

CygateTeamRoles__c teamroles2 = CygateTeamRoles__c.getInstance('CygateRole-2nd Set'); 
if(teamroles2!=null){
stringteamroles2  = teamroles2.CygateRolesList__c;
}    


if (stringteamroles1 != null && stringteamroles1.length() > 0){
listteamroles = stringteamroles1.split(','); 
}
if (stringteamroles2 != null && stringteamroles2.length() > 0){
listteamroles2 = stringteamroles2.split(',');
}

listteamroles.addAll(listteamroles2);


//System.debug('listteamroles size : --- '+listteamroles.size());
// All parent account team members
parentAccountTeamMembers = 
    [SELECT Id,TeamMemberRole,UserId,AccountId 
    FROM AccountTeamMember 
    WHERE TeamMemberRole NOT IN : listteamroles
    AND AccountId IN :setExcludedUltimateParentAccounts AND UserId IN (SELECT Id FROM User WHERE IsActive = True)];         
}

// Start method
public Database.QueryLocator start(Database.BatchableContext BC) {
return Database.getQueryLocator(query);
}

public void execute(Database.BatchableContext BC, List<Account> scope) {

if (!noBatchJob) {

    List<Id> childAccountIds = new List<Id>();
    for (Account childAccount : scope) {
        childAccountIds.add(childAccount.Id);
    }

    if (opType == 'delete') {

        // Delete AccountTeamMember from child accounts
        List<AccountTeamMember> existingChildAccountShares = 
        [SELECT Id
        FROM AccountTeamMember 
        WHERE TeamMemberRole NOT IN : listteamroles AND AccountId IN :childAccountIds]; 

        try {
            delete existingChildAccountShares;
        } catch (Exception e) {
            System.debug('Exception while deleting account shares for child accounts\' account team members: ' + e);
            System.debug('childAccountIds: ' + childAccountIds);

            // Send email about the exception
            SEUtility.sendExceptionMail('Exception in AccountTeamHandlerManual batch job - deleting existing child account shares', e, childAccountIds);                                
        }

    }

    if (opType == 'insertATM') {

        // Create AccountTeamMembers for the child accounts
        List<AccountTeamMember> childAccountTeamMembers = new List<AccountTeamMember>();
        for (Account childAccount : scope) {
            for (AccountTeamMember atm : parentAccountTeamMembers) {
                if (childAccount.ParentId == atm.AccountId) {
                    AccountTeamMember childAtm = atm.clone();
                    childAtm.accountId = childAccount.Id;
                    childAccountTeamMembers.add(childAtm);
                }
            }
        }

        try {
            if (Test.isRunningTest()) {
                User adminUser = Test_DataFactory.createAdminUser();                    
                System.runAs(adminUser) {
                    insert childAccountTeamMembers;
                }
            } else insert childAccountTeamMembers;
        } catch (Exception e) {
            System.debug('Exception while inserting child account team members: ' + e);
            System.debug('parentAccountIds: ' + scope);

            // Send email about the exception
            SEUtility.sendExceptionMail('Exception in AccountTeamHandlerManual batch job - inserting child AccountTeamMembers', e, childAccountIds);                                
        }

        try {
               // Store the parent accounts opportunityaccesslevel & caseaccesslevel in a map
            Map<String,String> mapAccountAndUserIdOppAccessLevel = new Map<String,String>();
            Map<String,String> mapAccountAndUserIdCaseAccessLevel = new Map<String,String>();
            List<AccountShare> parentAccountShares = [SELECT Id,UserOrGroupId,Account.Id,AccountAccessLevel,CaseAccessLevel,OpportunityAccessLevel FROM AccountShare WHERE RowCause = 'Team' and AccountId IN :setExcludedUltimateParentAccounts];
             
            for (AccountShare parentAccountShare : parentAccountShares) {
                mapAccountAndUserIdOppAccessLevel.put(parentAccountShare.Account.Id+String.ValueOf(parentAccountShare.UserOrGroupId), String.ValueOf(parentAccountShare.OpportunityAccessLevel));
                system.debug('parentAccountShare.Account.Id+String.ValueOf(parentAccountShare.UserOrGroupId): ' + parentAccountShare.Account.Id+String.ValueOf(parentAccountShare.UserOrGroupId));
                mapAccountAndUserIdCaseAccessLevel.put(parentAccountShare.Account.Id+String.ValueOf(parentAccountShare.UserOrGroupId), String.ValueOf(parentAccountShare.CaseAccessLevel));  //V.A
            }
            
            // AccountShares are created by default when AccountTeamMembers are created
            // The child account's account share information for the account team members are queried and updated
            // with the corresponding account sharing details from the parent accounts
            
            List<AccountShare> childAccountShares = [SELECT Id,UserOrGroupId,Account.Parent.Id,AccountAccessLevel,CaseAccessLevel,OpportunityAccessLevel FROM AccountShare WHERE RowCause = 'Team' and AccountId IN :childAccountIds];
            for (AccountShare childAccountShare : childAccountShares) {
                childAccountShare.AccountAccessLevel = 'Edit';
                // If OpportunityAccessLevel for AccountTeamMembers on parent accounts are set to private
                // Then the value for the child accounts should be set to 'Read Only'
                system.debug('childAccountShare.Account.Parent.Id+String.ValueOf(childAccountShare.UserOrGroupId): ' + childAccountShare.Account.Parent.Id+String.ValueOf(childAccountShare.UserOrGroupId));
                if (mapAccountAndUserIdOppAccessLevel.get(childAccountShare.Account.Parent.Id+String.ValueOf(childAccountShare.UserOrGroupId)) == 'Edit') {
                    childAccountShare.OpportunityAccessLevel = 'Edit';
                } else childAccountShare.OpportunityAccessLevel = 'Read';
                if (mapAccountAndUserIdCaseAccessLevel.get(childAccountShare.Account.Parent.Id+String.ValueOf(childAccountShare.UserOrGroupId)) == 'Edit') { // V.A
                    childAccountShare.CaseAccessLevel = 'Edit';
                } else childAccountShare.CaseAccessLevel = 'Read';   
                
            }
            if (Test.isRunningTest()) {
                User adminUser2 = Test_DataFactory.createAdminUser();                 
                System.runAs(adminUser2) {              
                    update childAccountShares;
                }
            } else update childAccountShares;
	        }
        catch (Exception e) {
            System.debug('Exception while updating child account shares: ' + e);
            System.debug('childAccountIds: ' + childAccountIds);

            // Send email about the exception
            SEUtility.sendExceptionMail('Exception in AccountTeamHandlerManual batch job - updating child account shares', e, childAccountIds);             
        }
		
    }
}
}

public void finish(Database.BatchableContext BC) {

if (!noBatchJob) {
    AsyncApexJob a = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob 
            WHERE Id = :BC.getJobId()
        ];

    if (opType == 'delete') {
        system.debug('AccountTeamHandlerManual Delete batch job ' + a.Status);
        system.debug('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with '+ a.NumberOfErrors + ' failures. \n' + 
            'numParentAccounts affected: ' + setExcludedUltimateParentAccounts.size());
    } else if (opType == 'insertATM') {
        system.debug('AccountTeamHandlerManual InsertATM batch job ' + a.Status);
        system.debug('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with '+ a.NumberOfErrors + ' failures. \n' + 
            'numParentAccounts affected: ' + setExcludedUltimateParentAccounts.size() + '\n' +
            'numParentAccountTeamMembers: ' + parentAccountTeamMembers.size()
        );
    }
    
    // Send an email to the Apex job's submitter
    // notifying of job completion.
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    //String[] toAddresses = new String[] {BATCH_JOB_RESULTS_RECEIVER};
    String[] toAddresses = new String[] {a.CreatedBy.Email};
    mail.setToAddresses(toAddresses);
    if (opType == 'delete') mail.setSubject('AccountTeamHandlerManual Delete batch job ' + a.Status);
    else if (opType == 'insertATM') mail.setSubject('AccountTeamHandlerManual InsertATM batch job ' + a.Status);
    if (opType == 'delete') {
        mail.setPlainTextBody (
            'The batch Apex job processed ' + a.TotalJobItems +
            ' job items with '+ a.NumberOfErrors + ' failures.' + '\n' + 
            'numParentAccounts affected: ' + setExcludedUltimateParentAccounts.size()
        );
    }
    else if (opType == 'insertATM') {
        mail.setPlainTextBody (
            'The batch Apex job processed ' + a.TotalJobItems +
            ' job items with '+ a.NumberOfErrors + ' failures.' + '\n' + 
            'numParentAccounts affected: ' + setExcludedUltimateParentAccounts.size() + '\n' +
            'numParentAccountTeamMembers: ' + parentAccountTeamMembers.size()
        );          
    }
  //  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 

    if (opType == 'delete') {
        System.debug('Start AccountTeamHandlerManual insert batch');
        ID batchProcessId = Database.executeBatch(new AccountTeamHandlerManual('insertATM'), 200);
    }
}
}
}