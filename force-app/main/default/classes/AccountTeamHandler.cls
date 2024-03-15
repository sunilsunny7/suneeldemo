/**
About
-----
Description: 
AccountTeamHandler class can be run either as anonymous apex or scheduled, to update AccountTeamMember 
information for subordinate accounts to ultimate parent accounts from the AccountTeamMember information 
on the ultimate accounts. 

The class implements the Batchable interface to be able to safely process all the AccountTeamMembers in the org. 
This solution has been chosen in the event that the number of AccountTeamMembers will increase due to the fact that 
there are more than 2M accounts. 

AccountTeamMember information and sharing details are first deleted for child accounts to ultimate accounts.
Then new AccountTeamMember information and sharing details are created/copied from the child accounts' parent accounts.
AccountShare's are set to default values except for AccountAccessLevel which is set to 'Read/Write'.

Create date: October 2015

Call by using the following in anonymous apex. The default operation is 'delete'. 
ID batchProcessId = Database.executeBatch(new AccountTeamHandler('delete'), 20);

What happens during an execution is that after deletions of child account accountteammembers have been done, 
a new batch job is started which creates new accountteammembers on child accounts (copied from ultimate parent
accounts). After this is done a new batch job starts which kicks off the AccountTeamHandlerManual batch job.

The class is also scheduled in class AccountTeamHandlerScheduler

Update History
--------------
Created Oct 2015 - N.W
Updated Feb 2016 - A.N Moved method SendExceptionEmail to SEUtility-class
Updated Sep 2016 - C.M Updated all queries to exclude all AccountTeamMembers having Cygate and PR Roles
Updated Dec 2016 - C.M Exclude parent and their child  from processing which have more than 10000 org accounts
Updated Apr 2017 - V.A 2245; Added access to the cases that are related to the accounts

**/
public with sharing class AccountTeamHandler implements Database.Batchable<SObject>, Database.Stateful {

public final String query;
public final String opType;
private Integer numParentAccounts = 0;
private Integer numChildAccounts = 0;
private Integer numParentAccountTeamMembers = 0;    
private Set<Id> setExcludedUltimateParentAccounts = new Set<Id>();
private Set<Id> setexcludedKundkontoAccs = new Set<Id>();
private Set<String> setteamroles = new Set<String>();
private Set<Id> processedParentAccountIds = new Set<Id>();
//private String BATCH_JOB_RESULTS_RECEIVER = 'mail@mail.com';
private String stringteamroles1;
private String stringteamroles2;
List<String> listteamroles = new List<String>();   
List<String> listteamroles2 = new List<String>();


public AccountTeamHandler(String operation) {
if (operation != 'delete' && operation != 'insertATM') opType = 'delete';
else opType = operation;
ExcludedRecords__c excludedUltimateParentAccounts = ExcludedRecords__c.getInstance('actExcludedAccounts');  
String stringExcludedUltimateParentAccounts = excludedUltimateParentAccounts.Excluded_records_list__c;
List<Id> listExcludedUltimateParentAccounts = new List<Id>();

if (stringExcludedUltimateParentAccounts != null && stringExcludedUltimateParentAccounts.length() > 0) {
listExcludedUltimateParentAccounts = stringExcludedUltimateParentAccounts.split(',');       
}

for (Id exclParentId : listExcludedUltimateParentAccounts) {
setExcludedUltimateParentAccounts.add(exclParentId);
}

ExcludedRecords__c excludedKundkontoAccs = ExcludedRecords__c.getInstance('excludedAccsATMhandler');  
String stringExcludedKundkontoAccs = excludedKundkontoAccs.Excluded_records_list__c;
List<Id> listexcludedKundkontoAccs = new List<Id>();

if (stringExcludedKundkontoAccs != null && stringExcludedKundkontoAccs.length() > 0) {
listexcludedKundkontoAccs = stringExcludedKundkontoAccs.split(',');       
}

for (Id exclParentAccId : listexcludedKundkontoAccs) {
setexcludedKundkontoAccs.add(exclParentAccId);
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

for (String rol : listteamroles) {
setteamroles.add(rol);
}
   
//System.debug('listteamroles size : --- '+listteamroles.size());
//query = 'SELECT AccountId,TeamMemberRole, Account.Recordtype.Name FROM AccountTeamMember WHERE Account.Recordtype.DeveloperName!=\'Kundkonto_Sk_1\' //AND Account.Recordtype.DeveloperName!=\'Kundkonto_S_k_2\' AND TeamMemberRole Not IN :listteamroles';

query = 'Select a.Id, (Select Id, AccountId From AccountTeamMembers where TeamMemberRole NOT IN : listteamroles limit 1)  From Account a Where a.Recordtype.DeveloperName=\'' + SEUtility.ACC_RECTYPE_KK + '\'';
}

// Start method
public Database.QueryLocator start(Database.BatchableContext BC) {
return Database.getQueryLocator(query);
}

public void execute(Database.BatchableContext BC, List<Account> scope) {

List<Id> childAccountIds = new List<Id>();
List<Account> parentAccs= new List<Account>();

System.debug('AccounTeamHandler: debug - enter execute method');

// Create list of account ids from the scope of AccountTeamMembers to which they belong
List<Id> accountTeamMemberAccountIds = new List<Id>();
Set<id> nullATMAccIds= new Set<id>();
system.debug('------------scope data-----------' +scope);
for (Account scopeAtm : scope) {
if (!processedParentAccountIds.contains(scopeAtm.Id) && !setExcludedUltimateParentAccounts.contains(scopeAtm.Id) && !setexcludedKundkontoAccs.contains(scopeAtm.Id)) {
    
    if (!scopeAtm.AccountTeamMembers.isEmpty()){
    accountTeamMemberAccountIds.add(scopeAtm.Id);
    processedParentAccountIds.add(scopeAtm.Id);
    }
    else if(scopeAtm.AccountTeamMembers.isEmpty()) {
        nullATMAccIds.add(scopeAtm.Id);       
    } 
}

}


 List<AccountTeamMember> nullchildATM = [SELECT Id,User.Name, AccountId, TeamMemberRole FROM AccountTeamMember WHERE TeamMemberRole NOT IN : listteamroles AND Account.ParentId != null 
                                    AND Account.Parent.ParentId = null AND Account.ParentId IN :nullATMAccIds];
                                    
                                    

//system.debug('----accountTeamMemberAccountIds------'+accountTeamMemberAccountIds);
// Get all child accounts to ultimate parent accounts for which the ultimate parents have AccountTeamMembers
List<Account> childAccounts = 
[SELECT Id,ParentId 
 FROM Account 
 WHERE ParentId != null AND Parent.ParentId = null AND ParentId IN : accountTeamMemberAccountIds];

// List of account ids
Set<Id> parentAccountIds = new Set<Id>();

for (Account a : childAccounts) {
childAccountIds.add(a.Id);          
}
//system.debug('---childAccountIds----' +childAccountIds.size());
numChildAccounts = numChildAccounts + childAccountIds.size();       

// Delete AccountTeamMember from child accounts
List<AccountTeamMember> existingChildAccountShares = 
[SELECT Id, User.Name, AccountId, TeamMemberRole
 FROM AccountTeamMember 
 WHERE TeamMemberRole NOT IN : listteamroles AND AccountId IN :childAccountIds];

for(AccountTeamMember nChildAtm :  nullchildATM){
    existingChildAccountShares.add(nChildAtm);
}
if (opType == 'delete') {
try {
      delete existingChildAccountShares;
     
} catch (Exception e) {
    
    System.debug('Exception while executing the AccountTeamHandler batch job: ' + e);
    //System.debug('childAccountIds: ' + childAccountIds);
    
    // Send email about the exception
    SEUtility.sendExceptionMail('Exception in AccountTeamHandler batch job - deleting child account shares', e, childAccountIds);
}

} else if (opType == 'insertATM') {

System.debug('AccountTeamHandler: debug - in insert clause');

try {
    // All parent account team members
    List<AccountTeamMember> parentAccountTeamMembers = 
        [SELECT Id,TeamMemberRole,UserId,AccountId 
         FROM AccountTeamMember 
         WHERE TeamMemberRole NOT IN : setteamroles 
         AND AccountId IN :accountTeamMemberAccountIds AND UserId IN (SELECT Id FROM User WHERE IsActive = True)];
    
    numParentAccountTeamMembers = numParentAccountTeamMembers + parentAccountTeamMembers.size();
    
    // Create AccountTeamMembers for the child accounts
    List<AccountTeamMember> childAccountTeamMembers = new List<AccountTeamMember>();
    for (Account childAccount : childAccounts) {
        for (AccountTeamMember atm : parentAccountTeamMembers) {
            if (childAccount.ParentId == atm.AccountId) {
                AccountTeamMember childAtm = atm.clone();
                childAtm.accountId = childAccount.Id;
                childAccountTeamMembers.add(childAtm);
            }
        }
    }
    
    if (Test.isRunningTest()) {
        User adminUser = Test_DataFactory.createAdminUser();                    
        System.runAs(adminUser) {
            insert childAccountTeamMembers;
        }System.Debug('ChildRecords! '+childAccountTeamMembers);
    } else insert childAccountTeamMembers;
    System.Debug('ChildRecordss '+childAccountTeamMembers);
    
    // Store the parent accounts opportunityaccesslevel & caseaccesslevel in a map
    Map<String,String> mapAccountAndUserIdOppAccessLevel = new Map<String,String>();
    Map<String,String> mapAccountAndUserIdCaseAccessLevel = new Map<String,String>();
    List<AccountShare> parentAccountShares = [SELECT Id,UserOrGroupId,Account.Id,AccountAccessLevel,CaseAccessLevel,OpportunityAccessLevel FROM AccountShare WHERE RowCause = 'Team' and AccountId IN :accountTeamMemberAccountIds];
     
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
      
        if (mapAccountAndUserIdCaseAccessLevel.get(childAccountShare.Account.Parent.Id+String.ValueOf(childAccountShare.UserOrGroupId)) == 'Edit') {  //V.A
            childAccountShare.CaseAccessLevel = 'Edit';
        } else childAccountShare.CaseAccessLevel = 'Read';
        
    }    
    if (Test.isRunningTest()) {
        User adminUser2 = Test_DataFactory.createAdminUser();                   
        System.runAs(adminUser2) {              
        update childAccountShares;
        }
    } else update childAccountShares;
  
} catch (Exception e) {
    
    System.debug('Exception while executing the AccountTeamHandler batch job: ' + e);
    System.debug('childAccountIds: ' + childAccountIds);
    
    // Send email about the exception
    SEUtility.sendExceptionMail('Exception in AccountTeamHandler batch job - inserting child accountteammembers or updating account shares', e, childAccountIds);
}           
}
}

public void finish(Database.BatchableContext BC) {

AsyncApexJob a = [SELECT id, ApexClassId, Status,
              JobItemsProcessed, TotalJobItems,
              NumberOfErrors, CreatedBy.Email
              FROM AsyncApexJob
              WHERE id = :BC.getJobId()];

// Define the email
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
//String[] toAddresses = new String[] {BATCH_JOB_RESULTS_RECEIVER};
String[] toAddresses = new String[] {a.CreatedBy.Email};        
email.setToAddresses(toAddresses);        

if (opType == 'delete') email.setSubject('AccountTeamHandler Delete batch job ' + a.Status);
else if (opType == 'insertATM') email.setSubject('AccountTeamHandler InsertATM batch job ' + a.Status);
if (opType == 'delete') {
email.setPlainTextBody (
    'The batch Apex job processed ' + a.TotalJobItems +
    ' job items with '+ a.NumberOfErrors + ' failures. \n' + 
    'numParentAccounts affected: ' + processedParentAccountIds.size() + '\n' + 
    'numChildAccounts affected: ' + numChildAccounts
);
} 
else if (opType == 'insertATM') {
email.setPlainTextBody (
    'The batch Apex job processed ' + a.TotalJobItems +
    ' job items with '+ a.NumberOfErrors + ' failures. \n' + 
    'numParentAccounts affected: ' + processedParentAccountIds.size() + '\n' + 
    'numChildAccounts affected: ' + numChildAccounts + '\n' +
    'numParentAccountTeamMembers inserted: ' + numParentAccountTeamMembers
);
}

// Sends the email
// Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

if (opType == 'delete') {
System.debug('Start AccountTeamHandler insert batch');          
ID batchProcessId = Database.executeBatch(new AccountTeamHandler('insertATM'), 100);
}
if (opType == 'insertATM') {
System.debug('Start AccountTeamHandlerManual delete batch');
ID batchProcessId = Database.executeBatch(new AccountTeamHandlerManual('delete'), 200);
}           
}
}