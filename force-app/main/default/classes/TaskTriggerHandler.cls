/**
About
-----
Description: TaskTriggerHandler on Task

Update History
--------------

Create date: 2016-03-23
Created Mar 2016 - N.G Created
Updated Sep 2016 - A.N Functionality from TaskBeforeInsert, TaskAfterInsert and TaskBeforeUpdate has been refactored and merged into this class
Updated Sep 2016 - V.M The PR methods and functionality
Updated Sep 2016 - A.N New methods updateOpportunityOnTask and updateCampaignOnTask created
Updated Oct 2016 - P.P Case 2090 Changed Error for Tasks Related to Other Termimnated Account so that it does not show up for PR profiles
Updated June 2016 - P.P Case 3094 Added method updateContactActivities
29.12.2022 [Tomass Brazovskis] SALEF-7949 - Account 'Contacted Quality Meeting' value might have to be updated upon 'Quality Meeting'-type 
            'Log a Call' Activity closure. updateAccountContactedDate() refactored and moved to be invoked OnAfterUpdate instead of OnBeforeUpdate.
Issues / TODOs
--------------

Replace error messages in validation methods with custom labels.

*/

public class TaskTriggerHandler {

    private Boolean m_isExecuting = false;
    private Integer BatchSize = 0;
    Boolean deleteInstance = False;
    Boolean insertInstance = False;
    Boolean updateInstance = False;

