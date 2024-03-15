/**About
-----
Description: 
AccountTeamDelete class can be run either as anonymous apex or scheduled, to delete the AccountTeamMembers 
from the child accounts whose parent don't have any AccountTeamMembers.

Create date: April 2016

Call by using the following in anonymous apex. The default operation is 'delete'. 
ID batchProcessId = Database.executeBatch(new AccountTeamDelete(), 100);

The class is also scheduled in class ATMDeleteScheduler

Update History
--------------
Updated Sep 2016 - C.M Updated all queries to exclude AccountTeamMembers having Cygate and PR Roles.
**/


global class AccountTeamDelete implements Database.Batchable<sObject>, Database.Stateful {


Set<id> nullATMAccIds= new Set<id>();
String query;
String stringteamroles1;
String stringteamroles2;
List<String> listteamroles = new List<String>();   
List<String> listteamroles2 = new List<String>();


global Database.QueryLocator start(Database.BatchableContext BC) {
CygateTeamRoles__c teamroles1 = CygateTeamRoles__c.getInstance('CygateRoles-1st Set');
if(teamroles1!=null)
{
    stringteamroles1 = teamroles1.CygateRolesList__c;
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

query='Select a.Id, (Select Id, AccountId From AccountTeamMembers where TeamMemberRole NOT IN : listteamroles limit 1)  From Account a Where a.Recordtype.DeveloperName=\'' + SEUtility.ACC_RECTYPE_KK + '\'';

return Database.getQueryLocator(query);
}

global void execute(Database.BatchableContext BC, List<Account> scope) {

for(Account a: scope){
    if (a.AccountTeamMembers.isEmpty()) {
        nullATMAccIds.add(a.Id);       
    }
}
 System.debug('nullATMAccIds------' +nullATMAccIds);
List<AccountTeamMember> childATM = [SELECT Id FROM AccountTeamMember WHERE TeamMemberRole NOT IN : listteamroles AND Account.ParentId != null 
                                    AND Account.Parent.ParentId = null AND Account.ParentId IN :nullATMAccIds];

//System.debug('childAccounts------' +childATM);

try{                   
    delete childATM;
}
catch (Exception e) {
    
    System.debug('Exception while executing the AccountTeamHandler batch job: ' + e);       
}
}   

global void finish(Database.BatchableContext BC){
AsyncApexJob a = 
    [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
     TotalJobItems, CreatedBy.Email
     FROM AsyncApexJob WHERE Id =
     :BC.getJobId()];

// Send an email to the Apex job's submitter 
//   notifying of job completion. 
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
String[] toAddresses = new String[] {a.CreatedBy.Email};
    mail.setToAddresses(toAddresses);
mail.setSubject('Account Team Delete Status ' + a.Status);
mail.setPlainTextBody
    ('The batch Apex job processed ' + a.TotalJobItems +
     ' batches with '+ a.NumberOfErrors + ' failures.');
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
}
}