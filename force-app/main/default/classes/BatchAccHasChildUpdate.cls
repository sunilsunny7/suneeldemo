global class BatchAccHasChildUpdate implements Database.Batchable < sObject > {
    String query;
    global BatchAccHasChildUpdate() {
        query = 'select Id, Has_Child_Account__c,ParentId,Old_Parent_Id__c from Account where Is_Parent_Changed__c = true';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List < Account > scope) {
        Set < Id > parentIds = new Set < Id > ();
        Set < Id > setExcludedUltimateParentAccounts = new Set < Id > ();
        
        ExcludedRecords__c excludedUltimateParentAccounts = ExcludedRecords__c.getInstance('AcntRollUpExcludedRecords');
        String stringExcludedUltimateParentAccounts = excludedUltimateParentAccounts.Excluded_records_list__c;

        List < Id > listExcludedUltimateParentAccounts = new List < Id > ();
        if (stringExcludedUltimateParentAccounts != null && stringExcludedUltimateParentAccounts.length() > 0) {
            listExcludedUltimateParentAccounts = stringExcludedUltimateParentAccounts.split(',');
        }

        for (Id exclParentId: listExcludedUltimateParentAccounts) {
            setExcludedUltimateParentAccounts.add(exclParentId);
        }

        List < Account > hasChildAccs = new List < Account > ();
        for (Account acc: scope) {
            Id oldId;
            If(acc.Old_Parent_Id__c!=null){
            oldId = Id.ValueOf(acc.Old_Parent_Id__c);
            }
            if (!setExcludedUltimateParentAccounts.contains(acc.ParentId) && !parentIds.contains(acc.ParentId)) {
                parentIds.add(acc.ParentId);
            }
            if (!setExcludedUltimateParentAccounts.contains(oldId) && !parentIds.contains(oldId)) {
                parentIds.add(oldId);
            }
            acc.Is_Parent_Changed__c = false;
            acc.Approved__c = false; //reset            
        }

        for (Account acc: [SELECT Id, Has_Child_Account__c, Has_Child_No_Of_Days_Performed__c, (SELECT Id FROM ChildAccounts limit 1) FROM Account where Id =: parentIds]) {
            if (acc.Has_Child_Account__c == true && acc.ChildAccounts.size() == 0) {
                acc.Has_Child_Account__c = false;
                acc.Has_Child_No_Of_Days_Performed__c = system.today();
            } else if (acc.Has_Child_Account__c == false && acc.ChildAccounts.size() > 0) {
                acc.Has_Child_Account__c = true;
                acc.Has_Child_No_Of_Days_Performed__c = NULL;
            }
            hasChildAccs.add(acc);
        }
        if (hasChildAccs.size() > 0) {
            try {
                database.update(hasChildAccs);
            } catch (Exception e1) {
                System.debug('Exception while executing the Segmentation batch job: ' + e1);
            }
        }

        try {
            database.update(scope);
        } catch (Exception e2) {
            System.debug('Exception while resetting flags: ' + e2);
        }
    }



    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id =: BC.getJobId()
        ];

        List < String > mailToAddresses = new List < String > ();
        List < Id > idList = new List < Id > ();
        Group g = [SELECT(select userOrGroupId from groupMembers) FROM group WHERE name = '2nd Line Support Group'];
        for (GroupMember gm: g.groupMembers) {
            idList.add(gm.userOrGroupId);
        }
        User[] usr = [SELECT email FROM user WHERE id IN: idList];
        for (User u: usr) {
            mailToAddresses.add(u.email);
        }
        // Send an email to the Apex job's submitter 
        //   notifying of job completion. 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(mailToAddresses);
        mail.setSubject('Customer List Monthly Job ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with ' + a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            mail
        });
    }

}