    public TaskTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnBeforeInsert(List<Task> newList, Map<ID, Task> newMap){
        System.debug('TaskTriggerHandler.OnBeforeInsert starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        validateContactIsActive(newList);
        validateAccountNotTerminated(newList);
        updateOpportunityOnTask(newList, null);
        updateCampaignOnTask(newList, null);
    }

    public void OnAfterInsert(List<Task> newList, Map<ID, Task> newMap){
        System.debug('TaskTriggerHandler.OnAfterInsert starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        updateAccountContactedDate(newList, null);
        setAccountCSBContactedDate(newList, null);
        updateCampaignMemberStatuses(newList);

        PerformanceUtils.updateYearlyTaskScore(newList);
        PerformanceUtils.checkSambesokForTask(newList);

        PR_setPrNotInterested(newList);
        PR_addContactToCampaign(PR_validateHasAccountContact(newList));
        deleteInstance = False;
        insertInstance = True;
        updateContactActivities(newList,null,insertInstance,deleteInstance);
        updateSalesResponseTimeOnBI(newList);
    }

    public void OnBeforeUpdate(List<Task> newList, Map<ID, Task> newMap, List<Task> oldList, Map<ID, Task> oldMap){
        System.debug('TaskTriggerHandler.OnBeforeUpdate starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        updateOpportunityOnTask(newList, oldMap);
        updateCampaignOnTask(newList, oldMap);
        setAccountCSBContactedDate(newList, oldMap);
    }

    public void OnAfterUpdate(List<Task> newList, Map<ID, Task> newMap, List<Task> oldList, Map<ID, Task> oldMap){
        System.debug('TaskTriggerHandler.OnAfterUpdate starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        PerformanceUtils.updateYearlyTaskScore(newList);
        PerformanceUtils.checkSambesokForTask(newList);
        updateAccountContactedDate(newList, oldMap); // SALEF-7949 - Moved from OnBeforeUpdate          

        PR_setPrNotInterested(newList);
        PR_addContactToCampaign(PR_validateHasAccountContact(newList));

        deleteInstance = False;
        insertInstance = False;
        updateContactActivities(newList,oldMap,InsertInstance,deleteInstance);
    }

    public void OnAfterDelete(List<Task> oldList, Map<ID, Task> oldMap){
        System.debug('TaskTriggerHandler.OnAfterDelete starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        PerformanceUtils.updateYearlyTaskScore(oldList);
        deleteInstance = True;
        insertInstance = False;
        updateContactActivities(oldList,oldMap, insertInstance,deleteInstance);
    }

    //CampaignMember Status
    public static final String PR_CAMPAIGN_STATUS = 'Ringt';

    //Call Activity Call Status values
    public static final String STATUS_CONTACTED = 'Kontaktad';
    public static final String STATUS_WILL_CONTACT = 'Ska kontaktas';

    // TASK PICKLIST STRING DEFINITIONS
    // Status Picklist
    public static final String STATUS_CLOSED = 'Stängd';
    public static final String STATUS_OPEN = 'Öppen';

    // Type Picklist
    public static final String TYPE_PHONE = 'Telefon';
    public static final String TYPE_PHYSICAL = 'Fysiskt';
    public static final String TYPE_WEB = 'Web';
    public static final String TYPE_APSIS = 'Apsis';

    // Subject Picklist
    public static final String SUBJECT_CALL = 'Call';

    //SME Task Type Picklist values
    public static final String TYPE_SALES = 'Säljuppföljning';
    public static final String TYPE_NEXT = 'Nästa steg';
    public static final String TYPE_MYBUSINESS = 'Genomgång MyBusiness';

    // Validate that contact related to the new task is not set as inactive
    private static void validateContactIsActive(List<Task> newList){
        Set<Id> whoIds = new Set<Id>();

        for(Task t : newList){
            whoIds.add(t.WhoId);
        }

        if(!whoIds.isEmpty()){
            // Create a map over all contacts related to the new Tasks by querying the whoId's
            Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id, Inaktiv__c from Contact where Id in :whoIds]);

            // If inactive contact, the Task should not be saved. An error message will be presented to the user.
            for (Task t : newList){
                Contact con = contactMap.get(t.WhoId);
                if(con != null && con.Inaktiv__c){
                    t.addError(Label.Task_Validation_Contact_Inactive_Error_Message);
                }
            }
        }
    }

    // Validate that parent account for the account related to the new task is not terminated
    private static void validateAccountNotTerminated(List<Task> newList){
        Set<Id> whatIds = new Set<Id>();
        Id uProfileId = UserInfo.getProfileId();
        Id uUserId = UserInfo.getUserId();

        User u = new User(Id = uUserId);
        u.ProfileId = uProfileId;

        for (Task t : newList){
            whatIds.add(t.WhatId);
        }

        if(!whatIds.isEmpty()){
            // Query for Parent Account which needs to be blocked for Task Creation
            Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, Parent.Kundkonto_Nr__c from Account WHERE Id IN: whatIds]);
            String accRef = Label.Account_to_Bypass_for_Tasks;

            // If terminated account, the Task should not be saved. An error message will be presented to the user.
            for (Task t : newList){
                Account acc = accountMap.get(t.WhatId);
                if(acc != null && acc.Parent != null && (acc.Parent.Kundkonto_Nr__c == accRef && !SEUtility.isPRUser(u))){
                    t.addError(Label.Task_Validation_Account_Terminated_Error_Msg);
                }
            }
        }
    }

    // Author A.N: Update the task.Opportunity lookup field if the WhatId is an opportunity
    private static void updateOpportunityOnTask(List<Task> newList, Map<ID, Task> oldMap){
        String oppPrefix = Opportunity.sObjectType.getDescribe().getKeyPrefix();

        for(Task t : newList){
            // If insert, update task.Opportunity field if WhatId is Opportunity
            if(oldMap == null && t.WhatId != null && String.valueOf(t.WhatId).substring(0,3) == oppPrefix){
                t.Opportunity__c = t.WhatId;
            } else if(oldMap != null && t.WhatId != oldMap.get(t.Id).WhatId){
                // If update, check if the WhatId has changed. If yes, check whether or not the new WhatId is an opportunity.
                if(t.WhatId == null || String.valueOf(t.WhatId).substring(0,3) != oppPrefix){
                    t.Opportunity__c = null;
                } else {
                    t.Opportunity__c = t.WhatId;
                }
            }
        }
    }

    // Author A.N: Update the task.Campaign lookup field:
    // - if the WhatId is a campaign, set this as the Campaign lookup field
    // - if the WhatId is an opportunity and opportunity.CampaignId is not null, set this as the Campaign lookup field
    private static void updateCampaignOnTask(List<Task> newList, Map<ID, Task> oldMap){
        String campPrefix = Campaign.sObjectType.getDescribe().getKeyPrefix();
        String oppPrefix = Opportunity.sObjectType.getDescribe().getKeyPrefix();
        List<Task> setCampaignFromOppList = new List<Task>();
        Set<Id> oppIds = new Set<Id>();

        for(Task t : newList){
            if(oldMap == null && t.WhatId != null ){
                // If insert, update task.Campaign field if WhatId is Campaign
                if(String.valueOf(t.WhatId).substring(0,3) == campPrefix && !(t.recordtypeId == SEUtility.getRecordTypeId(SEUtility.TASK_REC_TYPE_SME) && t.subject.contains('updated to Mail Klickat')) ){
                    t.Campaign__c = t.WhatId;
                } else if(t.Opportunity__c != null){
                    setCampaignFromOppList.add(t);
                    oppIds.add(t.Opportunity__c);
                }
            } else if(oldMap != null && t.WhatId != null && t.WhatId != oldMap.get(t.Id).WhatId){ // If update, check if the WhatId has changed.
                // If the new WhatId is Campaign set this as task.Campaign
                if(String.valueOf(t.WhatId).substring(0,3) == campPrefix){
                    t.Campaign__c = t.WhatId;
                    // If the new WhatId is Opportunity as task.Campaign based on Opportunity Campaign
                } else if(String.valueOf(t.WhatId).substring(0,3) == oppPrefix){
                    setCampaignFromOppList.add(t);
                    oppIds.add(t.Opportunity__c);
                }
            }
        }

        if(!setCampaignFromOppList.isEmpty()){
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, CampaignId FROM Opportunity WHERE Id in :oppIds]);
            for(Task t : setCampaignFromOppList){
                Opportunity opp = oppMap.get(t.Opportunity__c);
                if(opp != null && opp.CampaignId != null){
                    t.Campaign__c = opp.CampaignId;
                }
            }
        }
    }

    /**
     * @Description:
     * If a 'Log a Call' Activity has been closed, its parent Account 'Contacted..' field values might have
     * to be updated to the closed Activity's 'Due Date'.
     * @author V.I.
     * @param newList - List of Tasks after update
     * @param oldMap - Map of Task Ids to the pre-update Task versions
     * @Modifications:
     * 29.12.2022 [TB] SALEF-7949 - Account 'Contacted Quality Meeting' value might have to be updated upon
     *              'Quality Meeting'-type 'Log a Call' Activity closure. Method refactored.
     * 09.06.2022 [Mantas Brazionis] SALEF-6821 - Accommodate for the replacement of the "SME Task Type" picklist
     *              value with the "Review MyBusiness" checkbox.
     * 11.2021 [Aurimas Nausutis] SALEF-5324 - Account 'SME: Contacted MyBusiness' value might have to be updated 
     *          upon 'Review MyBusiness'-type 'Log a Call' Activity closure.
     * 03.2015 [V.I.] - Introduced. Check if task has been closed, if so we might need to update the Contacted__c
     *          field on the related account.
     **/
    @TestVisible
    private static void updateAccountContactedDate(List<Task> newList, Map<ID, Task> oldMap) {
        // Account 'Contacted...' fields that might require update
        String ACCOUNT_FIELD_API_NAME_CONTACTED = SEUtility.ACCOUNT_FIELD_API_NAME_CONTACTED;
        String ACCOUNT_FIELD_API_NAME_SME_CONTACTED_MB = SEUtility.ACCOUNT_FIELD_API_NAME_SME_CONTACTED_MB;
        String ACCOUNT_FIELD_API_NAME_CONTACTED_QUALITY_MEETING = SEUtility.ACCOUNT_FIELD_API_NAME_CONTACTED_QUALITY_MEETING;
        
        Map<Id, Map<String, Date>> mapAccIdsToMapContactedFieldNamesToDates = new Map<Id, Map<String, Date>>();
        // Check whether 'Log a Call' Activity update might have to trigger parent Account 'Contacted...' field value updates
        for(Task curTask : newList){
            if( (curTask.AccountId != null || curTask.Account__c != null)
                && curTask.Status != null 
                && curTask.Type != null
            ){
                // 'Log a Call' Activity 'Status' is set to 'Stängd' (Closed) by default
                if( curTask.Status == STATUS_CLOSED
                    && (oldMap == null || (oldMap != null && oldMap.get(curTask.Id).Status != STATUS_CLOSED))
                ){
                    // 'Log a Call' Activity 'Due Date' is set to its creation day (TODAY()) by default
                    // SALEF-7949 - System.now() replaced by System.today() to ensure consistency, as both TODAY()
                    // and System.today() are calculated in User's time zone, while System.today() - in GMT time zone
                    Date curTaskDueDate = (curTask.ActivityDate != null) ? curTask.ActivityDate : System.today();
                    Map<String, Date> mapContactedFieldNamesToDates = new Map<String, Date>();
                    if ((curTask.Type == TYPE_PHONE || curTask.Type == TYPE_PHYSICAL || curTask.Type == TYPE_WEB) 
                        && curTask.SME_Task_Type__c != TYPE_SALES 
                        && curTask.SME_Task_Type__c != TYPE_NEXT
                    ){
                        mapContactedFieldNamesToDates.put(ACCOUNT_FIELD_API_NAME_CONTACTED, curTaskDueDate);
                    }
                    // SALEF-5324 - Account 'SME: Contacted MyBusiness' check required
                    if(curTask.Review_MyBusiness__c){ // SALEF-6821
                        mapContactedFieldNamesToDates.put(ACCOUNT_FIELD_API_NAME_SME_CONTACTED_MB, curTaskDueDate);
                    }
                    // SALEF-7949 - Account 'Contacted Quality Meeting' check required
                    if(curTask.Quality_Meeting__c){
                        mapContactedFieldNamesToDates.put(ACCOUNT_FIELD_API_NAME_CONTACTED_QUALITY_MEETING, curTaskDueDate);
                    }
                    if(!mapContactedFieldNamesToDates.isEmpty()){
                        mapAccIdsToMapContactedFieldNamesToDates.put(   (curTask.AccountId != null) ? curTask.AccountId : curTask.Account__c,
                                                                            mapContactedFieldNamesToDates); 
                    }
                }
            }
        }
        // Check whether 'Log a Call' Activity closure should change any parent Account values 
        if(!mapAccIdsToMapContactedFieldNamesToDates.isEmpty()){
            List<Account> lstAccountsToUpdate = SEUtility.getAccountsWithContactedDatesToUpdate(mapAccIdsToMapContactedFieldNamesToDates);
            if(lstAccountsToUpdate != null && !lstAccountsToUpdate.isEmpty()){
                update lstAccountsToUpdate;
            }
        }
    }

    private static void setAccountCSBContactedDate(List<Task> newList, Map<Id,Task> oldMap) {
        Map<Id, DateTime> accountsWithDates = new Map<Id, DateTime>();

        if (isFiberUser()) {
            for (Task task : newList) {
                if (task.AccountId != null) {
                    accountsWithDates.put(task.AccountId, System.now());
                }
            }
            if (!accountsWithDates.isEmpty()) {
                List<Account>accountsToUpdate = new List<Account>();
                for (Account acc : [SELECT Id, C_SB_Contacted__c FROM Account WHERE Id IN :accountsWithDates.keySet()]) {
                    if(acc.C_SB_Contacted__c == null || acc.C_SB_Contacted__c < accountsWithDates.get(acc.Id).date()){
                        acc.C_SB_Contacted__c = accountsWithDates.get(acc.Id).date();
                        accountsToUpdate.add(acc);
                    }
                }
                if(!accountsToUpdate.isEmpty()) {
                    update accountsToUpdate;
                }
            }
        }
    }

    // If task type is 'Call' and it is connected to a contact and related to a campaign, update Campaign member statuses.
    private static void updateCampaignMemberStatuses(List<Task> newList){
        //Retrieve the object prefix for Campaign
        String campObjPrefix = Campaign.sObjectType.getDescribe().getKeyPrefix();
        Set<Id> conIds = new Set<Id>(); // Contact Ids
        Set<Id> campIds = new Set<Id>(); // Campaign Ids

        for(Task t : newList){
            // If the task is connected to a contact AND of type Call AND it relates to a Campaign-> Add the id of the task to a set
            if(t.WhoId != null && t.WhatId != null && t.Subject != null){
                if(t.Subject == SUBJECT_CALL && String.valueOf(t.WhatId).substring(0,3) == campObjPrefix){
                    // If the campaign is a Phone Campaign
                    conIds.add(t.WhoId);
                    campIds.add(t.WhatId);
                }
            }
        }

        // If there are more than zero related contacts to the tasks of type call
        if(conIds.size() != 0){
            // List all the CampaignMembers
            List<CampaignMember> cmList = [SELECT Id, Campaign.Type, Campaign.RecordTypeId FROM CampaignMember WHERE campaign.isActive = true AND (Campaign.Type = :TYPE_PHONE OR Campaign.Type = :TYPE_APSIS) AND ContactId IN :conIds AND CampaignId IN :campIds];
            for(CampaignMember cm : cmList){

                //Get the first
                Campaign_Member_Statuses__c cms = SEUtility.getCampaignMemberStatus(cm.Campaign.Type, cm.Campaign.RecordTypeId);
                if(cms == null) continue; // No custom setting found, skipping to the next itereation of the for loop
                if(cms.Status_1_Responded__c) cm.Status = cms.Status_1_Name__c;
                if(cms.Status_2_Responded__c) cm.Status = cms.Status_2_Name__c;
                if(cms.Status_3_Responded__c) cm.Status = cms.Status_3_Name__c;
                if(cms.Status_4_Responded__c) cm.Status = cms.Status_4_Name__c;
                if(cms.Status_5_Responded__c) cm.Status = cms.Status_5_Name__c;
                if(cms.Status_6_Responded__c) cm.Status = cms.Status_6_Name__c;
                if(cms.Status_7_Responded__c) cm.Status = cms.Status_7_Name__c;
                if(cms.Status_8_Responded__c) cm.Status = cms.Status_8_Name__c;
            }

            if(!cmList.isEmpty()){
                update cmList;
            }
        }
    }

    //Adds selected Contacts to Campaign
    private static void PR_addContactToCampaign(Map<Id, Task> newMap){

        //TaskId, CallActivityId
        Map<Id, Id> taskCallActivityMap = new Map<Id, Id>();
        Map<Id, Task> prFilteredMap = new Map<Id, Task>();

        //If the task matches the criteria of being from PR and PR Call Status set to true
        for(Task t : newMap.values()){
            if(t.Call_Activity__c != null && t.Call_Status__c == STATUS_CONTACTED && t.Status == STATUS_CLOSED && t.PR_Not_Interested__c != True){
                prFilteredMap.put(t.Id, t);
                taskCallActivityMap.put(t.id, t.Call_Activity__c);
            }
        }

        //Map Call Activity to the Campaign
        //CallActivityId, CampaignId
        Map<Id, Id> callActiCampMap = new Map<Id, Id>();
        if(!taskCallActivityMap.isEmpty()){
            for(Call_Activity__c ca :[SELECT Campaign__c, Id FROM Call_Activity__c WHERE ID IN :taskCallActivityMap.values()]){
                callActiCampMap.put(ca.Id, ca.Campaign__c);
            }
        }
        if(!prFilteredMap.isEmpty() && !callActiCampMap.isEmpty()){

            //ContactId, Contact
            Map<Id, Contact> addedContacts = new Map<Id, Contact>();

            //RelationId , TaskId
            Map<Id, Id> taskRelations = new Map<Id, Id>();
            for(TaskRelation tr : [SELECT RelationId, TaskId FROM TaskRelation WHERE TaskId IN :prFilteredMap.keySet() AND IsWhat = False]){
                taskRelations.put(tr.RelationId, tr.TaskId);
            }

            if(!taskRelations.isEmpty()){
                //Find all added contacts
                for(Contact c :[Select Id FROM Contact WHERE Id IN :taskRelations.keySet()]){
                    addedContacts.put(c.Id, c);
                }
                //Remove them from the addedContact list if they are already a campaign member
                for(CampaignMember cm : [SELECT ContactId FROM CampaignMember WHERE ContactId IN :addedContacts.keyset() AND CampaignId IN :callActiCampMap.values()]){
                    if(addedContacts.containsKey(cm.ContactId)){
                        addedContacts.remove(cm.ContactId);
                    }
                }
            }
            if(!addedContacts.isEmpty()){
                List<CampaignMember> campaignMemberList = new List<CampaignMember>();

                //For each contact we want to add to the campaign
                for(Id cId  :addedContacts.keySet()){
                    CampaignMember cm = new CampaignMember();
                    cm.ContactId = cId;

                    //To make sure that this code works even if we would update contacts related to two different campaigns we need to map what contact belongs to what campaign
                    cm.CampaignId =  callActiCampMap.get(taskCallActivityMap.get(taskRelations.get(cId)));
                    cm.Status = PR_CAMPAIGN_STATUS;

                    campaignMemberList.add(cm);
                }

                //Add the rest as CampaignMember
                insert campaignMemberList;
            }
        }
    }

    //Validates the Contacts to fulfill the critera for PR
    private static Map<Id, Task> PR_validateHasAccountContact(List<Task> newList){
        //Map containing validated Tasks
        Map<Id, Task> validatedTasks = new Map<Id, Task>();

        List<Task> prTasks = new List<Task>();

        //Check if it's PR task and if WhoId is not Empty
        for(Task t : newList){
            if(t.Call_Activity__c != null && t.Call_Status__c == STATUS_CONTACTED && t.Status == STATUS_CLOSED && t.PR_Not_Interested__c != True){
                //If no contacted added, validation error
                if(t.WhoId == null){
                    t.addError(Label.caValidationLogContact);
                }else{
                    //else add to PRtasks
                    prTasks.add(t);
                }
            }
        }

        if(!prTasks.isEmpty()){
            //Get CallActivities and map them to Tasks so we can see which Call Activity belongs to the Task
            //CallActivityId, TaskId
            Map<Id, Id> callActivityTaskMap = new Map<Id, Id> ();
            for(Task t : prTasks){
                callActivityTaskMap.put(t.Call_Activity__c, t.Id);
            }

            //Get the Account from the Call Activity to check if it matches the selected Contacts Account
            //AccountId, CallActivityId
            Map<Id, Id> callActivityAccountMap = new Map<Id, Id>();
            for(Call_Activity__c ca :[SELECT Id, Account__c FROM Call_Activity__c WHERE ID IN :callActivityTaskMap.keySet()]){
                callActivityAccountMap.put(ca.Id, ca.Account__c);
            }

            //Here we check if the Call Activity Account is the same as task AccountId, which is set by selected Contact (Internal Salesforce Logic)
            for(Task t : prTasks){
                if(callActivityAccountMap.get(t.Call_Activity__c) != t.AccountId){
                    t.addError(Label.caValidationAccountMismatch);
                }else{
                    validatedTasks.put(t.Id, t);
                }
            }
        }

        //We return the validated Tasks
        return validatedTasks;
    }

    //Updates the Call Activity if PR not interested is set
    private static void PR_setPrNotInterested(List<Task> newList){
        Set<Id> caSet = new Set<Id>();

        for(Task t : newList){
            if(t.Call_Activity__c != null && t.Status == STATUS_CLOSED && t.PR_Not_Interested__c == True){
                caSet.add(t.Call_Activity__c);
            }
        }
        if(!caSet.isEmpty()){
            List<Call_Activity__c> caList = new List<Call_Activity__c>();

            for(Call_Activity__c ca : [SELECT Id, Is_PR_Not_Interested__c FROM Call_Activity__c WHERE Id IN :caSet AND Is_PR_Not_Interested__c = FALSE]){
                ca.Is_PR_Not_Interested__c = true;
                caList.add(ca);
            }

            if(!caList.isEmpty()){
               update caList;
            }
        }
    }


    //method to mark Activities related to user group on Contacts
    public static void updateContactActivities(List<Task> taskList, Map<Id,Task> oldMap,Boolean isInsert,Boolean isDelete){

        Schema.DescribeSObjectResult contactDescribe = Contact.sObjectType.getDescribe();
        string contactPrefix = contactDescribe.getKeyPrefix();
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        List<Id> contactIdList = new List<Id>();
        Map<Id,Set<String>> contactSegmentMap = new Map<Id,Set<String>>();
        Map<Id,Set<String>> contactTaskSegmentMap = new Map<Id,Set<String>>();
        Set<Id> taskSet = new Set<Id>();
        List<TaskWhoRelation> TWRList = new List<TaskWhoRelation>();
        Boolean booleanupdate = False;
        List<Contact> contactUpdateList = new List<Contact>();
        Map<Id,Task> taskRelationMap = new Map<Id,Task>();
        Map<Id,String> roleSegmentMap = new Map<Id,String>();

        for(Contact_Management_Role_Set__c crms : Contact_Management_Role_Set__c.getAll().Values()){
            roleSegmentMap.put(crms.Role_Id__c,crms.Segment__c);
        }
        //can use this instead of following
        //if(recEvent.WhoId.getSObjectType() == Contact.sObjectType)
        for(task t:taskList){
            //works for insert statements
            if(isInsert == True){
                if(t.WhoId != Null){
                    if(string.valueof(t.WhoId).substring(0,3) == contactPrefix){
                        contactIdList.add(t.WhoId);
                        taskSet.add(t.Id);
                    }
                }
            }
            else{
                system.debug('not Insert');
                if(t.WhoId != Null){
                    if(string.valueof(t.WhoId).substring(0,3) == contactPrefix || string.valueof(oldMap.get(t.Id).WhoId).substring(0,3)==contactPrefix){
                        system.debug('contact prefix');
                        //works for update statement
                        if(isDelete == False){
                            //works when WHoId is changed
                            if(oldMap.get(t.Id).WhoId != Null){
                                if(t.WhoId != oldMap.get(t.id).WhoId)
                                {
                                    contactIdList.add(t.Whoid);
                                    contactIdList.add(oldMap.get(t.Id).WhoId);
                                    taskSet.add(t.Id);
                                }
                            }
                            //works when OwnerId is changed
                            if(t.OwnerId!= oldmap.get(t.id).OwnerId){
                                contactIdList.add(t.WhoId);
                                taskSet.add(t.Id);
                            }
                        }

                        else{
                            //works for delete statement
                            if(oldMap.get(t.Id).WhoId != Null){
                                contactIdList.add(oldMap.get(t.Id).WhoId);
                                taskSet.add(t.Id);
                            }
                        }
                    }
                }
                else{
                    //works for update statements where Who Id is made empty
                    if(oldMap.get(t.Id).WhoId != Null){
                        if(string.valueof(oldMap.get(t.Id).WhoId).substring(0,3) == contactPrefix){
                            contactIdList.add(oldMap.get(t.Id).WhoId);
                            taskSet.add(t.Id);
                        }
                    }
                }
            }
        }
        if(contactIdlist.size()>0){
            //system.debug('contactIdList' + contactIdList);
            contactMap = new Map <Id,Contact>([SELECT Id,Telia_Activities__c,Cygate_Activities__c,Marketing_Activities__c,Service_Management_Activities__c,Other_Activities__c,C_SB_Activities__c,(SELECT Id,Ownerid,WhoId,Owner.UserRoleId,RecordTypeId FROM Tasks),(SELECT Id,OwnerId,WhoId,Owner.UserRoleId,RecordTypeId FROM Events) FROM Contact WHERE ID IN: contactIdList AND RecordType.DeveloperName =: SEUtility.CONTACT_RECTYPE_CUSTOMER]);
            if(contactMap.values() != NULL){
                for(contact con:contactMap.values()){
                    if(con.Tasks.size() >0){
                       for(task t:con.Tasks){
                           taskSet.add(t.Id);
                       }
                   }
                   if(con.Events.size() > 0){
                       for(Event e :con.Events){
                           if(contactSegmentMap.containsKey(e.WhoId)){
                               Set<String> setVar = new Set<String>();
                               setVar =  contactSegmentMap.get(e.Whoid);
                               setVar.add(roleSegmentMap.get(e.Owner.UserRoleId));
                               contactSegmentMap.put(e.Whoid,setVar);
                           }
                           else{
                               Set<String> setVar = new Set<String>();
                               setVar.add(roleSegmentMap.get(e.Owner.UserRoleId));
                               contactSegmentMap.put(e.Whoid,setVar);
                           }
                        }
                    }
                }
            }
        }

        if(taskSet.size()>0){
            taskRelationMap = new Map<Id,Task>([Select Id, WhoId,Owner.UserRoleId,Ownerid,(Select Id,TaskId,RelationId,Type,Task.OwnerId,Task.Owner.UserRoleId FROM TaskWhoRelations) FROM TASK WHERE Id IN: taskSet]);
        }
        if(taskRelationMap.values() != Null){
            for(Task t:taskRelationMap.values())
            {
                if(t.taskWhoRelations != Null){
                    for(TaskWhoRelation twr:t.taskWhoRelations){
                        TWRList.add(twr);
                    }
                }
            }
            if(TWRList.size()>0){
                for(TaskWhoRelation TWR: TWRList){
                    if(TWR.Type == 'Contact'){
                        //if(oldMap != NUll && !(oldMap.containsKey(t.Id)))
                        if(contactTaskSegmentMap.containsKey(TWR.RelationId)){
                            Set<String> setVar = new Set<String>();
                            setVar =  contactTaskSegmentMap.get(TWR.RelationId);
                            string inst = string.valueof(roleSegmentMap.get(TWR.task.Owner.UserRoleId));
                            setVar.add(inst);
                            //setVar.add(roleSegmentMap.get(TWR.task.Owner.UserRoleId));
                            contactTaskSegmentMap.put(TWR.RelationId,setVar);
                        }
                        else{
                            Set<String> setVar = new Set<String>();
                            string inst = string.valueof(roleSegmentMap.get(TWR.task.Owner.UserRoleId));
                            setVar.add(inst);
                            //setVar.add(roleSegmentMap.get(TWR.Task.Owner.UserRoleId));
                            contactTaskSegmentMap.put(TWR.RelationId,setVar);
                        }
                    }
                }
            }
        }
        if(contactMap.Values() != NULL){
            for(Contact con:contactMap.values()){
                //contact cont = new Contact(id = con.Id);
                If(con.Telia_Activities__c != False){
                    if(contactTaskSegmentMap.get(con.Id) == NUll || !(contactTaskSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_TELIA))){
                        if(contactSegmentMap.get(con.Id) == NUll || !(contactSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_TELIA))){
                            con.Telia_Activities__c = False;
                            booleanUpdate = True;
                        }
                    }
                }
                else{
                    if((contacttaskSegmentMap.get(con.Id) != Null) && contactTaskSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_TELIA)){
                        con.Telia_Activities__c = True;
                        booleanUpdate = True;
                    }
                }
                if(con.Cygate_Activities__c != False){
                    if(contactTaskSegmentMap.get(con.Id) == Null || !(contactTaskSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_CYGATE))){
                        if(contactSegmentMap.get(con.Id) == Null || !(contactSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_CYGATE))){
                            con.Cygate_Activities__c = False;
                            booleanUpdate = True;
                        }
                    }
                }
                else{
                    if((contacttaskSegmentMap.get(con.Id) != Null) && contactTaskSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_CYGATE)){
                        con.Cygate_Activities__c = True;
                        booleanUpdate = True;
                    }
                }
                if(con.Service_Management_Activities__c != False){
                    if(contactTaskSegmentMap.get(con.Id) == Null || !(contactTaskSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_SERVICE_MANAGEMENT))){
                        if(contactSegmentMap.get(con.Id) == Null || !(contactSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_SERVICE_MANAGEMENT))){
                            con.Service_Management_Activities__c = False;
                            booleanUpdate = True;
                        }
                    }
                }
                else{
                    if((contacttaskSegmentMap.get(con.Id) != Null) && contactTaskSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_SERVICE_MANAGEMENT)){
                        con.Service_Management_Activities__c = True;
                        booleanUpdate = True;
                    }
                }
                if(con.Marketing_Activities__c != False){
                    if(contactTaskSegmentMap.get(con.Id) == Null || !(contactTaskSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_MARKETING))){
                        if(contactSegmentMap.get(con.Id) == Null || !(contactSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_MARKETING))){
                            con.Marketing_Activities__c = False;
                            booleanUpdate = True;
                        }
                    }
                }
                else{
                    if((contacttaskSegmentMap.get(con.Id) != Null) && contactTaskSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_MARKETING)){
                        con.Marketing_Activities__c = True;
                        booleanUpdate = True;
                    }
                }
                if(con.Other_Activities__c != False){
                    if(contactTaskSegmentMap.get(con.Id) == Null || !(contactTaskSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_OTHER))){
                        if(contactSegmentMap.get(con.Id) == Null || !(contactSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_OTHER))){
                            con.Other_Activities__c = False;
                            booleanUpdate = True;
                        }
                    }
                }
                else{
                    if((contacttaskSegmentMap.get(con.Id) != Null) && contactTaskSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_OTHER)){
                        con.Other_Activities__c = True;
                        booleanUpdate = True;
                    }
                }
                if (con.C_SB_Activities__c && (contactTaskSegmentMap.get(con.Id) == null || !(contactTaskSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_C_SB))) && (contactSegmentMap.get(con.Id) == null || !(contactSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_C_SB)))) {
                    con.C_SB_Activities__c = false;
                    booleanUpdate = true;
                } else if (!con.C_SB_Activities__c && contactTaskSegmentMap.get(con.Id) != null && (contactTaskSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_C_SB))) {
                    con.C_SB_Activities__c = true;
                    booleanUpdate = true;
                }
                if(booleanUpdate){
                    contactUpdateList.add(con);
                }
            }
        }
        if(contactUpdateList.size() > 0){

            try{
                update ContactUpdateList;
            }
            catch(exception e){
                for(Task t:TaskList){
                    t.adderror(e.getmessage());
                }
            }
        }
    }

    public static void updateSalesResponseTimeOnBI(List<Task> taskList){

        List<Buy_Interest__c> relatedToBI=new List<Buy_Interest__c>();
        List<Buy_Interest__c> updateBI=new List<Buy_Interest__c>();
        List<Lead> updateLead= new List<Lead>();
        Set<Id> leadIds= new Set<Id>();
        Integer Hours;
        Integer Hours_weekend;
        Set<Id> relatedToId=new Set<Id>();
        for(Task t:taskList){
            if(t.WhatId!=null){
                relatedToId.add(t.WhatId);
            }
        }
        relatedToBI= [select Id,Lead__c,Lead__r.Customer_Contacted__c,CreatedDate,Sales_rep_response_time__c,Customer_Contacted__c,Date_Owner_Changed__c,Response_Time_Calculate_Date_Time__c,(SELECT Id,CreatedDate FROM Tasks order by CreatedDate desc limit 1) from Buy_Interest__c where Id IN : relatedToId];
        if(relatedToBI.size()>0){
            for(Buy_Interest__c bi: relatedToBI){
                //if(bi.Events.size()==0 && bi.Tasks.size()==1)
                if(bi.Sales_rep_response_time__c==null){
                    for(Task t: bi.Tasks){
                        Hours= Integer.valueof((t.CreatedDate.getTime() - bi.Response_Time_Calculate_Date_Time__c.getTime())/(60*60));
                        Integer s=(hours/1000);
                        if(s<0){
                            Hours_weekend=Integer.valueof((t.CreatedDate.getTime() - bi.Date_Owner_Changed__c.getTime())/(60*60));
                            Integer s_w=(Hours_weekend/1000);
                            bi.Sales_rep_response_time__c=String.ValueOf(s_w);
                        }
                        else{
                            bi.Sales_rep_response_time__c=String.ValueOf(s);
                        }
                        bi.Customer_Contacted__c=true;
                        updateBI.add(bi);
                    }
                    //}
                    if(!bi.Lead__r.Customer_Contacted__c){
                        leadIds.add(bi.Lead__c);
                    }
                }
            }
        }
        if(updateBI.size()>0){
            update updateBI;
        }
        updateLead = [select Id, Customer_Contacted__c from Lead where Id IN :leadIds];

        for(Lead l : updateLead){
            l.Customer_Contacted__c =true;
        }
        if(updateLead.size()>0){
            update updateLead;
        }
    }

    public static Boolean isFiberUser() {
        String profileName = [Select Id,Name from Profile where Id = :Userinfo.getProfileId()].Name;
        if (profileName == 'Fiber Base Profile') {
            return true;
        }
        return false;
    }
}