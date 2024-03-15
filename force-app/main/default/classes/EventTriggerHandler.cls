/**
About
-----
Description: TriggerHandler on Events
- On creation the old EventBeforeInsert and EventBeforeUpdate triggers where merged into the new trigger handler
Create date: 23.02.2016

    EventBeforeUpdate Update History
    --------------
    Created March 2015 - V.I
    Updated May 2015 - V.I removed purpose field on Event
    Updated Feb 2016 - Merged functionality from old trigger to the new method

    EventBeforeInsert Update History
    --------------
    Created September - A.N. if event is created with an inactive contact, do not save the record but add error message
    Updated Feb 2016 - Merged functionality from old trigger to the new method

Update History
--------------
    Created Feb 2016 - A.N. Method to post to chatter on after update + helper methods
    Updated Sep 2016 - A.N. Refactored. Replaced hardcoded error message with custom label lookup. Cleaned up comments/debug statements
    Updated Dec 2016 - A.N. SAEN-2101 new method createChatterPostForNewEvents, replaces Process Builder Chatter Post for New Event Created
    Updated May 2016 - P.P Case 3094 Added method updateContactActivities
    Updated Sept 2018 - P.S SALEF-1423 - Updated method- updateCampaignOnEvent() to add the functionality for Telia type events.
    29.12.2022 [Tomass Brazovskis] SALEF-7949 - Accommodate for the replacement of SEUtility.setAccountContactedDate() with
                SEUtility.getAccountsWithContactedDatesToUpdate().
*/

public class EventTriggerHandler {

    /* * * * * * * * * * * * * * * * * * * * */
    /* * EventTriggerHandler Trigger Calls * */
    /* * * * * * * * * * * * * * * * * * * * */

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    Boolean deleteInstance = False;
    Boolean insertInstance = False;

