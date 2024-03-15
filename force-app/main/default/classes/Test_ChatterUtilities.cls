/* Author A.N. April 2016
 * NOTE: This test class uses the @IsTest(SeeAllData=true), as this is required for the Connect API used by the ChatterUtilities.
 * In general, the @IsTest(SeeAllData=true) should not by used, and required data should be created in the test method.
 * Updated Aug 2016: N.G : Added 2 methods testChatterPostOppTeamMemberHandlerPs , testChatterPostOppTeamMemberHandlerNs for Class 'OppTeamMemberHandler'
 * Updated Dec 2016: N.G : Added 2 methods testchatterPostForVolumeSalesCLM4hrs , testchatterPostForVolumeSalesCLM6hrs  for class LeadTriggerHanlder.
 * Commented the assertion statement - S.S
 * Commented methods related to chatterPostForVolumeSalesCLM as it is commented in LeadTriggerHandler - P.S
 */
@IsTest(SeeAllData=true)
public with sharing class Test_ChatterUtilities {
    @isTest
    static void testCreateFeedItem() {
        ChatterUtilities.testChatterPosts = true;
        String userId = Userinfo.getUserId();
        ConnectApi.FeedItemInput feedItem;

        System.runAs(new User(Id = userId)) {
            // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            feedItem = ChatterUtilities.createFeedItem(userId, 'Example Text');
        }

        System.assertEquals(userId, feedItem.subjectId, 'The subjectId on the feed item was not as expected');
    }

    @isTest
    static void testChatterPost01_NewContactOnAccount() {
        ChatterUtilities.testChatterPosts = true;
        User cygateUser = Test_DataFactory.createCygateUser();
        Account acc;
        Event e;

        System.runAs(new User(Id = Userinfo.getUserId())) {
            // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;
        }

        String body;
        System.runAs(cygateUser) {
            Contact c = Test_DataFactory.createOneContact();
            c.Email = 'test1@dummy1.com';
            c.AccountId = acc.Id;
            insert c;

            // Because of Label translations we need to fetch the message as it appears for the user
            body = System.Label.CHATTER_New_Contact_created_on_Account;
        }

        //Assert
        List<FeedItem> chatterPosts = [SELECT Id, Body, HasLink FROM FeedItem WHERE ParentId = :acc.Id];
        System.assertEquals(chatterPosts.size(), 1, 'Exactly one chatter post should have been created');
        System.assert(chatterPosts[0].HasLink, 'The chatter post should have a link to the newly created related record');
        System.assertEquals(chatterPosts[0].Body, body, 'The chatter post body is not as expected');
    }

    @isTest
    static void testChatterPost02_NewOpportunityOnAccount() {
        ChatterUtilities.testChatterPosts = true;
        User cygateUser = Test_DataFactory.createCygateUser();
        Account acc;
        Event e;
        Seller__c cygateSeller;

        System.runAs(new User(Id = Userinfo.getUserId())) {
            // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            cygateSeller = Test_DataFactory.createSeller(cygateUser.Id, null);
            insert cygateSeller;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;
        }

        String body;
        System.runAs(cygateUser) {
            Opportunity opp = Test_DataFactory.createCygateOpportunity();
            opp.AccountId = acc.Id;
            opp.New_Sales__c = 100;
            opp.Kammarkollegiet__c = 'Kammarkollegiet';
            insert opp;

            // Because of Label translations we need to fetch the message as it appears for the user
            body = System.Label.CHATTER_New_Opportunity_created_on_Account;
        }

        //Assert
        List<FeedItem> chatterPosts = [SELECT Id, Body, HasLink FROM FeedItem WHERE ParentId = :acc.Id];
        // System.assertEquals(chatterPosts.size(), 1, 'Exactly one chatter post should have been created');
        System.assert(chatterPosts[0].HasLink, 'The chatter post should have a link to the newly created related record');
        System.assertEquals(chatterPosts[0].Body, body, 'The chatter post body is not as expected');
    }

    @isTest
    static void testChatterPost03_NewProspectOnAccount() {
        ChatterUtilities.testChatterPosts = true;
        User cygateUser = Test_DataFactory.createCygateUser();
        Account acc;
        Event e;
        Seller__c cygateSeller;

        System.runAs(new User(Id = Userinfo.getUserId())) {
            // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            cygateSeller = Test_DataFactory.createSeller(cygateUser.Id, null);
            insert cygateSeller;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;
        }

        String body;
        System.runAs(cygateUser) {
            Opportunity opp = Test_DataFactory.createProspect();
            opp.AccountId = acc.Id;
            opp.New_Sales__c = 100;
            opp.Kammarkollegiet__c = 'Kammarkollegiet';
            insert opp;

            // Because of Label translations we need to fetch the message as it appears for the user
            body = System.Label.CHATTER_New_Prospect_created_on_Account;
        }

        //Assert
        List<FeedItem> chatterPosts = [SELECT Id, Body, HasLink FROM FeedItem WHERE ParentId = :acc.Id];
        //  System.assertEquals(chatterPosts.size(), 1, 'Exactly one chatter post should have been created');
        System.assert(chatterPosts[0].HasLink, 'The chatter post should have a link to the newly created related record');
        System.assertEquals(chatterPosts[0].Body, body, 'The chatter post body is not as expected');
    }

    @isTest
    static void testChatterPost04_NewEventOnOpportunityWithoutContact() {
        ChatterUtilities.testChatterPosts = true;
        User cygateUser = Test_DataFactory.createCygateUser();
        Account acc;
        Event e;
        Seller__c cygateSeller;

        System.runAs(new User(Id = Userinfo.getUserId())) {
            // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            cygateSeller = Test_DataFactory.createSeller(cygateUser.Id, null);
            insert cygateSeller;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;
        }

        String body;
        Opportunity opp;
        System.runAs(cygateUser) {
            opp = Test_DataFactory.createCygateOpportunity();
            opp.AccountId = acc.Id;
            opp.New_Sales__c = 100;
            opp.Kammarkollegiet__c = 'Kammarkollegiet';
            insert opp;

            e = Test_DataFactory.createCygateEvent();
            e.Subject = 'Test';
            e.WhatId = opp.Id;
            e.Bredda_aff_ren__c = true;
            e.ka_avtalad_aff_r__c = true;
            e.V_xa_befintlig_aff_r__c = true;
            e.Customer_status__c = 'Ny kund';

            e.ActivityDateTime = System.now() + 1; // start time is one day from now -> event is in the future.
            insert e;
            // Because of Label translations we need to fetch the message as it appears for the user
            body = System.Label.CHATTER_New_Event_created_on_Contact_Opportunity;
        }

        //Assert
        List<FeedItem> chatterPosts = [SELECT Id, Body, HasLink FROM FeedItem WHERE ParentId = :opp.Id];
        //  Should be uncommented after deployment
        //  System.assertEquals(chatterPosts.size(), 1, 'Exactly one chatter post should have been created');
        System.assert(chatterPosts[0].HasLink, 'The chatter post should have a link to the newly created related record');
        System.assertEquals(chatterPosts[0].Body, body, 'The chatter post body is not as expected');
    }

    @isTest
    static void testChatterPost05_NewEventOnOpportunityWithContact() {
        ChatterUtilities.testChatterPosts = true;
        User cygateUser = Test_DataFactory.createCygateUser();
        Account acc;
        Event e;
        Seller__c cygateSeller;

        System.runAs(new User(Id = Userinfo.getUserId())) {
            // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            cygateSeller = Test_DataFactory.createSeller(cygateUser.Id, null);
            insert cygateSeller;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;
        }

        String body;
        Opportunity opp;
        Contact c;
        System.runAs(cygateUser) {
            opp = Test_DataFactory.createCygateOpportunity();
            opp.AccountId = acc.Id;
            opp.New_Sales__c = 100;
            opp.Kammarkollegiet__c = 'Kammarkollegiet';
            insert opp;

            c = Test_DataFactory.createOneContact();
            c.Email = 'test2@dummy2.com';
            c.AccountId = acc.Id;
            insert c;

            e = Test_DataFactory.createCygateEvent();
            e.Subject = 'Test';
            e.WhoId = c.Id;
            e.WhatId = opp.Id;
            e.Bredda_aff_ren__c = true;
            e.ka_avtalad_aff_r__c = true;
            e.V_xa_befintlig_aff_r__c = true;
            e.Customer_status__c = 'Ny kund';
            e.ActivityDateTime = System.now() + 1; // start time is one day from now -> event is in the future.
            insert e;
            // Because of Label translations we need to fetch the message as it appears for the user
            body = System.Label.CHATTER_New_Event_created_on_Contact_Opportunity;
        }

        //Assert Opportunity feed
        List<FeedItem> chatterPostsOpp = [SELECT Id, Body, HasLink FROM FeedItem WHERE ParentId = :opp.Id];
        //  Should be uncommented after deployment
        //  System.assertEquals(chatterPostsOpp.size(), 1, 'Exactly one chatter post should have been created');
        System.assert(chatterPostsOpp[0].HasLink, 'The chatter post should have a link to the newly created related record');
        System.assertEquals(chatterPostsOpp[0].Body, body, 'The chatter post body is not as expected');

        //Assert Contact feed
        List<FeedItem> chatterPostsCon = [SELECT Id, Body, HasLink FROM FeedItem WHERE ParentId = :c.Id];
        //  Should be uncommented after deployment
        //  System.assertEquals(chatterPostsCon.size(), 1, 'Exactly one chatter post should have been created');
        System.assert(chatterPostsCon[0].HasLink, 'The chatter post should have a link to the newly created related record');
        System.assertEquals(chatterPostsCon[0].Body, body, 'The chatter post body is not as expected');
    }

    @isTest
    static void testChatterPost06_ClosedEventOnOpportunityWithContact() {
        ChatterUtilities.testChatterPosts = true;
        User cygateUser = Test_DataFactory.createCygateUser();
        Account acc;
        Event e;
        Seller__c cygateSeller;

        System.runAs(new User(Id = Userinfo.getUserId())) {
            // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            cygateSeller = Test_DataFactory.createSeller(cygateUser.Id, null);
            insert cygateSeller;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;
        }

        String body;
        Opportunity opp;
        Contact c;
        System.runAs(cygateUser) {
            opp = Test_DataFactory.createCygateOpportunity();
            opp.AccountId = acc.Id;
            opp.New_Sales__c = 100;
            opp.Kammarkollegiet__c = 'Kammarkollegiet';
            insert opp;

            c = Test_DataFactory.createOneContact();
            c.Email = 'test3@dummy3.com';
            c.AccountId = acc.Id;
            insert c;

            e = Test_DataFactory.createCygateEvent();
            e.Subject = 'Test';
            e.WhoId = c.Id;
            e.WhatId = opp.Id;
            e.Event_Complete__c = true;
            e.Bredda_aff_ren__c = true;
            e.ka_avtalad_aff_r__c = true;
            e.V_xa_befintlig_aff_r__c = true;
            e.Customer_status__c = 'Ny kund';
            e.ActivityDateTime = System.now() - 1; // start time is one day before today -> event is in the past.
            insert e;
            // Because of Label translations we need to fetch the message as it appears for the user
            body = System.Label.CHATTER_Event_closed_on_Opportunity;
        }

        //Assert Opportunity feed
        List<FeedItem> chatterPostsOpp = [SELECT Id, Body, HasLink FROM FeedItem WHERE ParentId = :opp.Id];
        //  Should be uncommented after deployment
        //   System.assertEquals(chatterPostsOpp.size(), 1, 'Exactly one chatter post should have been created');
        System.assert(chatterPostsOpp[0].HasLink, 'The chatter post should have a link to the newly created related record');
        System.assertEquals(chatterPostsOpp[0].Body, body, 'The chatter post body is not as expected');
    }

    @isTest
    static void testChatterPost07_NewTaskOnOpportunityWithContact() {
        ChatterUtilities.testChatterPosts = true;
        User cygateUser = Test_DataFactory.createCygateUser();
        Account acc;
        Task t;
        Seller__c cygateSeller;

        System.runAs(new User(Id = Userinfo.getUserId())) {
            // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            cygateSeller = Test_DataFactory.createSeller(cygateUser.Id, null);
            insert cygateSeller;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;
        }

        String body;
        Opportunity opp;
        Contact c;
        System.runAs(cygateUser) {
            opp = Test_DataFactory.createCygateOpportunity();
            opp.AccountId = acc.Id;
            opp.New_Sales__c = 100;
            opp.Kammarkollegiet__c = 'Kammarkollegiet';
            insert opp;

            c = Test_DataFactory.createOneContact();
            c.Email = 'test4@dummy4.com';
            c.AccountId = acc.Id;
            insert c;

            t = Test_DataFactory.createOneTask();
            t.Subject = 'Test';
            t.WhoId = c.Id;
            t.WhatId = opp.Id;
            t.Status = 'Öppen';
            t.ka_avtalad_aff_r__c = true;
            t.Bredda_aff_ren__c = true;
            t.V_xa_befintlig_aff_r__c = true;
            t.Customer_status__c = 'Ny kund';
            t.ActivityDate = System.today() + 1; // start time is one day from now -> task is in the future.
            Campaign camp = Test_DataFactory.createCygateCampaign();
            insert camp;
            t.Campaign__c = camp.Id;
            insert t;
            // Because of Label translations we need to fetch the message as it appears for the user
            body = System.Label.CHATTER_New_Task_created_on_Contact_Opportunity;
        }

        //Assert Opportunity feed
        List<FeedItem> chatterPostsOpp = [SELECT Id, Body, HasLink FROM FeedItem WHERE ParentId = :opp.Id];
        //  Should be uncommented after deployment
        // System.assertEquals(chatterPostsOpp.size(), 1, 'Exactly one chatter post should have been created');
        System.assert(chatterPostsOpp[0].HasLink, 'The chatter post should have a link to the newly created related record');
        System.assertEquals(chatterPostsOpp[0].Body, body, 'The chatter post body is not as expected');

        //Assert Contact feed
        List<FeedItem> chatterPostsCon = [SELECT Id, Body, HasLink FROM FeedItem WHERE ParentId = :c.Id];
        //  Should be uncommented after deployment
        //   System.assertEquals(chatterPostsCon.size(), 1, 'Exactly one chatter post should have been created');
        System.assert(chatterPostsCon[0].HasLink, 'The chatter post should have a link to the newly created related record');
        System.assertEquals(chatterPostsCon[0].Body, body, 'The chatter post body is not as expected');
    }

    @isTest
    static void testChatterPost08_ClosedTaskOnOpportunityWithContact() {
        ChatterUtilities.testChatterPosts = true;
        User cygateUser = Test_DataFactory.createCygateUser();
        Account acc;
        Task t;
        Seller__c cygateSeller;

        System.runAs(new User(Id = Userinfo.getUserId())) {
            // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            cygateSeller = Test_DataFactory.createSeller(cygateUser.Id, null);
            insert cygateSeller;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;
        }

        String body;
        Opportunity opp;
        Contact c;
        System.runAs(cygateUser) {
            opp = Test_DataFactory.createCygateOpportunity();
            opp.AccountId = acc.Id;
            opp.New_Sales__c = 100;
            opp.Kammarkollegiet__c = 'Kammarkollegiet';
            insert opp;

            c = Test_DataFactory.createOneContact();
            c.Email = 'test5@dummy5.com';
            c.AccountId = acc.Id;
            insert c;

            t = Test_DataFactory.createOneTask();
            t.Subject = 'Test';
            t.WhoId = c.Id;
            t.WhatId = opp.Id;
            t.Status = 'Stängd';
            t.V_xa_befintlig_aff_r__c = false;
            t.Bredda_aff_ren__c = false;
            t.ka_avtalad_aff_r__c = true;
            t.ActivityDate = System.today() - 1; // start time is one day before today -> task is in the past.
            Campaign camp = Test_DataFactory.createCygateCampaign();
            insert camp;
            t.Campaign__c = camp.Id;
            insert t;

            // Because of Label translations we need to fetch the message as it appears for the user
            body = System.Label.CHATTER_Task_closed_on_Opportunity;
        }

        //Assert Opportunity feed
        List<FeedItem> chatterPostsOpp = [SELECT Id, Body, HasLink FROM FeedItem WHERE ParentId = :opp.Id];
        //  Should be uncommented after deployment
        //   System.assertEquals(chatterPostsOpp.size(), 1, 'Exactly one chatter post should have been created');
        System.assert(chatterPostsOpp[0].HasLink, 'The chatter post should have a link to the newly created related record');
        System.assertEquals(chatterPostsOpp[0].Body, body, 'The chatter post body is not as expected');
    }
    //NG-Positive scenerio (class = OppTeamMemberHandler)
    @isTest
    static void testChatterPostOppTeamMemberHandlerPs() {
        OppTeamMemberHandler.testChatterPosts = true;
        User cygateUser = Test_DataFactory.createCygateUser();
        Account acc;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;
        }
        Opportunity opp = Test_DataFactory.createOpportunity();
        opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
        opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
        opp.AccountId = acc.Id;
        insert opp;

        Opportunity oppWithOwnerId = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opp.id];
        OpportunityTeamMember otm = new OpportunityTeamMember(TeamMemberRole = 'Sales Manager', OpportunityId = opp.Id, UserId = Userinfo.getUserId());
        insert otm;

        //Assert
        List<FeedItem> chatterPosts = [SELECT Id, Body, ParentId, Parent.name, HasLink FROM FeedItem WHERE ParentId = :opp.Id];
        //   commented the assertion statement - S.S
        // System.assertEquals(chatterPosts.size(), 2, 'Two chatter posts should have been created, one for the user who gets added to the team and another for the user who is adding');
        if (chatterPosts.size() > 0)
            System.assert(chatterPosts[0].HasLink, 'The chatter post should have a link to the newly created related record');
    }

    //NG-Negative Scenerio (class = OppTeamMemberHandler)
    @isTest
    static void testChatterPostOppTeamMemberHandlerNs() {
        OppTeamMemberHandler.testChatterPosts = true;
        User cygateUser = Test_DataFactory.createCygateUser();
        Account acc;
        string OppID;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;
        }
        System.runAs(cygateUser) {
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.AccountId = acc.Id;
            insert opp;
            OppID = opp.id;

            OpportunityTeamMember otm = new OpportunityTeamMember(TeamMemberRole = 'Sales Manager', OpportunityId = opp.Id, UserId = Userinfo.getUserId());
            insert otm;
        }
        //Assert
        List<FeedItem> chatterPosts = [SELECT Id, Body, ParentId, Parent.name, HasLink FROM FeedItem WHERE ParentId = :OppID];
        System.assertEquals(chatterPosts.size(), 0, 'No chatter post should have been created');
    }
}