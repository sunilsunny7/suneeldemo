/**
    About
    -----
    Description: For all accounts owned by Large users having one of the roles defined in the
        custom setting "Large Roles Acc Owners as Contact Owners", this batch job will update all contacts on
        these accounts so that the contact owner is the same as the account owner (but only if the old contact owner 
        is also a Large User. If the contact is owned by f.ex. a SME user we should not update the owner)
        This batch job will be scheduled to run every night Mon-Fri so that the contact owners are always up to date.

    Create date: February 2017
            
    Update History
    --------------
    Created Feb 2017 - A.N Case-2451

    // To manually start the batch job, run the following code:
    // Id batchInstanceId = Database.executeBatch(new UpdateContactOwnerOnLargeAccountsBatch()); // Default batchsize 200
*/

global class UpdateContactOwnerOnLargeAccountsBatch implements Database.Batchable<sObject> {
    
    String query;
    Set<Id> largeAccRecTypeIds;
    Set<Id> largeUserIds;
    
    global UpdateContactOwnerOnLargeAccountsBatch() {
        setUserList();
        largeAccRecTypeIds = new Set<Id>{SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE), SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE_SEC1), SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE_SEC2)};     
        
        query =  'SELECT Id, Name, OwnerId, Account.OwnerId FROM Contact WHERE Contact_Owner_not_equal_Account_Owner__c = true ';
        query += 'AND Account.OwnerId in :largeUserIds AND Account.RecordTypeId in :largeAccRecTypeIds';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> contactList) {
        List<Contact> contactUpdateList = new List<Contact>();
        for(Contact c : contactList){
            if(largeUserIds.contains(c.OwnerId)){ // Check if the existing contact-owner is also a Large user, if yes update contact owner to account owner.
                c.OwnerId = c.Account.OwnerId;
                contactUpdateList.add(c);
            }
        }
        System.debug('Batch job UpdateContactOwnerOnLargeAccounts updating contacts: ' + contactUpdateList);
        if(!contactUpdateList.isEmpty()) update contactUpdateList;
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch job UpdateContactOwnerOnLargeAccounts finished');
    }
    

    private void setUserList(){
        List<UserRole> userRoles = [SELECT Id, DeveloperName FROM UserRole];
        Map<String, Id> userRoleMap = new Map<String, Id>();
        for(UserRole ur : userRoles) userRoleMap.put(ur.DeveloperName, ur.Id);

        Set<Id> largeRoleIds = new Set<Id>();        
        for(Large_Roles_Acc_Owners_as_Contact_Owners__c roleName : Large_Roles_Acc_Owners_as_Contact_Owners__c.getAll().values())
            largeRoleIds.add(userRoleMap.get(roleName.Role_Developer_Name__c));

        largeUserIds = new Map<Id, User>([SELECT Id FROM User Where UserRoleId in : largeRoleIds]).keySet();
    }
}