/**
About
-----
Description: BatchAccountSegmention for Customer List
This is a monthly batch which updates the segmentation on Kundkonto if it is approved and also updates the related org with same segmentation values
This also updates the orgs with correct segmentation if its is reparented to some other org.
    
Create date: April 2020

Update History
--------------
August-2020:P.S - SALEF-3497 - Updated Recordtype assignment for new Business Units

Issues / TODOs
--------------     
*/
global class BatchAccountSegmention implements Database.Batchable < sObject > {

    public final String query;
    public final String oType;
    public Integer btchSize = Integer.ValueOf(Label.Segmentbatchsize);
    public Integer flgBtchSize = Integer.ValueOf(Label.FlagResetSize);
    public Integer hcBtchSize = Integer.ValueOf(Label.hasChildBatSize);
    Set < Id > kknrRecTypeIds = new Set < Id > {
        SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK),
        SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC1),
        SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC2)
    };
    public BatchAccountSegmention(String operation) {
        if (operation == 'reparent') {
            oType = 'reparent';
            //get all Orgs which are reparented(Is_Parent_Changed__c=true) and its parent's segmentation fields.
            query = 'SELECT Id,ParentId,Is_Owner_Changed__c,RecordTypeId,Is_Parent_Changed__c,Approved__c,Security_Category__c,Approve_Date__c,Business_Area__c,Suggested_Business_Area__c,Suggested_Parent__r.Business_Area__c,Parent.Suggested_Business_Area__c,Cust_Business_Unit__c,Business_Unit_Lvl1__c,Business_Unit_Lvl2__c,Business_Sales_Unit__c,Business_Unit__c,Sales_Team__c,DS__c,Account_Type__c,Industry,OwnerId,Suggested_Business_Unit__c,Suggested_SubBusinessUnitLvl1__c,Suggested_SubBusinessUnitLvl2__c,Suggested_Business_Sales_Unit__c,Suggested_Sales_Unit__c,Suggested_Sales_Team__c,Suggested_Delsegment__c,Suggested_Industry__c,Suggested_Account_Type__c,Suggested_Owner__c,Parent.Cust_Business_Unit__c,Parent.Business_Unit_Lvl1__c,Parent.Business_Unit_Lvl2__c,Parent.Business_Sales_Unit__c,Parent.Business_Unit__c,Parent.Sales_Team__c,Parent.DS__c,Parent.Industry,Parent.Account_Type__c,Parent.OwnerId,Parent.Approved__c,Parent.Suggested_Business_Unit__c,Parent.Suggested_SubBusinessUnitLvl1__c,Parent.Suggested_SubBusinessUnitLvl2__c,Parent.Suggested_Business_Sales_Unit__c,Parent.Suggested_Sales_Unit__c,Parent.Suggested_Sales_Team__c,Parent.Suggested_Delsegment__c,Parent.Suggested_Industry__c,Parent.Suggested_Account_Type__c,Parent.Suggested_Owner__c,Suggested_Parent__r.Cust_Business_Unit__c,Suggested_Parent__r.Business_Unit_Lvl1__c,Suggested_Parent__r.Business_Unit_Lvl2__c,Suggested_Parent__r.Business_Sales_Unit__c,Suggested_Parent__r.Business_Unit__c,Suggested_Parent__r.Sales_Team__c,Suggested_Parent__r.DS__c,Suggested_Parent__r.Industry,Suggested_Parent__r.Account_Type__c,Suggested_Parent__r.OwnerId,Suggested_Parent__r.Approved__c,Business_Unit_Code__c,Parent.Business_Unit_Code__c,Parent.Suggested_Business_Unit_Code__c,Suggested_Business_Unit_Code__c,Suggested_Parent__r.Business_Unit_Code__c FROM Account WHERE Is_Parent_Changed__c=true';
        } else if (operation == 'update') {
            oType = 'update';
            //get all Kundkonto which are Approved and its related Orgs accounts.
            query = 'SELECT Id,ParentId,Is_Owner_Changed__c,RecordTypeId,Is_Parent_Changed__c,Approved__c,Security_Category__c,Approve_Date__c,Business_Area__c,Suggested_Business_Area__c,Suggested_Parent__r.Business_Area__c,Parent.Suggested_Business_Area__c,Cust_Business_Unit__c,Business_Unit_Lvl1__c,Business_Unit_Lvl2__c,Business_Sales_Unit__c,Business_Unit__c,Sales_Team__c,DS__c,Account_Type__c,Industry,OwnerId,Suggested_Business_Unit__c,Suggested_SubBusinessUnitLvl1__c,Suggested_SubBusinessUnitLvl2__c,Suggested_Business_Sales_Unit__c,Suggested_Sales_Unit__c,Suggested_Sales_Team__c,Suggested_Delsegment__c,Suggested_Industry__c,Suggested_Account_Type__c,Suggested_Owner__c,Parent.Cust_Business_Unit__c,Parent.Business_Unit_Lvl1__c,Parent.Business_Unit_Lvl2__c,Parent.Business_Sales_Unit__c,Parent.Business_Unit__c,Parent.Sales_Team__c,Parent.DS__c,Parent.Industry,Parent.Account_Type__c,Parent.OwnerId,Parent.Approved__c,Parent.Suggested_Business_Unit__c,Parent.Suggested_SubBusinessUnitLvl1__c,Parent.Suggested_SubBusinessUnitLvl2__c,Parent.Suggested_Business_Sales_Unit__c,Parent.Suggested_Sales_Unit__c,Parent.Suggested_Sales_Team__c,Parent.Suggested_Delsegment__c,Parent.Suggested_Industry__c,Parent.Suggested_Account_Type__c,Parent.Suggested_Owner__c,Suggested_Parent__r.Cust_Business_Unit__c,Suggested_Parent__r.Business_Unit_Lvl1__c,Suggested_Parent__r.Business_Unit_Lvl2__c,Suggested_Parent__r.Business_Sales_Unit__c,Suggested_Parent__r.Business_Unit__c,Suggested_Parent__r.Sales_Team__c,Suggested_Parent__r.DS__c,Suggested_Parent__r.Industry,Suggested_Parent__r.Account_Type__c,Suggested_Parent__r.OwnerId,Suggested_Parent__r.Approved__c,Parent.Business_Unit_Code__c,Parent.Suggested_Business_Unit_Code__c,Suggested_Business_Unit_Code__c,Suggested_Parent__r.Business_Unit_Code__c FROM Account WHERE (Approved__c=true AND Kundkonto_Nr__c!=null) OR (Parent.Approved__c=true AND Org_Nr__c!=null)';
        } else if (operation == 'reset') {
            oType = 'reset';
            //reset the Approved checkbox on kundkonto accounts.
            query = 'SELECT Id,RecordTypeId, Approved__c FROM Account WHERE RecordTypeId IN :kknrRecTypeIds AND Approved__c =true';
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Get all the Kundkonto and its related orgs which are approved 
        // Get all the orgs and its parent which are reparented        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List < Account > scope) {
        List < vlocity_cmt__VlocityErrorLogEntry__c > exceptions = new List < vlocity_cmt__VlocityErrorLogEntry__c > ();
        Set<Id> accIds= new Set<Id>();
        List<AccountTeamMember> atmBefore= new List<AccountTeamMember>();

        for (Account acc: scope) {
            // Check if the record type of account is Kundkonto, Kundkonto Security account, if yes set segmentation with suggested segmentation
            if (oType != 'reset') {
                if ((acc.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK) || acc.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC1) || acc.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC2)) && acc.Approved__c == true && oType != 'reset') {
                    acc.Cust_Business_Unit__c = acc.Suggested_Business_Unit__c;
                    acc.Business_Area__c = acc.Suggested_Business_Area__c;
                    acc.Business_Unit_Lvl1__c = acc.Suggested_SubBusinessUnitLvl1__c;
                    acc.Business_Unit_Lvl2__c = acc.Suggested_SubBusinessUnitLvl2__c;
                    acc.Business_Unit_Code__c = acc.Suggested_Business_Unit_Code__c;
                    acc.Business_Sales_Unit__c = acc.Suggested_Business_Sales_Unit__c;
                    acc.Business_Unit__c = acc.Suggested_Sales_Unit__c;
                    acc.Sales_Team__c = acc.Suggested_Sales_Team__c;
                    acc.DS__c = acc.Suggested_Delsegment__c;
                    acc.Industry = acc.Suggested_Industry__c;
                    acc.Account_Type__c = acc.Suggested_Account_Type__c;
                    acc.OwnerId = acc.Suggested_Owner__c;
                    acc.Approve_Date__c = System.today();
                    accIds.add(acc.Id);
                    //acc.GESB_Flag_KKNR__c = true;
                }
                if (acc.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE) || acc.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME) || acc.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE_SEC1) || acc.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE_SEC2)) {

                    acc.GESB_Flag_Org__c = true; // this flag should be set for all orgs which is  updated via this batch in order for gesb to fetch it. 
                    //It will be reset to false by GESB.

                    //if reparented
                    if (acc.Is_Parent_Changed__c == true) {
                        //If suggested parent is approved for segmentation change, just reparent.
                        if (acc.Suggested_Parent__r.Approved__c == true) {
                            acc.ParentId = acc.Suggested_Parent__c;
                            acc.Approve_Date__c = System.today();
                            acc.Is_Parent_Changed__c = false;

                        } else {
                            // if suggested parent is not approved for change in segmentation set Actual or existing segmentation of Kunkonto to Org Segmentation.
                            acc.Cust_Business_Unit__c = acc.Suggested_Parent__r.Cust_Business_Unit__c;
                            acc.Business_Area__c = acc.Suggested_Parent__r.Business_Area__c;
                            acc.Business_Unit_Lvl1__c = acc.Suggested_Parent__r.Business_Unit_Lvl1__c;
                            acc.Business_Unit_Lvl2__c = acc.Suggested_Parent__r.Business_Unit_Lvl2__c;
                            acc.Business_Sales_Unit__c = acc.Suggested_Parent__r.Business_Sales_Unit__c;
                            acc.Business_Unit_Code__c = acc.Suggested_Parent__r.Business_Unit_Code__c;
                            acc.Business_Unit__c = acc.Suggested_Parent__r.Business_Unit__c;
                            acc.Sales_Team__c = acc.Suggested_Parent__r.Sales_Team__c;
                            acc.DS__c = acc.Suggested_Parent__r.DS__c;
                            acc.Industry = acc.Suggested_Parent__r.Industry;
                            acc.Account_Type__c = acc.Suggested_Parent__r.Account_Type__c;
                            if (acc.OwnerId != acc.Suggested_Parent__r.OwnerId) {
                                acc.Is_Owner_Changed__c = System.today();
                                accIds.add(acc.Id);
                            }
                            acc.OwnerId = acc.Suggested_Parent__r.OwnerId;
                            acc.ParentId = acc.Suggested_Parent__c;
                            acc.Suggested_Business_Unit__c = acc.Suggested_Parent__r.Cust_Business_Unit__c;
                            acc.Suggested_Business_Area__c = acc.Suggested_Parent__r.Business_Area__c;
                            acc.Suggested_SubBusinessUnitLvl1__c = acc.Suggested_Parent__r.Business_Unit_Lvl1__c;
                            acc.Suggested_SubBusinessUnitLvl2__c = acc.Suggested_Parent__r.Business_Unit_Lvl2__c;
                            acc.Suggested_Business_Sales_Unit__c = acc.Suggested_Parent__r.Business_Sales_Unit__c;
                            acc.Suggested_Sales_Unit__c = acc.Suggested_Parent__r.Business_Unit__c;
                            acc.Suggested_Sales_Team__c = acc.Suggested_Parent__r.Sales_Team__c;
                            acc.Suggested_Delsegment__c = acc.Suggested_Parent__r.DS__c;
                            acc.Suggested_Owner__c = acc.Suggested_Parent__r.OwnerId;

                            acc.Approve_Date__c = System.today();
                            acc.Customer_Information_Changed__c = false; //reset

                            if (acc.Suggested_Parent__r.Cust_Business_Unit__c == 'SME' || acc.Suggested_Parent__r.Cust_Business_Unit__c == 'Enterprise Other' && acc.RecordTypeId != SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME) && acc.Security_Category__c == null) {
                                acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
                            }
                            if (acc.Suggested_Parent__r.Cust_Business_Unit__c == 'Large Business' || acc.Suggested_Parent__r.Cust_Business_Unit__c == 'Public & Key' && acc.RecordTypeId != SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE) && acc.Security_Category__c == null) {
                                acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
                            }

                        }
                    } else if (acc.Parent.Approved__c == true) {
                        //set kundkoto suggested segmentation fields to org existing and suggested segmentation fields
                        acc.Cust_Business_Unit__c = acc.Parent.Suggested_Business_Unit__c;
                        acc.Business_Area__c = acc.Parent.Suggested_Business_Area__c;
                        acc.Business_Unit_Lvl1__c = acc.Parent.Suggested_SubBusinessUnitLvl1__c;
                        acc.Business_Unit_Lvl2__c = acc.Parent.Suggested_SubBusinessUnitLvl2__c;
                        acc.Business_Unit_Code__c = acc.Parent.Suggested_Business_Unit_Code__c;
                        acc.Business_Sales_Unit__c = acc.Parent.Suggested_Business_Sales_Unit__c;
                        acc.Business_Unit__c = acc.Parent.Suggested_Sales_Unit__c;
                        acc.Sales_Team__c = acc.Parent.Suggested_Sales_Team__c;
                        acc.DS__c = acc.Parent.Suggested_Delsegment__c;
                        acc.Industry = acc.Parent.Suggested_Industry__c;
                        acc.Account_Type__c = acc.Parent.Suggested_Account_Type__c;
                        if (acc.OwnerId != acc.Parent.Suggested_Owner__c) {
                            acc.Is_Owner_Changed__c = System.today();
                            accIds.add(acc.Id);
                        }
                        acc.OwnerId = acc.Parent.Suggested_Owner__c;
                        acc.Approve_Date__c = System.today();
                        acc.Customer_Information_Changed__c = false;

                        //for orgs which have changed suggested parent but not approved, this is check to avoid overwriting suggested segmentation values changed by trigger, 
                        if (acc.ParentId == acc.Suggested_Parent__c) {
                            acc.Suggested_Business_Unit__c = acc.Parent.Suggested_Business_Unit__c;
                            acc.Suggested_Business_Area__c = acc.Parent.Suggested_Business_Area__c;
                            acc.Suggested_SubBusinessUnitLvl1__c = acc.Parent.Suggested_SubBusinessUnitLvl1__c;
                            acc.Suggested_SubBusinessUnitLvl2__c = acc.Parent.Suggested_SubBusinessUnitLvl2__c;
                            acc.Suggested_Business_Sales_Unit__c = acc.Parent.Suggested_Business_Sales_Unit__c;
                            acc.Suggested_Sales_Unit__c = acc.Parent.Suggested_Sales_Unit__c;
                            acc.Suggested_Sales_Team__c = acc.Parent.Suggested_Sales_Team__c;
                            acc.Suggested_Delsegment__c = acc.Parent.Suggested_Delsegment__c;
                            acc.Suggested_Owner__c = acc.Parent.Suggested_Owner__c;
                        }
                        //Set record type based on Business Unit
                        if (acc.Parent.Suggested_Business_Unit__c == 'SME' || acc.Parent.Suggested_Business_Unit__c == 'Enterprise Other' && acc.RecordTypeId != SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME)) {
                            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
                        }
                        if (acc.Parent.Suggested_Business_Unit__c == 'Large Business' || acc.Parent.Suggested_Business_Unit__c == 'Public & Key' && acc.RecordTypeId != SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE)) {
                            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
                        }
                    }


                }
            }
            if (oType == 'reset') {
                if (acc.Approved__c = true) {
                    acc.Approved__c = false;
                    acc.Approved_By_Time__c = '';
                    acc.Customer_Information_Changed__c = false;
                }
            }


        }
        if(accIds.size()>0){
            atmBefore=[select AccountAccessLevel, AccountId, CaseAccessLevel, ContactAccessLevel, OpportunityAccessLevel, UserId, TeamMemberRole from AccountTeamMember where AccountId IN : accIds AND TeamMemberRole like '%Cygate%'];
    }
        
        try {
            database.update(scope);
        } catch (Exception e) {
            System.debug('Exception while executing the Segmentation batch job: ' + e);
            vlocity_cmt__VlocityErrorLogEntry__c v1 = new vlocity_cmt__VlocityErrorLogEntry__c();
            v1.vlocity_cmt__ErrorType__c = 'Exception';
            v1.vlocity_cmt__ErrorMessage__c = String.valueOf(e.getmessage());
            v1.vlocity_cmt__SourceName__c = 'BatchAccountSegmention';
            v1.vlocity_cmt__ObjectName__c = 'Account';
            exceptions.add(v1);
        }

        List<AccountTeamMember> toInsert= new List<AccountTeamMember>();
        if(atmBefore.size()>0){
            for(AccountTeamMember atm: atmBefore){
                AccountTeamMember a= new AccountTeamMember();
                a.AccountId = atm.AccountId;
                a.TeamMemberRole = atm.TeamMemberRole;
                a.UserId = atm.UserId;
                toInsert.add(a);

            }
        }
        if(toInsert.size()>0){

            try {
                database.insert(toInsert);
            } catch (Exception e) {
                System.debug('Exception while executing the Segmentation batch job: ' + e);
                vlocity_cmt__VlocityErrorLogEntry__c v2 = new vlocity_cmt__VlocityErrorLogEntry__c();
                v2.vlocity_cmt__ErrorType__c = 'Exception';
                v2.vlocity_cmt__ErrorMessage__c = String.valueOf(e.getmessage());
                v2.vlocity_cmt__SourceName__c = 'BatchAccountSegmention';
                v2.vlocity_cmt__ObjectName__c = 'Account';
                exceptions.add(v2);
            }
        }


        if (exceptions.size() > 0) {
            try {
                insert exceptions;
            } catch (Exception e) {
                system.debug('Exception Caught:' + e.getmessage());
            }
        }

    }


    public void finish(Database.BatchableContext BC) {
        List < vlocity_cmt__VlocityErrorLogEntry__c > exceptionsCheck = [Select Id from vlocity_cmt__VlocityErrorLogEntry__c where CreatedDate >=: System.today() AND vlocity_cmt__SourceName__c = 'BatchAccountSegmention'];
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
        if (exceptionsCheck.size() > 0) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(mailToAddresses);
            mail.setSubject('Customer List Monthly Job ' + a.Status);
            mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
                ' batches with ' + a.NumberOfErrors + ' failures ' + exceptionsCheck.size() + ' Exceptions.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                mail
            });
        } else {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setToAddresses(mailToAddresses);
            mail.setSubject('Customer List Monthly Job ' + a.Status);
            mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
                ' batches with ' + a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                mail
            });
        }
        if(!Test.IsRunningtest()){
            if (oType == 'reparent') {
                System.debug('update segmentation');
                ID batchProcessId = Database.executeBatch(new BatchAccountSegmention('update'), btchSize);
            }
            if (oType == 'update') {
                System.debug('reset flags');
                ID batchProcessId = Database.executeBatch(new BatchAccountSegmention('reset'), flgBtchSize);
                //System.debug('BatchAccountSegmentation FINNISH');
            }
            if (oType == 'reset') {
                System.debug('haschild');
                ID batchProcessId = Database.executeBatch(new BatchAccHasChildUpdate(), hcBtchSize);
                //System.debug('BatchAccountSegmentation FINNISH');
            }
        }
    }
}