/**
 * Author A.N. March 2016
 * NOTE: This test class uses the @IsTest(SeeAllData=true), as this is required for the Connect API used by the EventTriggerHandler.
 * In general, the @IsTest(SeeAllData=true) should never by used, and required data should be created in the test method.
 * Modifications:
 * 06.01.2022 [Tomass Brazovskis] SALEF-7949 - Moved the (SeeAllData=true) annotation to the methods where it must be used,
 *              instead of applying to the whole class. Ensured test Contact uniqueness in the methods using the annotation
 *              to avoid failures due to Duplicate Exceptions.
 **/
@IsTest
public with sharing class Test_EventTriggerHandlerChatterPosts {
    @isTest(SeeAllData=true)
    static void testPostChatterUpdateEventNoInvitees() {
        User cygateUser = Test_DataFactory.createCygateUser();
        Account acc;
        Event e;

        System.runAs(new User(Id = Userinfo.getUserId())) {
            // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;
        }

        System.runAs(cygateUser) {
            test.starttest();
            Contact c = Test_DataFactory.createOneContact();
            c.AccountId = acc.Id;
            c.LastName = c.LastName + System.now().format('yyMMddHHmmss');
            c.Email = 'test' + System.now().format('yyMMddHHmmss') + '@dummy.com';
            insert c;

            e = Test_DataFactory.createCygateKundbesokEvent();
            e.WhoId = c.Id;
            e.WhatId = acc.Id;
            e.Bredda_aff_ren__c = true;
            e.ka_avtalad_aff_r__c = true;
            e.V_xa_befintlig_aff_r__c = true;
            e.Customer_status__c = 'Ny kund';
            e.ActivityDateTime = System.now() + 1; // start time is one day from now -> event is open.
            insert e;
            test.stoptest();
        }

        //Assert
        Integer noOfChatterPosts = [SELECT COUNT() FROM FeedItem WHERE ParentId = :cygateUser.Id];
        //System.assertEquals(noOfChatterPosts, 0, 'No chatter posts should have be created as the event is still open');

        System.runAs(cygateUser) {
            e.ActivityDateTime = System.now() - 1; // start time is one day before now -> event is closed.
            update e;
        }

        //Assert
        Integer noOfChatterPostsAfter = [SELECT COUNT() FROM FeedItem WHERE ParentId = :cygateUser.Id];
        //System.assertEquals(noOfChatterPostsAfter, 1, 'A chatter posts should have be created as the event is closed');
    }

    @isTest
    static void testPostChatterUpdateEventWithInvitees() {
        /*
        List<User> userList = new List<User>();
        User cygateUser;
        Account acc;
        Event e;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            userList.add(Test_DataFactory.createCygateUser());
            userList.add(Test_DataFactory.createCygateUser());
            userList.add(Test_DataFactory.createCygateUser());
            insert userList;
            cygateUser = userList[0];
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;
        }

        System.runAs(cygateUser) {        
            Contact c = Test_DataFactory.createOneContact();
            c.AccountId = acc.Id;
            insert c;

            e = Test_DataFactory.createCygateKundbesokEvent();
            e.WhoId = c.Id;
            e.WhatId = acc.Id;
            e.ActivityDateTime = System.now() + 1; // start time is one day from now -> event is open.
            insert e;
            List<EventRelation> erList = new List<EventRelation>();
            erList.add(Test_DataFactory.createEventRelation(e.Id, userList[1].Id));
            erList.add(Test_DataFactory.createEventRelation(e.Id, userList[2].Id));
            insert erList;
        }

        //Assert
        Integer noOfChatterPosts = [SELECT COUNT() FROM FeedItem WHERE ParentId =: cygateUser.Id];
        System.assertEquals(noOfChatterPosts, 0, 'No chatter posts should have be created as the event is still open');

        System.runAs(cygateUser) {
            e.ActivityDateTime = System.now() - 1; // start time is one day before now -> event is closed.
            update e;
        }

        //Assert
        FeedItem chatterPost = [SELECT Id, Body FROM FeedItem WHERE ParentId =: cygateUser.Id LIMIT 1];
        String chatterText = chatterPost.body;
        System.assert(chatterText.contains(userList[0].LastName), 'The event assigned to should be referenced in the chatter post');
        System.assert(chatterText.contains(userList[1].LastName), 'The event invitee no 1 to should be referenced in the chatter post');
        System.assert(chatterText.contains(userList[2].LastName), 'The event invitee no 2 to should be referenced in the chatter post');
        */
    }

    @isTest(SeeAllData=true)
    static void testPostChatterUpdateEventRelatedToOpp() {
        User cygateUser = Test_DataFactory.createCygateUser();
        Account acc;
        Event e;

        System.runAs(new User(Id = Userinfo.getUserId())) {
            // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;
        }

        System.runAs(cygateUser) {
            test.starttest();
            Contact c = Test_DataFactory.createOneContact();
            c.AccountId = acc.Id;
            c.LastName = c.LastName + System.now().format('yyMMddHHmmss');
            c.Email = 'test' + System.now().format('yyMMddHHmmss') + '@dummy.com';
            insert c;

            e = Test_DataFactory.createCygateKundbesokEvent();
            e.WhoId = c.Id;
            e.WhatId = acc.Id;
            e.Bredda_aff_ren__c = true;
            e.ka_avtalad_aff_r__c = true;
            e.V_xa_befintlig_aff_r__c = true;
            e.Customer_status__c = 'Ny kund';
            e.ActivityDateTime = System.now() + 1; // start time is one day from now -> event is open.
            insert e;
            test.stoptest();
        }

        //Assert
        Integer noOfChatterPosts = [SELECT COUNT() FROM FeedItem WHERE ParentId = :cygateUser.Id];
        //System.assertEquals(noOfChatterPosts, 0, 'No chatter posts should have be created as the event is still open');

        System.runAs(cygateUser) {
            e.ActivityDateTime = System.now() - 1; // start time is one day before now -> event is closed.
            update e;
        }

        //Assert
        Integer noOfChatterPostsAfter = [SELECT COUNT() FROM FeedItem WHERE ParentId = :cygateUser.Id];
        //System.assertEquals(noOfChatterPostsAfter, 1, 'A chatter posts should have be created as the event is closed');
    }
    @isTest(SeeAllData=true)
    static void testUpdateContactActivitiesForEvents() {
        //Author - P.P
        User aUser = new User();
        Account acc = new Account();
        List<Account> accList = new List<Account>();
        Campaign aCampaign = new Campaign();
        Contact aContact = new Contact();
        List<Id> contactIdsList = new List<Id>();
        List<Contact> contactList = new List<Contact>();
        Event aEvent = new Event();
        List<Event> eventList = new List<Event>();
        List<Task> taskList = new List<Task>();

        System.runAs(Test_DataFactory.getByPassUser()) {
            // to avoid MIXED_DML operation
            aUser = Test_DataFactory.createCygateUser();
            insert aUser;

            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = aUser.Id;
            acc.Cygate_Account_Manager__c = aUser.Id;
            accList.add(acc);
            insert accList;

            acc = accList[0];
            aCampaign = Test_DataFactory.createCygateCampaign();
            insert aCampaign;

            aContact = new Contact(
                LastName = 'TestLN' + +System.now().format('yyMMddHHmmss'),
                AccountId = acc.Id,
                FirstName = 'TestFirstName',
                Phone = '+460345678',
                Email = 'testl' + System.now().format('yyMMddHHmmss') + '@dummy.com',
                Role__c = 'Annan',
                Owner = aUser
            );
            contactList.add(aContact);
            insert contactList;

            aContact = contactList[0];
            contactIdsList.add(aContact.Id);
            eventList = Test_DataFactory.createEvents(1);
            taskList = Test_DataFactory.createTasks(1);
        }

        Test.startTest();

        System.runAs(aUser) {
            aEvent = eventList[0];
            aEvent.OwnerId = aUser.Id;
            aEvent.WhoId = aContact.Id;
            insert aEvent;
            Task tL = taskList[0];
            tL.WhoId = aContact.Id;
            tL.OwnerId = aUser.Id;
            insert tL;
        }

        Test.stopTest();

        List<Contact> conSAList = [
            SELECT Id, Telia_Activities__c, Cygate_Activities__c, Other_Activities__c, Service_Management_Activities__c, Marketing_Activities__c
            FROM COntact
            WHERE Id IN :contactIdsList
        ];
        for (contact con : conSAList) {
            if (aContact.Id == con.Id) {
                system.assertequals(con.Telia_Activities__c, false);
                system.assertequals(con.Cygate_Activities__c, true);
            }
        }
    }
    @isTest(SeeAllData=true)
    static void testUpdateFalseContactActivitiesForEvents() {
        //Author - P.P
        User aUser = new User();
        Account acc = new Account();
        List<Account> accList = new List<Account>();
        Campaign aCampaign = new Campaign();
        Contact aContact = new Contact();
        List<Id> contactIdsList = new List<Id>();
        List<Contact> contactList = new List<Contact>();
        Event aEvent = new Event();
        List<Event> eventList = new List<Event>();
        List<Task> taskList = new List<Task>();

        System.runAs(Test_DataFactory.getByPassUser()) {
            // to avoid MIXED_DML operation
            aUser = Test_DataFactory.createCygateUser();
            insert aUser;

            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = aUser.Id;
            acc.Cygate_Account_Manager__c = aUser.Id;
            accList.add(acc);
            insert accList;

            acc = accList[0];
            aCampaign = Test_DataFactory.createCygateCampaign();
            insert aCampaign;

            aContact = new Contact(
                LastName = 'TestLN' + +System.now().format('yyMMddHHmmss'),
                AccountId = acc.Id,
                FirstName = 'TestFirstName',
                Phone = '+460345678',
                Email = 'testl' + System.now().format('yyMMddHHmmss') + '@dummy.com',
                Role__c = 'Annan',
                Cygate_Activities__c = true
            );
            contactList.add(aContact);
            insert contactList;

            aContact = contactList[0];
            contactIdsList.add(aContact.Id);
            eventList = Test_DataFactory.createEvents(1);
            taskList = Test_DataFactory.createTasks(1);
        }

        Test.startTest();

        aEvent = eventList[0];
        aEvent.WhoId = aContact.Id;
        insert aEvent;

        Test.stopTest();

        List<Contact> conSAList = [
            SELECT Id, Telia_Activities__c, Cygate_Activities__c, Other_Activities__c, Service_Management_Activities__c, Marketing_Activities__c
            FROM Contact
            WHERE Id IN :contactIdsList
        ];
        for (contact con : conSAList) {
            if (aContact.Id == con.Id) {
                system.assertequals(con.Telia_Activities__c, true);
                system.assertequals(con.Cygate_Activities__c, false);
            }
        }
    }
    @isTest(SeeAllData=true)
    static void testUpdateContactActivitiesForEventsCSB() {
        User aUser = new User();
        Account acc = new Account();
        List<Account> accList = new List<Account>();
        Contact aContact = new Contact();
        List<Id> contactIdsList = new List<Id>();
        List<Contact> contactList = new List<Contact>();
        Event aEvent = new Event();
        List<Event> eventList = new List<Event>();
        List<Task> taskList = new List<Task>();

        System.runAs(Test_DataFactory.getByPassUser()) {
            // to avoid MIXED_DML operation
            aUser = Test_DataFactory.createFiberUser();
            insert aUser;

            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = aUser.Id;
            acc.Real_Estate_Fiber_Account_Owner__c = aUser.Id;
            accList.add(acc);
            insert accList;

            acc = accList[0];

            aContact = new Contact(
                LastName = 'TestLN' + +System.now().format('yyMMddHHmmss'),
                AccountId = acc.Id,
                FirstName = 'TestFirstName',
                Phone = '+460345678',
                Email = 'testl' + System.now().format('yyMMddHHmmss') + '@dummy.com',
                Role__c = 'Annan',
                Owner = aUser
            );
            contactList.add(aContact);
            insert contactList;

            aContact = contactList[0];
            contactIdsList.add(aContact.Id);
            eventList = Test_DataFactory.createEvents(1);
            taskList = Test_DataFactory.createTasks(1);
        }

        Test.startTest();

        System.runAs(aUser) {
            aEvent = eventList[0];
            aEvent.OwnerId = aUser.Id;
            aEvent.WhoId = aContact.Id;
            insert aEvent;
            Task tL = taskList[0];
            tL.WhoId = aContact.Id;
            tL.OwnerId = aUser.Id;
            insert tL;
        }

        Test.stopTest();

        List<Contact> conSAList = [SELECT Id, Telia_Activities__c, Cygate_Activities__c, C_SB_Activities__c FROM Contact WHERE Id IN :contactIdsList];
        for (contact con : conSAList) {
            if (aContact.Id == con.Id) {
                Assert.isFalse(con.Telia_Activities__c);
                Assert.isFalse(con.Cygate_Activities__c);
                Assert.isTrue(con.C_SB_Activities__c);
            }
        }
    }
    @isTest(SeeAllData=true)
    static void testUpdateFalseContactActivitiesForEventsCSB() {
        User aUser = new User();
        Account acc = new Account();
        List<Account> accList = new List<Account>();
        Contact aContact = new Contact();
        List<Id> contactIdsList = new List<Id>();
        List<Contact> contactList = new List<Contact>();
        Event aEvent = new Event();
        List<Event> eventList = new List<Event>();
        List<Task> taskList = new List<Task>();

        System.runAs(Test_DataFactory.getByPassUser()) {
            // to avoid MIXED_DML operation
            aUser = Test_DataFactory.createFiberUser();
            insert aUser;

            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = aUser.Id;
            acc.Real_Estate_Fiber_Account_Owner__c = aUser.Id;
            accList.add(acc);
            insert accList;

            acc = accList[0];

            aContact = new Contact(
                LastName = 'TestLN' + +System.now().format('yyMMddHHmmss'),
                AccountId = acc.Id,
                FirstName = 'TestFirstName',
                Phone = '+460345678',
                Email = 'testl' + System.now().format('yyMMddHHmmss') + '@dummy.com',
                Role__c = 'Annan',
                C_SB_Activities__c = true
            );
            contactList.add(aContact);
            insert contactList;

            aContact = contactList[0];
            contactIdsList.add(aContact.Id);
            eventList = Test_DataFactory.createEvents(1);
            taskList = Test_DataFactory.createTasks(1);
        }

        Test.startTest();

        aEvent = eventList[0];
        aEvent.WhoId = aContact.Id;
        insert aEvent;

        Test.stopTest();

        List<Contact> conSAList = [SELECT Id, Telia_Activities__c, Cygate_Activities__c, C_SB_Activities__c FROM Contact WHERE Id IN :contactIdsList];
        for (contact con : conSAList) {
            if (aContact.Id == con.Id) {
                Assert.isTrue(con.Telia_Activities__c);
                Assert.isFalse(con.Cygate_Activities__c);
                Assert.isFalse(con.C_SB_Activities__c);
            }
        }
    }

    @isTest
    static void Test_SetSalesResponseOnBI() {
        //System.debug('@@Test Test_PR_addContactToCampaign Starts');
        User fiberusr;
        Account a;
        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User
            fiberusr = Test_DataFactory.createFiberUser();
            insert fiberusr;
            a = Test_DataFactory.createOneAccount();
            a.OwnerId = fiberusr.Id;
            insert a;
        }

        System.runAs(fiberusr) {
            Lead ld = Test_DataFactory.createLead();
            ld.Product_Area__c = 'Healthcare';
            ld.Account__c = a.Id;
            insert ld;

            Buy_Interest__c bi = new Buy_Interest__c();
            bi.Lead__c = ld.Id;
            insert bi;

            Event e = Test_DataFactory.createOneEvent();
            e.WhatId = bi.Id;
            insert e;

            List<Buy_Interest__c> buyI = new List<Buy_Interest__c>([SELECT Id, Sales_rep_response_time__c, Customer_Contacted__c FROM Buy_Interest__c]);
            system.assertEquals(buyI[0].Sales_rep_response_time__c, '0');
            system.assertEquals(buyI[0].Customer_Contacted__c, true);
        }
    }
}