    public EventTriggerHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnBeforeInsert(List<Event> newList, Map<ID, Event> newMap) {
        System.debug('EventTriggerHandler.OnBeforeInsert starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        validateActiveContactOnEvents(newList);
        updateOpportunityOnEvent(newList, null);
        updateCampaignOnEvent(newList, null);
    }

    public void OnBeforeUpdate(List<Event> newList, Map<ID, Event> newMap, List<Event> oldList, Map<ID, Event> oldMap) {
        System.debug('EventTriggerHandler.OnBeforeUpdate starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        updateOpportunityOnEvent(newList, oldMap);
        updateCampaignOnEvent(newList, oldMap);
        updateTargetedAccounts(newList);
    }

    public void OnAfterInsert(List<Event> newList, Map<ID, Event> newMap) {
        System.debug('EventTriggerHandler.OnAfterInsert starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        PerformanceUtils.updateYearlyContributionScore(newList);
        //PerformanceUtils.updateQuarterlyContributionScore(newList);
        PerformanceUtils.checkSambesokForEvent(newList);
        PerformanceUtils.updateQuarterlyPointScore(newList);
        createChatterPostForNewEvents(newList);
        deleteInstance = False;
        insertInstance = True;
        updateContactActivities(newList, null, insertInstance, deleteInstance);
        updateSalesResponseTimeOnBI(newList);
        setAccountCSBContactedDate(newList, null);
    }

    public void OnAfterUpdate(List<Event> newList, Map<ID, Event> newMap, List<Event> oldList, Map<ID, Event> oldMap) {
        System.debug('EventTriggerHandler.OnAfterUpdate starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        postChatterUpdate(newList, oldMap);
        PerformanceUtils.updateYearlyContributionScore(newList);
        //PerformanceUtils.updateQuarterlyContributionScore(newList);
        PerformanceUtils.checkSambesokForEvent(newList);
        PerformanceUtils.updateQuarterlyPointScore(newList);
        deleteInstance = False;
        insertInstance = False;
        updateContactActivities(newList, oldMap, insertInstance, deleteInstance);
        setAccountCSBContactedDate(newList, oldMap);
    }
    public void OnBeforeDelete(List<Event> oldList, Map<Id, Event> oldMap) {
        System.debug('EventTriggerHandler.OnBeforeDelete starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
    }
    public void OnAfterDelete(List<Event> oldList, Map<ID, Event> oldMap) {
        System.debug('EventTriggerHandler.OnAfterDelete starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        PerformanceUtils.updateYearlyContributionScore(oldList);
        //PerformanceUtils.updateQuarterlyContributionScore(oldList);
        PerformanceUtils.updateQuarterlyPointScore(oldList);
        deleteInstance = True;
        insertInstance = False;
        updateContactActivities(oldList, oldMap, insertInstance, deleteInstance);
    }

    /* * * * * * * * * * * * * * * * * * * * * */
    /* * EventTriggerHandler Trigger Methods * */
    /* * * * * * * * * * * * * * * * * * * * * */

    private final static String CYGATE_CHATTER_POST_FOLDER_NAME = 'Cygate_Chatter_Posts'; // Folder developer name
    private final static String COMPLETED_EVENT_WITH_INVITEES = 'Cygate_Completed_Customer_Visits_with_invitees_SE'; // Template developer name
    private final static String COMPLETED_EVENT_WITHOUT_INVITEES = 'Cygate_Completed_Customer_Visits_without_invitees_SE'; // Template developer name

    /* Author A.N
    *  This method posts a chatter post on the chatter page for the account related to the event when a cygate customer event is completed.
    *  The message is always posted from the context user, as the connect api does not allow to specify any other user as the creator of the comment. 
    *  The completed checkbox is automatically set by WF-rules/Process builder.
    *  It will use one out of templates dependent on if the user visited the customer alone or with other invitees (users)*/

    private final static String TEMPLATE_USER_REF = '[SALESPERSON]'; // The event assigned to user
    private final static String TEMPLATE_ACCOUNT_REF = '[CLIENT]'; // The name of the account relaetd to 
    private final static String TEMPLATE_INVITEES_REF = '[INVITEES]';
    private final static String TEMPLATE_POINTS_REF = '[VISIT_POINTS]';
    private final static String TEMPLATE_DATE_REF = '[VISIT_DATE]';

    private static void postChatterUpdate(List<Event> newList, Map<ID, Event> oldMap) {
        List<Event> closedCygateCustomerVisitEvents = filterClosedCygateClientMeetings(newList, oldMap);

        if (!closedCygateCustomerVisitEvents.isEmpty()) {
            //Retrieve the object prefix for User
            String userObjPrefix = User.sObjectType.getDescribe().getKeyPrefix();
            // Load all users
            Map<Id, User> usersRelatedToEvents = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN (SELECT RelationId FROM EventRelation WHERE EventId in :closedCygateCustomerVisitEvents)]);
            // Get the cygate chatter post templates
            Map<String, EmailTemplate> cygateTemplatesMap = loadCygateChatterPostTemplates();

            List<ConnectApi.BatchInput> chatterPosts = new List<ConnectApi.BatchInput>();
            // for each event, create a chatter post
            for (Event e : [
                    SELECT Id, AccountId, Account.Name, OwnerId, Owner.Name, StartDateTime, Points__c, (SELECT Id, RelationId FROM EventRelations WHERE Status != 'Declined')
                    FROM Event
                    WHERE Id in :closedCygateCustomerVisitEvents
            ]) {

                if (e.AccountId != null) {
                    ConnectApi.FeedItemInput post = new ConnectApi.FeedItemInput();
                    ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                    messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

                    List<ConnectApi.MentionSegmentInput> mentionSegmentInputList = new List<ConnectApi.MentionSegmentInput>();
                    for (EventRelation er : e.EventRelations) {
                        if (String.valueOf(er.RelationId).substring(0, 3) == userObjPrefix) {
                            ConnectApi.MentionSegmentInput msi = new ConnectApi.MentionSegmentInput();
                            msi.Id = er.RelationId;
                            mentionSegmentInputList.add(msi);
                        }
                    }

                    String body = (mentionSegmentInputList.size() == 0 ? cygateTemplatesMap.get(COMPLETED_EVENT_WITHOUT_INVITEES).Body : cygateTemplatesMap.get(COMPLETED_EVENT_WITH_INVITEES).Body);

                    List<String> sList = body.replace(TEMPLATE_INVITEES_REF, 'XXX').split('XXX');
                    Integer i = 0;
                    ConnectApi.TextSegmentInput commaText = new ConnectApi.TextSegmentInput();
                    commaText.text = ', ';
                    ConnectApi.TextSegmentInput andText = new ConnectApi.TextSegmentInput();
                    andText.text = ' och ';
                    // The list sList is split for each occurence of TEMPLATE_INVITEES_REF, so for each string s add text/mention input and then add invitees mentions (unless s is the last element in the list)
                    for (String s : sList) {
                        i++;
                        Integer k = 0;
                        // The list sList2 is split for each occurence of TEMPLATE_USER_REF, so for each string s2 add text input and then add mention event owner (unless s2 is the last element in the list)
                        List<String> sList2 = s.replace(TEMPLATE_USER_REF, 'YYY').split('YYY');
                        for (String s2 : sList2) {
                            k++;
                            ConnectApi.TextSegmentInput tsi = new ConnectApi.TextSegmentInput();
                            tsi.text = s2.replace(TEMPLATE_ACCOUNT_REF, e.Account.Name).replace(TEMPLATE_POINTS_REF, String.valueOf(e.Points__c)).replace(TEMPLATE_DATE_REF, String.valueOf(e.StartDateTime.format('MMMM d,  yyyy')));
                            messageBodyInput.messageSegments.add(tsi);
                            if (k < sList2.size()) {
                                ConnectApi.MentionSegmentInput msi = new ConnectApi.MentionSegmentInput();
                                msi.Id = e.OwnerId;
                                messageBodyInput.messageSegments.add(msi);
                            }
                        }

                        // Add invitees mentions if not last element in list
                        if (i < sList.size()) { // This loop will add each event invite with a mention to the post, with each invitee separated by comma
                            Integer j = 0;
                            for (ConnectApi.MentionSegmentInput msi : mentionSegmentInputList) {
                                j++;
                                messageBodyInput.messageSegments.add(msi);
                                if (j < mentionSegmentInputList.size() - 1) { // If more than 1 more invitee in list, add comma
                                    messageBodyInput.messageSegments.add(commaText);
                                } else if (j == mentionSegmentInputList.size() - 1) { // In next to last invitee in list, add " och " (and)
                                    messageBodyInput.messageSegments.add(andText);
                                }
                            }
                        }
                    }
                    post.Body = messageBodyInput;
                    post.FeedElementType = ConnectApi.FeedElementType.FeedItem;
                    post.SubjectId = e.AccountId;

                    chatterPosts.add(new ConnectApi.BatchInput(post));
                }
            }

            system.debug('chatterPosts.size(): ' + chatterPosts.size());
            if (!chatterPosts.isEmpty()) {
                ConnectApi.ChatterFeeds.postFeedElementBatch(null, chatterPosts);
            }
        }
    }

    /* Author A.N
    *  Method to retrieve all Cygate chatter post templates.
    *  The templates are stored as email-templates in the folder "Cygate ChatterPosts". */
    private static Map<String, EmailTemplate> loadCygateChatterPostTemplates() {
        Map<String, EmailTemplate> cygateTemplatesMap = new Map<String, EmailTemplate>();
        for (EmailTemplate emailTemp : [SELECT id, Body, DeveloperName FROM EmailTemplate WHERE FolderId IN (SELECT Id From Folder WHERE DeveloperName = :CYGATE_CHATTER_POST_FOLDER_NAME)]) {
            cygateTemplatesMap.put(emailTemp.DeveloperName, emailTemp);
        }
        return cygateTemplatesMap;
    }

    /* Author A.N
    *  If event is created with an inactive contact, do not save the record but add error message. */
    private static void validateActiveContactOnEvents(List<Event> newList) {
        // Create a set to hold all the whoIds
        Set<Id> whoIds = new Set<Id>();
        for (Event e : newList) {
            whoIds.add(e.WhoId);
        }

        // Create a map over all contacts related to the new Events by querying the whoId's
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Inaktiv__c from Contact where Id in :whoIds]);

        // If inactive contact, the Event should not be saved. An error message will be presented to the user.
        for (Event e : newList) {
            Contact con = contactMap.get(e.WhoId);
            if (con != null) {
                if (con.Inaktiv__c) {
                    e.addError(Label.Event_Validation_Contact_Inactive_Error_Message);
                }
            }
        }
    }

    // Author A.N: Update the event.Opportunity lookup field if the WhatId is an opportunity
    private static void updateOpportunityOnEvent(List<Event> newList, Map<ID, Event> oldMap) {
        String oppPrefix = Opportunity.sObjectType.getDescribe().getKeyPrefix();

        for (Event e : newList) {
            // If insert, update event.Opportunity field if WhatId is Opportunity
            if (oldMap == null && e.WhatId != null && String.valueOf(e.WhatId).substring(0, 3) == oppPrefix) {
                e.Opportunity__c = e.WhatId;
            } else if (oldMap != null && e.WhatId != oldMap.get(e.Id).WhatId) {
                // If update, check if the WhatId has changed. If yes, check whether or not the new WhatId is an opportunity.
                if (e.WhatId == null || String.valueOf(e.WhatId).substring(0, 3) != oppPrefix) {
                    e.Opportunity__c = null;
                } else {
                    e.Opportunity__c = e.WhatId;
                }
            }
        }
    }

    // Author A.N: Update the event.Campaign lookup field:
    // - if the WhatId is a campaign, set this as the Campaign lookup field
    // - if the WhatId is an opportunity and opportunity.CampaignId is not null, set this as the Campaign lookup field
    private static void updateCampaignOnEvent(List<Event> newList, Map<ID, Event> oldMap) {
        String campPrefix = Campaign.sObjectType.getDescribe().getKeyPrefix();
        String oppPrefix = Opportunity.sObjectType.getDescribe().getKeyPrefix();
        List<Event> setCampaignFromOppList = new List<Event>();
        Set<Id> oppIds = new Set<Id>();

        for (Event e : newList) {
            if (e.RecordTypeId == SeUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE) || e.RecordTypeId == SeUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_TELIA)) {
                if (oldMap == null && e.WhatId != null && e.Campaign__c == null) {
                    // If insert, update event.Campaign field if WhatId is Campaign
                    if (String.valueOf(e.WhatId).substring(0, 3) == campPrefix) {
                        e.Campaign__c = e.WhatId;
                    } else if (e.Opportunity__c != null) {
                        setCampaignFromOppList.add(e);
                        oppIds.add(e.Opportunity__c);
                    }
                } else if (oldMap != null && e.WhatId != null && e.WhatId != oldMap.get(e.Id).WhatId) { // If update, check if the WhatId has changed.
                    // If the new WhatId is Campaign set this as event.Campaign
                    if (String.valueOf(e.WhatId).substring(0, 3) == campPrefix) {
                        e.Campaign__c = e.WhatId;
                        // If the new WhatId is Opportunity as event.Campaign based on Opportunity Campaign
                    } else if (String.valueOf(e.WhatId).substring(0, 3) == oppPrefix) {
                        setCampaignFromOppList.add(e);
                        oppIds.add(e.Opportunity__c);
                    }
                }
            }
        }

        if (!setCampaignFromOppList.isEmpty()) {
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, CampaignId FROM Opportunity WHERE Id in :oppIds]);
            for (Event e : setCampaignFromOppList) {
                Opportunity opp = oppMap.get(e.Opportunity__c);
                if (opp != null && opp.CampaignId != null) {
                    e.Campaign__c = opp.CampaignId;
                }
            }
        }
    }


    /**
     * @Description:
     * Updates the Account.Contacted__c on the targeted accounts.
     * @author [V.I.]/[A.N.]
     * @param newList - List of the new versions of the Event records. 
     * @Modifications:
     * 29.12.2022 [TB] SALEF-7949 - Accommodate for the replacement of SEUtility.setAccountContactedDate() with
     *              SEUtility.getAccountsWithContactedDatesToUpdate().
     * 11.2021 [Aurimas Nausutis] SALEF-5324 - Accommodate for SEUtility.setAccountContactedDate() signiture change.
     * 03.2015 [V.I.] - Introduced. Check if Event has been closed, if so we might need to update the Contacted__c
     *          field on the related account.
     **/
    private static void updateTargetedAccounts(List<Event> newList) {
        String ACCOUNT_FIELD_API_NAME_CONTACTED = SEUtility.ACCOUNT_FIELD_API_NAME_CONTACTED;
        Map<Id, Map<String, Date>> mapAccIdsToMapContactedFieldNamesToDates = new Map<Id, Map<String, Date>>();
        for (Event e : newList) {
            if (e.Event_Complete__c == TRUE) {
                if (e.AccountId != null && e.EndDateTime != null) {
                    mapAccIdsToMapContactedFieldNamesToDates.put(e.AccountId,
                            new Map<String, Date>{
                                    ACCOUNT_FIELD_API_NAME_CONTACTED => e.EndDateTime.date()
                            }
                    );
                }
            }
        }

        if (!mapAccIdsToMapContactedFieldNamesToDates.isEmpty()) {
            List<Account> lstAccountsToUpdate = SEUtility.getAccountsWithContactedDatesToUpdate(mapAccIdsToMapContactedFieldNamesToDates);
            if (lstAccountsToUpdate != null && !lstAccountsToUpdate.isEmpty()) {
                update lstAccountsToUpdate;
            }
        }
    }


    /* Author A.N */
    private static List<Event> filterClosedCygateClientMeetings(List<Event> newList, Map<ID, Event> oldMap) {
        List<Event> closedCygateClientMeetings = new List<Event>();
        for (Event e : newList) {
            if ((oldMap == null && e.Event_Complete__c) || (oldMap != null && e.Event_Complete__c && !oldMap.get(e.Id).Event_Complete__c)) {
                // Filter 2: events is defined as Cygate Client Meeting Event
                if (PerformanceUtils.isCygateClientMeeting(e)) {
                    closedCygateClientMeetings.add(e);
                }
            }
        }
        return closedCygateClientMeetings;
    }

    // Author A.N
    // This method replaces Process Builder Chatter Post for New Event Created (SAEN-2101)
    private static void createChatterPostForNewEvents(List<Event> newList) {
        List<Id> eventIds = new List<Id>();

        for (Event e : newList) {
            // Only create Chatter Post if the Event start date is not in the past
            if (e.StartDateTime >= System.now()) {
                eventIds.add(e.Id);
            }
        }

        if (!eventIds.isEmpty()) {
            ChatterUtilities.createChatterPosts(eventIds);
        }
    }
    /*Author - P.P*/
    //method to mark Activities related to user group on Contacts
    public static void updateContactActivities(List<Event> eventList, Map<Id, Event> oldMap, Boolean isInsert, Boolean isDelete) {

        Schema.DescribeSObjectResult contactDescribe = Contact.sObjectType.getDescribe();
        string contactPrefix = contactDescribe.getKeyPrefix();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        List<Id> contactIdList = new List<Id>();
        Map<Id, Set<String>> contactSegmentMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> contactEventSegmentMap = new Map<Id, Set<String>>();
        Set<Id> eventSet = new Set<Id>();
        List<EventWhoRelation> EWRList = new List<EventWhoRelation>();
        Boolean booleanupdate = False;
        List<Contact> contactUpdateList = new List<Contact>();
        Map<Id, Event> eventRelationMap = new Map<Id, Event>();
        Map<Id, String> roleSegmentMap = new Map<Id, String>();

        for (Contact_Management_Role_Set__c crms : Contact_Management_Role_Set__c.getAll().Values()) {
            roleSegmentMap.put(crms.Role_Id__c, crms.Segment__c);
        }
        //can use this instead of following
        //if(recEvent.WhoId.getSObjectType() == Contact.sObjectType)
        for (Event e : eventList) {
            if (isInsert == True) {
                //works for insert statements
                if (String.IsNotBlank(e.WhoId)) {
                    if (string.valueof(e.WhoId).substring(0, 3) == contactPrefix) {
                        contactIdList.add(e.WhoId);
                        eventSet.add(e.Id);
                    }
                }
            } else {
                system.debug('not Insert');
                if (e.WhoId != Null) {
                    if (string.valueof(e.WhoId).substring(0, 3) == contactPrefix || string.valueof(oldMap.get(e.Id).WhoId).substring(0, 3) == contactPrefix) {
                        system.debug('contact prefix');
                        //works for update statement
                        if (isDelete == False) {
                            //works when WHoId is changed
                            if (e.WhoId != oldMap.get(e.id).WhoId) {
                                contactIdList.add(e.Whoid);
                                contactIdList.add(oldMap.get(e.Id).WhoId);
                                eventSet.add(e.Id);
                            }
                            //works when OwnerId is changed
                            if (e.OwnerId != oldmap.get(e.id).OwnerId) {
                                contactIdList.add(e.WhoId);
                                eventSet.add(e.Id);
                            }
                        }

                        else {
                            //works for delete statement
                            contactIdList.add(oldMap.get(e.Id).WhoId);
                            eventSet.add(e.Id);
                        }
                    }
                } else {
                    //works for update statements where Who Id is made empty
                    if (String.IsNotBlank(Oldmap.get(e.Id).WhoId)) {
                        if (string.valueof(Oldmap.get(e.Id).WhoId).substring(0, 3) == contactPrefix) {
                            contactIdList.add(oldMap.get(e.Id).WhoId);
                            eventSet.add(e.Id);
                        }
                    }
                }
            }
        }
        if (contactIdlist.size() > 0) {
            //system.debug('contactIdList' + contactIdList);
            contactMap = new Map <Id, Contact>([SELECT Id,Telia_Activities__c,Cygate_Activities__c,Marketing_Activities__c,Service_Management_Activities__c,Other_Activities__c,C_SB_Activities__c, (SELECT Id,Ownerid,WhoId,Owner.UserRoleId,RecordTypeId FROM Tasks), (SELECT Id,OwnerId,WhoId,Owner.UserRoleId,RecordTypeId FROM Events) FROM Contact WHERE ID IN:contactIdList AND RecordType.DeveloperName = :SEUtility.CONTACT_RECTYPE_CUSTOMER]);

            if (contactMap.values() != Null) {
                for (contact con : contactMap.values()) {
                    if (con.Events.size() > 0) {
                        for (event e : con.Events) {
                            eventSet.add(e.Id);
                        }
                    }
                    if (con.Tasks.size() > 0) {
                        for (Task t : con.Tasks) {
                            if (contactSegmentMap.containsKey(t.WhoId)) {
                                Set<String> setVar = new Set<String>();
                                setVar = contactSegmentMap.get(t.Whoid);
                                setVar.add(roleSegmentMap.get(t.Owner.UserRoleId));
                                contactSegmentMap.put(t.Whoid, setVar);
                            } else {
                                Set<String> setVar = new Set<String>();
                                setVar.add(roleSegmentMap.get(t.Owner.UserRoleId));
                                contactSegmentMap.put(t.Whoid, setVar);
                            }
                        }
                    }
                }
            }
        }

        if (eventSet.size() > 0) {
            eventRelationMap = new Map<Id, Event>([Select Id, WhoId,Owner.UserRoleId,Ownerid, (Select Id,EventId,RelationId,Type,Event.OwnerId,Event.Owner.UserRoleId FROM EventWhoRelations) FROM Event WHERE Id IN:EventSet]);
        }
        if (eventRelationMap.values() != Null) {
            for (event e : eventRelationMap.values()) {
                if (e.eventWhoRelations != Null) {
                    for (EventWhoRelation ewr : e.eventWhoRelations) {
                        EWRList.add(ewr);
                    }
                }
            }
            if (EWRList.size() > 0) {
                for (EventWhoRelation EWR : EWRList) {
                    if (EWR.Type == 'Contact') {
                        //if(oldMap != NUll && !(oldMap.containsKey(t.Id)))
                        if (contactEventSegmentMap.containsKey(EWR.RelationId)) {
                            Set<String> setVar = new Set<String>();
                            setVar = contactEventSegmentMap.get(EWR.RelationId);
                            string inst = string.valueof(roleSegmentMap.get(EWR.event.Owner.UserRoleId));
                            setVar.add(inst);
                            //setVar.add(roleSegmentMap.get(TWR.task.Owner.UserRoleId));
                            contactEventSegmentMap.put(EWR.RelationId, setVar);
                        } else {
                            Set<String> setVar = new Set<String>();
                            string inst = string.valueof(roleSegmentMap.get(EWR.Event.Owner.UserRoleId));
                            setVar.add(inst);
                            //setVar.add(roleSegmentMap.get(TWR.Task.Owner.UserRoleId));
                            contactEventSegmentMap.put(EWR.RelationId, setVar);
                        }
                    }
                }
            }
        }
        if (contactMap.Values() != Null) {
            for (Contact con : contactMap.values()) {
                //contact cont = new Contact(id = con.Id);
                If (con.Telia_Activities__c != False) {
                    if (contactEventSegmentMap.get(con.Id) == NUll || !(contactEventSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_TELIA))) {
                        if (contactSegmentMap.get(con.id) == NUll || !(contactSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_TELIA))) {
                            con.Telia_Activities__c = False;
                            booleanUpdate = True;
                        }
                    }
                } else {
                    if ((contactEventSegmentMap.get(con.Id) != Null) && contactEventSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_TELIA)) {
                        con.Telia_Activities__c = True;
                        booleanUpdate = True;
                    }
                }
                if (con.Cygate_Activities__c != False) {
                    if (contactEventSegmentMap.get(con.Id) == Null || !(contactEventSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_CYGATE))) {
                        if (contactSegmentMap.get(con.id) == NUll || !(contactSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_CYGATE))) {
                            con.Cygate_Activities__c = False;
                            booleanUpdate = True;
                        }
                    }
                } else {
                    if ((contactEventSegmentMap.get(con.Id) != Null) && contactEventSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_CYGATE)) {
                        con.Cygate_Activities__c = True;
                        booleanUpdate = True;
                    }
                }
                if (con.Service_Management_Activities__c != False) {
                    if (contactEventSegmentMap.get(con.Id) == Null || !(contactEventSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_SERVICE_MANAGEMENT))) {
                        if (contactSegmentMap.get(con.id) == NUll || !(contactSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_SERVICE_MANAGEMENT))) {
                            con.Service_Management_Activities__c = False;
                            booleanUpdate = True;
                        }
                    }
                } else {
                    if ((contactEventSegmentMap.get(con.Id) != Null) && contactEventSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_SERVICE_MANAGEMENT)) {
                        con.Service_Management_Activities__c = True;
                        booleanUpdate = True;
                    }
                }
                if (con.Marketing_Activities__c != False) {
                    if (contactEventSegmentMap.get(con.Id) == Null || !(contactEventSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_MARKETING))) {
                        if (contactSegmentMap.get(con.id) == NUll || !(contactSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_MARKETING))) {
                            con.Marketing_Activities__c = False;
                            booleanUpdate = True;
                        }
                    }
                } else {
                    if ((contactEventSegmentMap.get(con.Id) != Null) && contactEventSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_MARKETING)) {
                        con.Marketing_Activities__c = True;
                        booleanUpdate = True;
                    }
                }
                if (con.Other_Activities__c != False) {
                    if (contactEventSegmentMap.get(con.Id) == Null || !(contactEventSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_OTHER))) {
                        if (contactSegmentMap.get(con.id) == NUll || !(contactSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_OTHER))) {
                            con.Other_Activities__c = False;
                            booleanUpdate = True;
                        }
                    }
                } else {
                    if ((contactEventSegmentMap.get(con.Id) != Null) && contactEventSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_OTHER)) {
                        con.Other_Activities__c = True;
                        booleanUpdate = True;
                    }
                }
                if (con.C_SB_Activities__c && (contactEventSegmentMap.get(con.Id) == null || !(contactEventSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_C_SB))) && (contactSegmentMap.get(con.Id) == null || !(contactSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_C_SB)))) {
                    con.C_SB_Activities__c = false;
                    booleanUpdate = true;
                } else if (!con.C_SB_Activities__c && contactEventSegmentMap.get(con.Id) != null && (contactEventSegmentMap.get(con.Id).contains(SEUtility.CONTACT_SEGMENT_C_SB))) {
                    con.C_SB_Activities__c = true;
                    booleanUpdate = true;
                }
                if (booleanUpdate) {
                    contactUpdateList.add(con);
                }
            }
        }
        if (contactUpdateList.size() > 0) {
            update ContactUpdateList;
        }
    }

    public static void updateSalesResponseTimeOnBI(List<Event> eventList) {

        List<Buy_Interest__c> relatedToBI = new List<Buy_Interest__c>();
        List<Buy_Interest__c> updateBI = new List<Buy_Interest__c>();
        Integer Hours_weekend;
        Set<Id> relatedToId = new Set<Id>();
        List<Lead> updateLead = new List<Lead>();
        Set<Id> leadIds = new Set<Id>();
        for (Event e : eventList) {
            if (e.WhatId != null) {
                relatedToId.add(e.WhatId);
            }
        }
        relatedToBI = [select Id,Lead__c,Lead__r.Customer_Contacted__c,CreatedDate,Sales_rep_response_time__c,Date_Owner_Changed__c,Customer_Contacted__c,Response_Time_Calculate_Date_Time__c, (SELECT ID,CreatedDate FROM Events order by CreatedDate desc limit 1) from Buy_Interest__c where Id IN :relatedToId];
        if (relatedToBI.size() > 0) {
            for (Buy_Interest__c bi : relatedToBI) {
                if (bi.Sales_rep_response_time__c == null) {
                    //if(bi.Tasks.size()==0 && bi.Events.size()==1)
                    for (Event e : bi.Events) {
                        Integer Hours = Integer.valueof((e.CreatedDate.getTime() - bi.Response_Time_Calculate_Date_Time__c.getTime()) / (60 * 60));
                        Integer s = (hours / 1000);
                        if (s < 0) {
                            Hours_weekend = Integer.valueof((e.CreatedDate.getTime() - bi.Date_Owner_Changed__c.getTime()) / (60 * 60));
                            Integer s_w = (Hours_weekend / 1000);
                            bi.Sales_rep_response_time__c = String.ValueOf(s_w);
                        } else {
                            bi.Sales_rep_response_time__c = String.ValueOf(s);
                        }
                        bi.Customer_Contacted__c = true;
                        updateBI.add(bi);
                    }
                    if (!bi.Lead__r.Customer_Contacted__c) {
                        leadIds.add(bi.Lead__c);
                    }
                }
            }
        }

        if (updateBI.size() > 0) {
            update updateBI;
        }

        updateLead = [select Id, Customer_Contacted__c from Lead where Id IN :leadIds];

        for (Lead l : updateLead) {
            l.Customer_Contacted__c = true;
        }
        if (updateLead.size() > 0) {
            update updateLead;
        }
    }

    private static void setAccountCSBContactedDate(List<Event> newList, Map<Id, Event> oldMap) {
        Map<Id, DateTime> accountsWithDates = new Map<Id, DateTime>();

        if (isFiberUser()) {
            for (Event event : newList) {
                if (event.AccountId != null) {
                    accountsWithDates.put(event.AccountId, System.now());
                }
            }
            if (!accountsWithDates.isEmpty()) {
                List<Account>accountsToUpdate = new List<Account>();
                for (Account acc : [SELECT Id, C_SB_Contacted__c FROM Account WHERE Id IN :accountsWithDates.keySet()]) {
                    if (acc.C_SB_Contacted__c == null || acc.C_SB_Contacted__c < accountsWithDates.get(acc.Id).date()) {
                        acc.C_SB_Contacted__c = accountsWithDates.get(acc.Id).date();
                        accountsToUpdate.add(acc);
                    }
                }
                if (!accountsToUpdate.isEmpty()) {
                    update accountsToUpdate;
                }
            }
        }
    }

    public static Boolean isFiberUser() {
        try {
            String profileName = [Select Id,Name from Profile where Id = :Userinfo.getProfileId()].Name;
            if (profileName == 'Fiber Base Profile') {
                return true;
            }
            return false;
        } catch (Exception e) {
            return false;
        }
    }
}