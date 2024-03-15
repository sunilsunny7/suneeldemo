/**
 * Created by esa137 on 2022-12-15.
 */

public with sharing class BatchUpdateCygateAccountManager implements Database.Batchable<SObject>, Database.AllowsCallouts{
    public List<Id> updatedAccountIds = new List<Id>();

    public BatchUpdateCygateAccountManager(List<Id> listMainAccounts)
    {
        updatedAccountIds = listMainAccounts;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Cygate_Account_Manager__r.FirstName, Cygate_Account_Manager__r.LastName, (SELECT Id, Cygate_Account_Manager__c FROM Contacts), (SELECT Id, Cygate_Account_Manager__c FROM Leads__r ) FROM Account WHERE Id IN :updatedAccountIds');
    }
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        List<SObject> leadsAndContacts = new List<SObject> ();
        for (Account oneAccount : scope) {
            String cygateAccountManagerName = oneAccount.Cygate_Account_Manager__r.FirstName + ' ' + oneAccount.Cygate_Account_Manager__r.LastName;
            for (Contact oneContact : oneAccount.Contacts) {
                if (oneContact.Cygate_account_manager__c != cygateAccountManagerName) {
                    Contact updatedContact = new Contact(Id = oneContact.Id, Cygate_account_manager__c = cygateAccountManagerName);
                    leadsAndContacts.add(updatedContact);
                }
            }

            for (Lead oneLead : oneAccount.Leads__r){
                if (oneLead.Cygate_account_manager__c != cygateAccountManagerName){
                    Lead updatedLead = new Lead(Id = oneLead.Id, Cygate_account_manager__c = cygateAccountManagerName);
                    leadsAndContacts.add(updatedLead);
                }
            }
        }
        if (scope.size() > 0) {

        try {
            Database.update(leadsAndContacts) ;
        }
            catch (Exception e)  {


            SEUtility.sendExceptionMail('Cygate_account_manager__c field was not updated for the following records:',e , new List<Id> ());
        }

        }


    }
    public void finish(Database.BatchableContext bc){


    }
}