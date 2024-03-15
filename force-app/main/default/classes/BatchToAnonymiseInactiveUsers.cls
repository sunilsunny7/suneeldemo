/*
Created : Dec 2019
Retention and Purging 
Batch to anonymize user information deactivated some time ago as per given criteria.
*/


global class BatchToAnonymiseInactiveUsers implements Database.Batchable < sObject > {
    String query;
    Integer UserWithRelation;
    Integer UserWithoutRelation;
    Date uDate;
    String SystemAdmin;


    global Database.QueryLocator start(Database.BatchableContext BC) {
        UserWithoutRelation= Integer.ValueOf(Label.UserWithoutRelation);
        uDate = Date.Today() - UserWithoutRelation;
        SystemAdmin = SEUtility.PROFILE_SYS_ADMIN;
        //UserWithRelation = Integer.ValueOf(Label.UserWithRelation);
        // UserWithoutRelation = Integer.ValueOf(Label.UserWithoutRelation);
        if (Test.isRunningTest()) {
            query = 'Select Id,Deactivated_On__c,Email, FirstName,LastName from User where IsActive=false and Deactivated_On__c < : uDate AND Profile.Name!= :SystemAdmin AND FirstName!=\'XXXXXXX\' limit 10';
        } else {
            query = 'Select Id,Deactivated_On__c,Email, FirstName,LastName from User where IsActive=false and Deactivated_On__c < : uDate AND Profile.Name!= :SystemAdmin AND FirstName!=\'XXXXXXX\'';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List < User > scope) {
        List < User > userToAnonymize = new List < User > ();
        List < User > userUpdate = new List < User > ();
        UserWithRelation = Integer.ValueOf(Label.UserWithRelation);
        UserWithoutRelation = Integer.ValueOf(Label.UserWithoutRelation);
        Set < Id > usrIds = new Set < Id > ();
        for (User u: scope) {
            usrIds.add(u.Id);
        }

        List < Account > accs = new List < Account > ([Select Id, OwnerId, Cygate_Account_Manager__c, Personal_Advisor__c from Account where OwnerId IN: usrIds]);
        Set < Id > hasRelation = new Set < Id > ();
        for (Account a: accs) {
            hasRelation.add(a.OwnerId);
        }

        List < Account > accsCAM = new List < Account > ([Select Id, OwnerId, Cygate_Account_Manager__c, Personal_Advisor__c from Account where Cygate_Account_Manager__c IN: usrIds]);
        for (Account a: accsCAM) {
            hasRelation.add(a.Cygate_Account_Manager__c);
        }
        List < Account > accsPA = new List < Account > ([Select Id, OwnerId, Cygate_Account_Manager__c, Personal_Advisor__c from Account where Personal_Advisor__c IN: usrIds]);
        for (Account a: accsPA) {
            hasRelation.add(a.Personal_Advisor__c);
        }

        List < Opportunity > opps = new List < Opportunity > ([Select Id, OwnerId, Seller__c from Opportunity where OwnerId IN: usrIds]);
        for (Opportunity a: opps) {
            hasRelation.add(a.OwnerId);
        }

        List < Opportunity > oppsSel = new List < Opportunity > ([Select Id, OwnerId, Seller__c from Opportunity where Seller__c IN: usrIds]);
        for (Opportunity a: oppsSel) {
            hasRelation.add(a.Seller__c);
        }

        List < Contact > cons = new List < Contact > ([Select Id, OwnerId from Contact where OwnerId IN: usrIds]);
        for (Contact a: cons) {
            hasRelation.add(a.OwnerId);
        }




        List < Contract > cont = new List < Contract > ([Select Id, OwnerId from Contract where OwnerId IN: usrIds]);
        for (Contract a: cont) {
            hasRelation.add(a.OwnerId);
        }

        List < Case > cas = new List < Case > ([Select Id, OwnerId from Case where OwnerId IN: usrIds]);
        for (Case a: cas) {
            hasRelation.add(a.OwnerId);
        }
        List < Event > eve = new List < Event > ([Select Id, OwnerId from Event where OwnerId IN: usrIds]);
        for (Event a: eve) {
            hasRelation.add(a.OwnerId);
        }

        List < Task > tsk = new List < Task > ([Select Id, OwnerId from Task where OwnerId IN: usrIds]);
        for (Task a: tsk) {
            hasRelation.add(a.OwnerId);
        }

        List < Yearly_Target__c > yt = new List < Yearly_Target__c > ([Select Id, OwnerId from Yearly_Target__c where OwnerId IN: usrIds]);
        for (Yearly_Target__c a: yt) {
            hasRelation.add(a.OwnerId);
        }

        List < User_Performance__c > ut = new List < User_Performance__c > ([Select Id, OwnerId from User_Performance__c where OwnerId IN: usrIds]);
        for (User_Performance__c a: ut) {
            hasRelation.add(a.OwnerId);
        }

        List < Agreement_Situation__c > ats = new List < Agreement_Situation__c > ([Select Id, OwnerId from Agreement_Situation__c where OwnerId IN: usrIds]);
        for (Agreement_Situation__c a: ats) {
            hasRelation.add(a.OwnerId);
        }

        List < Campaign > cam = new List < Campaign > ([Select Id, OwnerId from Campaign where OwnerId IN: usrIds]);
        for (Campaign a: cam) {
            hasRelation.add(a.OwnerId);
        }

        List < Lead > ld = new List < Lead > ([Select Id, OwnerId from Lead where OwnerId IN: usrIds]);
        for (Lead l: ld) {
            hasRelation.add(l.OwnerId);
        }

        for (User u: scope) {
            if (hasRelation.contains(u.Id)) {
                if (u.Deactivated_On__c < (Date.Today() - UserWithRelation)) {
                    userToAnonymize.add(u);
                }
            }
            else
             {
                if (u.Deactivated_On__c < (Date.Today() - UserWithoutRelation)) {
                    userToAnonymize.add(u);
                }
            }


        }

        for (User usr: userToAnonymize) {

            try {
                System.UserManagement.obfuscateUser(usr.Id);
            } catch (Exception e) {
                system.debug('Exception Caught:' + e.getmessage());
            }

        }

       for (User uid: userToAnonymize) {
            uid.FirstName = 'XXXXXXX';
            uid.LastName = 'XXXXXXX';
           // String str = uid.Email;
           // String strr = str.replace('-', '0');
           // uid.Email = strr;
           // System.debug('uid' + uid);
            userUpdate.add(uid);
        }

        try {
            update userUpdate;
        } catch (Exception e) {
            system.debug('Exception Caught:' + e.getmessage());
        }

    }

    global void finish(Database.BatchableContext BC) {
         AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id =: BC.getJobId()
        ];

        // Send an email to the Apex job's submitter 
        //   notifying of job completion. 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {
            a.CreatedBy.Email
        };
        mail.setToAddresses(toAddresses);
        mail.setSubject('User Anonymize Job  ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with ' + a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            mail
        });
         
    
    }
}