/**
About
-----
Description: Utility Class for Chatter functionality in Apex

The ChatterUtilities class is used by several Process Builders. The invokable method createChatterPosts will create new chatter posts when f.ex. new tasks/events are created.

The class also have general utility methods for creating new feed items

Create date: April 2016

Update History
--------------
Created Jun 2015 - A.N Created
Updated Sep 2016 - Refactored: Cleaned up in debug statements.
Updated Feb 2023 - R. Urbonas refectored code to use less SOQL

Issues / TODOs
--------------  

*/

public with sharing class ChatterUtilities {
    // When system tests are running, the ConnectAPI is only available if SeeAllData=true.
    // We therefore do not post the ChatterPosts when unit tests are running unless this is specifically stated (by setting testChatterPosts = true)
    @TestVisible
    private static Boolean testChatterPosts = false;

    @InvocableMethod
    public static void createChatterPosts(List<Id> sObjectIds) {
        List<ConnectApi.BatchInput> chatterPosts = new List<ConnectApi.BatchInput>();
        List<Id> opportunityIds = new List<Id>();
        List<Id> contractIds = new List<Id>();
        List<Id> eventIds = new List<Id>();
        List<Id> taskIds = new List<Id>();

        for (Id sObjectId : sObjectIds) {
            if (sObjectId.getSObjectType() == Opportunity.sObjectType) {
                opportunityIds.add(sObjectId);
            } else if (sObjectId.getSObjectType() == Contact.sObjectType) {
                contractIds.add(sObjectId);
            } else if (sObjectId.getSObjectType() == Event.sObjectType) {
                eventIds.add(sObjectId);
            } else if (sObjectId.getSObjectType() == Task.sObjectType) {
                taskIds.add(sObjectId);
            }
        }
        if (!contractIds.isEmpty()) {
            // Create Chatter posts when new Contact is created on an Account
            for (Contact oneContact : [SELECT Id, Name, AccountId FROM Contact WHERE Id IN :contractIds AND AccountId != NULL]) {
                ConnectApi.FeedItemInput item = createFeedItem(
                    oneContact.AccountId,
                    System.Label.CHATTER_New_Contact_created_on_Account,
                    '/' + oneContact.Id,
                    oneContact.Name
                );
                chatterPosts.add(new ConnectApi.BatchInput(item));
            }
        }
        if (!opportunityIds.isEmpty()) {
            // Create Chatter posts when new opportunity is created on an Account
            for (Opportunity oneOpportunity : [
                SELECT Id, Name, AccountId, RecordType.DeveloperName
                FROM Opportunity
                WHERE Id IN :opportunityIds AND AccountId != NULL
            ]) {
                String text = (oneOpportunity.RecordType.DeveloperName == SEUtility.OPP_RECTYPE_PROSPECT
                    ? System.Label.CHATTER_New_Prospect_created_on_Account
                    : System.Label.CHATTER_New_Opportunity_created_on_Account);
                ConnectApi.FeedItemInput item = createFeedItem(oneOpportunity.AccountId, text, '/' + oneOpportunity.Id, oneOpportunity.Name);
                chatterPosts.add(new ConnectApi.BatchInput(item));
            }
        }
        if (!eventIds.isEmpty()) {
            // Create Chatter posts on opportunity feed when:
            // a) A new event is created with a future start date. Also post to contact.
            // b) An event related to an opportunity is completed.
            for (Event oneEvent : [SELECT Id, Subject, WhoId, WhatId, StartDateTime, Event_Complete__c FROM Event WHERE Id IN :eventIds]) {
                if (oneEvent.Event_Complete__c && oneEvent.WhatId != null && oneEvent.WhatId.getSObjectType() == Opportunity.sObjectType) {
                    ConnectApi.FeedItemInput item = createFeedItem(
                        oneEvent.WhatId,
                        System.Label.CHATTER_Event_closed_on_Opportunity,
                        '/' + oneEvent.Id,
                        oneEvent.Subject
                    );
                    chatterPosts.add(new ConnectApi.BatchInput(item));
                } else if (oneEvent.StartDateTime > System.now() && oneEvent.WhatId != null && oneEvent.WhatId.getSObjectType() == Opportunity.sObjectType) {
                    ConnectApi.FeedItemInput item = createFeedItem(
                        oneEvent.WhatId,
                        System.Label.CHATTER_New_Event_created_on_Contact_Opportunity,
                        '/' + oneEvent.Id,
                        oneEvent.Subject
                    );
                    chatterPosts.add(new ConnectApi.BatchInput(item));
                }
                if (oneEvent.StartDateTime > System.now() && oneEvent.WhoId != null && oneEvent.WhoId.getSObjectType() == Contact.sObjectType) {
                    ConnectApi.FeedItemInput item = createFeedItem(
                        oneEvent.WhoId,
                        System.Label.CHATTER_New_Event_created_on_Contact_Opportunity,
                        '/' + oneEvent.Id,
                        oneEvent.Subject
                    );
                    chatterPosts.add(new ConnectApi.BatchInput(item));
                }
            }
        }
        if (!taskIds.isEmpty()) {
            // Create Chatter posts on opportunity feed when:
            // a) A new task is created with a future start date. Also post to contact.
            // b) An task related to an opportunity is closed.
            for (Task oneTask : [SELECT Id, Subject, WhoId, WhatId, ActivityDate, IsClosed FROM Task WHERE Id IN :taskIds]) {
                if (oneTask.IsClosed && oneTask.WhatId != null && oneTask.WhatId.getSObjectType() == Opportunity.sObjectType) {
                    ConnectApi.FeedItemInput item = createFeedItem(
                        oneTask.WhatId,
                        System.Label.CHATTER_Task_closed_on_Opportunity,
                        '/' + oneTask.Id,
                        oneTask.Subject
                    );
                    chatterPosts.add(new ConnectApi.BatchInput(item));
                } else if (oneTask.ActivityDate > System.today() && oneTask.WhatId != null && oneTask.WhatId.getSObjectType() == Opportunity.sObjectType) {
                    ConnectApi.FeedItemInput item = createFeedItem(
                        oneTask.WhatId,
                        System.Label.CHATTER_New_Task_created_on_Contact_Opportunity,
                        '/' + oneTask.Id,
                        oneTask.Subject
                    );
                    chatterPosts.add(new ConnectApi.BatchInput(item));
                }
                if (oneTask.ActivityDate > System.today() && oneTask.WhoId != null && oneTask.WhoId.getSObjectType() == Contact.sObjectType) {
                    ConnectApi.FeedItemInput item = createFeedItem(
                        oneTask.WhoId,
                        System.Label.CHATTER_New_Task_created_on_Contact_Opportunity,
                        '/' + oneTask.Id,
                        oneTask.Subject
                    );
                    chatterPosts.add(new ConnectApi.BatchInput(item));
                }
            }
        }

        if (!chatterPosts.isEmpty() && (!Test.isRunningTest() || testChatterPosts)) {
            ConnectApi.ChatterFeeds.postFeedElementBatch(null, chatterPosts);
        }
    }

    public static ConnectApi.FeedItemInput createFeedItem(Id subjectId, String text) {
        return createFeedItem(subjectId, text, null, null);
    }

    public static ConnectApi.FeedItemInput createFeedItem(Id subjectId, String text, String optUrl, String optUrlName) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        feedItemInput.body = new ConnectApi.MessageBodyInput();
        feedItemInput.subjectId = subjectId;

        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        feedItemInput.body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        textSegment.text = text;
        feedItemInput.body.messageSegments.add(textSegment);

        if (optUrl != null) {
            ConnectApi.FeedElementCapabilitiesInput capability = new ConnectApi.FeedElementCapabilitiesInput();
            ConnectApi.LinkCapabilityInput link = new ConnectApi.LinkCapabilityInput();
            link.url = optUrl;
            link.urlName = optUrlName;
            capability.link = link;
            feedItemInput.capabilities = capability;
        }

        return feedItemInput;
    }
}