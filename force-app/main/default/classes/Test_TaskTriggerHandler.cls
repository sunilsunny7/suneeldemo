@IsTest
public with sharing class Test_TaskTriggerHandler {

    // SALEF-7949 - ByPass User Username
    public static final String BYPASS_USER_USERNAME = 'test.telia11@telia.com';

    @TestSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
        User byPassUser = Test_DataFactory.getByPassUser();
        // SALEF-7949 - ensure ByPass User Username value
        byPassUser.Username = BYPASS_USER_USERNAME;
        update byPassUser;
        System.runAs(byPassUser) {
            Account oneKundkontoAccount = Test_DataFactory.createOneKundkontoAccount();
            insert oneKundkontoAccount;
            oneKundkontoAccount.Kundkonto_Nr__c = 'Z101';
            update oneKundkontoAccount;
            //update contact Activities test Data
            List<User> newUsers = new List<User>();
            List<Account> newAccounts = new List<Account>();
            List<Contact> newContacts = new List<Contact>();
            List<Campaign> campaigns = new List<Campaign>();
            User renewalUser = Test_DataFactory.createLargeRenewalUser();
            renewalUser.firstname='Large Renewal Test';
            newUsers.add(renewalUser);
            User largeUser = Test_DataFactory.createLargeRenewalUser();
            largeUser.firstname='Large Test';
            newUsers.add(largeUser);
            User cygateUser = Test_DataFactory.createCygateUser();
            cygateUser.firstname='Cygate Test';
            newUsers.add(cygateUser);
            User smeUser = Test_DataFactory.createSMUser();
            smeUser.firstname='SME Test';
            newUsers.add(smeUser);
            User marketingUser = Test_DataFactory.createMarketingUser();
            marketingUser.firstname='Marketing Test';
            newUsers.add(marketingUser);
            User csbUser = Test_DataFactory.createFiberUser();
            csbUser.firstname='CSB Test';
            newUsers.add(csbUser);
            insert newUsers;
            List<Account> accounts = Test_DataFactory.createAccounts(2);
            accounts[0].ParentId = oneKundkontoAccount.Id;
            newAccounts.addAll(accounts);
            Account largeStandardAccount = Test_DataFactory.createOneLargeStandardAccount();
            largeStandardAccount.OwnerId = renewalUser.Id;
            newAccounts.add(largeStandardAccount);
            Account largeStandardAccountCygate = Test_DataFactory.createOneLargeStandardAccount();
            largeStandardAccountCygate.OwnerId = largeUser.Id;
            largeStandardAccountCygate.Cygate_Account_Manager__c = cygateUser.Id;
            newAccounts.add(largeStandardAccountCygate);
            Account largeStandardAccountSME = Test_DataFactory.createOneLargeStandardAccount();
            largeStandardAccountSME.OwnerId = smeUser.Id;
            newAccounts.add(largeStandardAccountSME);
            Account largeStandardAccountMarketing= Test_DataFactory.createOneLargeStandardAccount();
            largeStandardAccountMarketing.OwnerId = marketingUser.Id;
            newAccounts.add(largeStandardAccountMarketing);
            insert newAccounts;
            Campaign camp = Test_DataFactory.createCygateCampaign();
            camp.Name = 'Test Cygate Campaign';
            campaigns.add(camp);
            Contact contactLargeStandard = Test_DataFactory.createOneContact();
            contactLargeStandard.AccountId = largeStandardAccount.Id;
            contactLargeStandard.Email='test3@dummy3.com';
            contactLargeStandard.Other_Activities__c = true;
            newContacts.add(contactLargeStandard);
            Contact contactCygate = Test_DataFactory.createOneContact();
            contactCygate.AccountId = largeStandardAccountCygate.Id;
            contactCygate.Email='test4@dummy4.com';
            contactCygate.Cygate_Activities__c = true;
            contactCygate.Telia_Activities__c = true;
            newContacts.add(contactCygate);
            Contact contactSME = Test_DataFactory.createOneContact();
            contactSME.AccountId = largeStandardAccountSME.Id;
            contactSME.Email='test5@dummy5.com';
            contactSME.Service_Management_Activities__c = true;
            contactSME.Marketing_Activities__c = true;
            newContacts.add(contactSME);
            Contact contactMarketing = Test_DataFactory.createOneContact();
            contactMarketing.AccountId = largeStandardAccountMarketing.Id;
            contactMarketing.Email='test6@dummy6.com';
            contactMarketing.Marketing_Activities__c = true;
            contactMarketing.Service_Management_Activities__c = true;
            newContacts.add(contactMarketing);
            Contact contactCSB = Test_DataFactory.createOneContact();
            contactCSB.AccountId = largeStandardAccountMarketing.Id;
            contactCSB.Email='test7@dummy7.com';
            contactCSB.C_SB_Activities__c = true;
            newContacts.add(contactCSB);
            Contact oneContact = Test_DataFactory.createOneContact();
            oneContact.Deactivation_Date__c = System.today();
            oneContact.AccountId = accounts[0].Id;
            newContacts.add(oneContact);
            Contact activeContact = Test_DataFactory.createOneContact();
            activeContact.FirstName='NewContactActive';
            activeContact.LastName='newTestContact';
            activeContact.Email='test1@dummy1.com';
            activeContact.AccountId = accounts[1].Id;
            newContacts.add(activeContact);
            Contact activeContact2 = Test_DataFactory.createOneContact();
            activeContact2.FirstName='NewContactActive';
            activeContact2.LastName='newTestContact';
            activeContact2.Email='test2@dummy2.com';
            activeContact2.AccountId = accounts[1].Id;
            newContacts.add(activeContact2);
            insert newContacts;
            Campaign oneCampaign = Test_DataFactory.createTeliaCampaign();
            campaigns.add(oneCampaign);
            insert campaigns;
            CampaignMember oneCampaignMember = new CampaignMember(CampaignId = oneCampaign.Id, ContactId = activeContact.Id, status = 'Ringt', Bounce_reason__c ='Test');
            insert oneCampaignMember;
            Opportunity oneOpportunity = Test_DataFactory.createOpportunity();
            oneOpportunity.CampaignId = oneCampaign.Id;
            insert oneOpportunity;
            User fiberUser = Test_DataFactory.createFiberUser();
            insert fiberUser;
            Call_Activity__c oneCallActivity = Test_DataFactory.createCallActivity(oneCampaign.Id ,accounts[1].Id);
            insert oneCallActivity;
        }
    }
    @IsTest
    static void validateContactIsActiveTest() {
        Id newContact = [SELECT Id FROM Contact WHERE Inaktiv__c = true].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].WhoId = newContact;
        Test.startTest();
        Database.SaveResult result = Database.insert(tasks[0], false);
        Test.stopTest();
        System.assertEquals(false, result.isSuccess());
        System.assertEquals(1, result.getErrors().size());
    }
    @IsTest
    static void validateAccountNotTerminatedTest() {
        Id newAccount = [SELECT Id FROM Account WHERE Parent.Kundkonto_Nr__c = 'Z101' LIMIT 1].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].WhatId = newAccount;
        Test.startTest();
        Database.SaveResult result = Database.insert(tasks[0], false);
        Test.stopTest();
        System.assertEquals(false, result.isSuccess());
        System.assertEquals(1, result.getErrors().size());
    }
    @IsTest
    static void updateOpportunityOnTaskInsertTest() {
        Id newOpportunity = [SELECT Id FROM Opportunity WHERE Comment_to_Reason__c = 'testcomment'].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].WhatId = newOpportunity;
        Test.startTest();
        insert tasks;
        Test.stopTest();
        Task updatedTask = [SELECT Id, Opportunity__c FROM Task];
        System.assertEquals(newOpportunity, updatedTask.Opportunity__c);
    }
    @IsTest
    static void updateOpportunityOnTaskUpdateTest() {
        Id newOpportunity = [SELECT Id FROM Opportunity WHERE Comment_to_Reason__c = 'testcomment'].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);

        Test.startTest();
        insert tasks;
        tasks[0].WhatId = newOpportunity;
        update tasks;
        Test.stopTest();
        Task updatedTask = [SELECT Id, Opportunity__c FROM Task];
        System.assertEquals(newOpportunity, updatedTask.Opportunity__c);
    }
    @IsTest
    static void updateOpportunityOnTaskUpdateToEmptyTest() {
        Id newOpportunity = [SELECT Id FROM Opportunity WHERE Comment_to_Reason__c = 'testcomment'].Id;
        Id newAccount = [SELECT Id FROM Account WHERE ParentId = NULL AND Kundkonto_Nr__c = NULL LIMIT 1].Id;
        Test.startTest();
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].WhatId = newOpportunity;
        insert tasks;
        tasks[0].WhatId = newAccount;
        update tasks;
        Test.stopTest();
        Task updatedTask = [SELECT Id, Opportunity__c FROM Task];
        System.assertEquals(null, updatedTask.Opportunity__c);
    }
    @IsTest
    static void updateCampaignOnTaskInsertTest() {
        Id newCampaign = [SELECT Id FROM Campaign WHERE name = 'Test Campaign'].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].WhatId = newCampaign;
        tasks[0].Subject = 'updated to Mail Klickat';
        Test.startTest();
        insert tasks;
        Test.stopTest();
        Task updatedTask = [SELECT Id, Campaign__c FROM Task];
        System.assertEquals(newCampaign, updatedTask.Campaign__c);
    }
    @IsTest
    static void updateCampaignOnTaskInsertWhenItHaveOpportunityTest() {
        Id newCampaign = [SELECT Id FROM Campaign WHERE name = 'Test Campaign'].Id;
        Id newOpportunity = [SELECT Id FROM Opportunity WHERE Comment_to_Reason__c = 'testcomment'].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].WhatId = newOpportunity;
        tasks[0].Opportunity__c = newOpportunity;
        Test.startTest();
        insert tasks;
        Test.stopTest();
        Task updatedTask = [SELECT Id, Campaign__c FROM Task];
        System.assertEquals(newCampaign, updatedTask.Campaign__c);
    }
    @IsTest
    static void updateCampaignOnTaskUpdateTest() {
        Id newCampaign = [SELECT Id FROM Campaign WHERE name = 'Test Campaign'].Id;
        Id newOpportunity = [SELECT Id FROM Opportunity WHERE Comment_to_Reason__c = 'testcomment'].Id;
        Test.startTest();
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].Opportunity__c = newOpportunity;
        insert tasks;
        tasks[0].WhatId = newCampaign;
        update tasks;
        Test.stopTest();
        Task updatedTask = [SELECT Id, Campaign__c FROM Task];
        System.assertEquals(newCampaign, updatedTask.Campaign__c);
    }
    @IsTest
    static void updateCampaignOnTaskUpdateWithOpportunityTest() {
        Id newCampaign = [SELECT Id FROM Campaign WHERE name = 'Test Campaign'].Id;
        Id newOpportunity = [SELECT Id FROM Opportunity WHERE Comment_to_Reason__c = 'testcomment'].Id;
        Test.startTest();
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].Opportunity__c = newOpportunity;
        insert tasks;
        tasks[0].WhatId = newOpportunity;
        update tasks;
        Test.stopTest();
        Task updatedTask = [SELECT Id, Campaign__c FROM Task];
        System.assertEquals(newCampaign, updatedTask.Campaign__c);
    }
    @IsTest
    static void updateAccountContactedDateWithoutActivityDateTest() {
        Id newAccount = [SELECT Id FROM Account LIMIT 1].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].Account__c = newAccount;
        tasks[0].Status = 'Stängd';
        tasks[0].Type = 'Telefon';
        Test.startTest();
        insert tasks;
        Test.stopTest();
        Account updatedAccount = [SELECT Id, Contacted__c FROM Account WHERE id = :newAccount];
        System.assertEquals(Date.today(), updatedAccount.Contacted__c);
    }
    @IsTest
    static void updateAccountContactedDateWithActivityDateTest() {
        Id newAccount = [SELECT Id FROM Account LIMIT 1].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].Account__c = newAccount;
        tasks[0].Status = 'Stängd';
        tasks[0].Type = 'Telefon';
        tasks[0].ActivityDate = Date.today();
        Test.startTest();
        insert tasks;
        Test.stopTest();
        Account updatedAccount = [SELECT Id, Contacted__c FROM Account WHERE id = :newAccount];
        System.assertEquals(Date.today(), updatedAccount.Contacted__c);
    }
    @IsTest
    static void updateAccountContactedDateWithActivityDateReviewTest() {
        Id newAccount = [SELECT Id FROM Account LIMIT 1].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].Account__c = newAccount;
        tasks[0].Status = 'Stängd';
        tasks[0].Type = 'Telefon';
        tasks[0].ActivityDate = Date.today();
        tasks[0].Review_MyBusiness__c = true;
        Test.startTest();
        insert tasks;
        Test.stopTest();
        Account updatedAccount = [SELECT Id, Contacted__c FROM Account WHERE id = :newAccount];
        System.assertEquals(Date.today(), updatedAccount.Contacted__c);
    }
    @IsTest
    static void updateAccountContactedDateWithoutActivityDateReviewTest() {
        Id newAccount = [SELECT Id FROM Account LIMIT 1].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].Account__c = newAccount;
        tasks[0].Status = 'Stängd';
        tasks[0].Type = 'Telefon';
        tasks[0].Review_MyBusiness__c = true;
        Test.startTest();
        insert tasks;
        Test.stopTest();
        Account updatedAccount = [SELECT Id, Contacted__c FROM Account WHERE id = :newAccount];
        System.assertEquals(Date.today(), updatedAccount.Contacted__c);
    }
    @IsTest
    static void setAccountCSBContactedDateTest() {
        Id newAccount = [SELECT Id FROM Account LIMIT 1].Id;
        User fiberUser = [SELECT Id FROM User WHERE profile.name = 'Fiber Base Profile' AND isActive = TRUE LIMIT 1];
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].WhatId = newAccount;
        Test.startTest();
        system.runAs(fiberUser){
            insert tasks;
        }
        Test.stopTest();
        Account updatedAccount = [SELECT Id, C_SB_Contacted__c FROM Account WHERE id = :newAccount];
        System.assertEquals(Date.today(), updatedAccount.C_SB_Contacted__c);
    }
    @IsTest
    // This test don't have assert need to update it.
    static void updateCampaignMemberStatusesTest() {
        Campaign newCampaign = [SELECT Id, Type, RecordTypeId, isActive FROM Campaign WHERE Name = 'Test Campaign'];
        newCampaign.Type = 'Apsis';
        update newCampaign;
        Id newContact = [SELECT Id FROM Contact WHERE Email='test1@dummy1.com' LIMIT 1].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].WhoId = newContact;
        tasks[0].WhatId = newCampaign.Id;
        tasks[0].Subject = 'Call';
        Test.startTest();
        insert tasks;
        Test.stopTest();
    }
    @IsTest
    static void insertPR_addContactToCampaignTest() {
        Id oneCallActivity = [SELECT Id FROM Call_Activity__c].Id;
        Id newContact = [SELECT Id FROM Contact WHERE Email='test2@dummy2.com'].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].Status = TaskTriggerHandler.STATUS_CLOSED;
        tasks[0].Call_Status__c = TaskTriggerHandler.STATUS_CONTACTED;
        tasks[0].Type = TaskTriggerHandler.TYPE_PHONE;
        tasks[0].PR_Not_Interested__c = false;
        tasks[0].Call_Activity__c = oneCallActivity;
        tasks[0].WhoId = newContact;
        tasks[0].RecordTypeId = '012240000006rBSAAY';
        Test.startTest();
        insert tasks;
        Test.stopTest();
        CampaignMember campaignMember = [SELECT Id, ContactId, CampaignId FROM CampaignMember WHERE Bounce_reason__c !='Test' LIMIT 1];
        System.assertEquals(campaignMember.ContactId, newContact, 'Campaign Member have wrong contact');
    }
    @IsTest
    static void insertPR_setPrNotInterestedTest() {
        Id oneCallActivity = [SELECT Id FROM Call_Activity__c].Id;
        Id newContact = [SELECT Id FROM Contact WHERE Email='test2@dummy2.com'].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].Status = TaskTriggerHandler.STATUS_CLOSED;
        tasks[0].Call_Status__c = TaskTriggerHandler.STATUS_CONTACTED;
        tasks[0].Type = TaskTriggerHandler.TYPE_PHONE;
        tasks[0].PR_Not_Interested__c = true;
        tasks[0].Call_Activity__c = oneCallActivity;
        tasks[0].WhoId = newContact;
        tasks[0].RecordTypeId = '012240000006rBSAAY';
        Test.startTest();
        insert tasks;
        Test.stopTest();
        Call_Activity__c updateCallActivity = [SELECT Id, Is_PR_Not_Interested__c FROM Call_Activity__c WHERE Id = :oneCallActivity LIMIT 1];
        System.assertEquals(updateCallActivity.Is_PR_Not_Interested__c, true);
    }
    @IsTest
    static void standardLargeUpdateContactActivitiesOnInsertTest() {
        Id newUser = [SELECT Id FROM User WHERE firstname ='Large Renewal Test'].Id;
        Id newContact = [SELECT Id FROM Contact WHERE Email='test3@dummy3.com'].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].OwnerId = newUser;
        tasks[0].WhoId = newContact;
        Test.startTest();
        insert tasks;
        Test.stopTest();
        Contact updatedContact = [SELECT Id, Other_Activities__c FROM Contact WHERE Id = :newContact LIMIT 1];
        System.assertEquals(updatedContact.Other_Activities__c, false);
    }
    @IsTest
    static void cygateUpdateContactActivitiesOnInsertTest() {
        Id newUser = [SELECT Id FROM User WHERE firstname ='Cygate Test'].Id;
        Id newContact = [SELECT Id FROM Contact WHERE Email='test4@dummy4.com'].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].OwnerId = newUser;
        tasks[0].WhoId = newContact;
        Test.startTest();
        insert tasks;
        Test.stopTest();
        Contact updatedContact = [SELECT Id, Cygate_Activities__c FROM Contact WHERE Id = :newContact LIMIT 1];
        System.assertEquals(updatedContact.Cygate_Activities__c, false);
    }
    @IsTest
    static void smeUpdateContactActivitiesOnInsertTest() {
        Id newUser = [SELECT Id FROM User WHERE firstname ='SME Test'].Id;
        Id newContact = [SELECT Id FROM Contact WHERE Email='test5@dummy5.com'].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].OwnerId = newUser;
        tasks[0].WhoId = newContact;
        Test.startTest();
        insert tasks;
        Test.stopTest();
        Contact updatedContact = [SELECT Id, Service_Management_Activities__c FROM Contact WHERE Id = :newContact LIMIT 1];
        System.assertEquals(updatedContact.Service_Management_Activities__c, false);
    }
    @IsTest
    static void marketingUpdateContactActivitiesOnInsertTest() {
        Id newUser = [SELECT Id FROM User WHERE firstname ='Marketing Test'].Id;
        Id newContact = [SELECT Id FROM Contact WHERE Email='test6@dummy6.com'].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].OwnerId = newUser;
        tasks[0].WhoId = newContact;
        Test.startTest();
        insert tasks;
        Test.stopTest();
        Contact updatedContact = [SELECT Id, Marketing_Activities__c FROM Contact WHERE Id = :newContact LIMIT 1];
        System.assertEquals(updatedContact.Marketing_Activities__c, false);
    }
    @IsTest
    static void csbUpdateContactActivitiesOnInsertTest() {
        Id newUser = [SELECT Id FROM User WHERE firstname ='CSB Test'].Id;
        Id newContact = [SELECT Id FROM Contact WHERE Email='test7@dummy7.com'].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].OwnerId = newUser;
        tasks[0].WhoId = newContact;
        Test.startTest();
        insert tasks;
        Test.stopTest();
        Contact updatedContact = [SELECT Id, C_SB_Activities__c FROM Contact WHERE Id = :newContact LIMIT 1];
        System.assertEquals(updatedContact.C_SB_Activities__c, false);
    }
    @IsTest
    static void marketingUpdateContactActivitiesOnDeleteTest() {
        Id newUser = [SELECT Id FROM User WHERE firstname ='Marketing Test'].Id;
        Id newContact = [SELECT Id FROM Contact WHERE Email='test6@dummy6.com'].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].OwnerId = newUser;
        tasks[0].WhoId = newContact;
        Test.startTest();
        insert tasks;
        delete tasks;
        Test.stopTest();
        Contact updatedContact = [SELECT Id, Marketing_Activities__c FROM Contact WHERE Id = :newContact LIMIT 1];
        System.assertEquals(updatedContact.Marketing_Activities__c, false);
    }
    @IsTest
    static void updateContactActivitiesOnUpdateTest() {
        Id newUser = [SELECT Id FROM User WHERE firstname ='Marketing Test'].Id;
        Id newContact = [SELECT Id FROM Contact WHERE Email='test6@dummy6.com'].Id;
        Id newContactOther = [SELECT Id FROM Contact WHERE Email='test5@dummy5.com'].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].OwnerId = newUser;
        tasks[0].WhoId = newContact;
        Test.startTest();
        insert tasks;
        tasks[0].WhoId = newContactOther;
        update tasks;
        Test.stopTest();
        Contact updatedContact = [SELECT Id, Marketing_Activities__c FROM Contact WHERE Id = :newContactOther LIMIT 1];
        System.assertEquals(updatedContact.Marketing_Activities__c, false);
    }
    @IsTest
    static void updateContactActivitiesOnUpdateOwnerTest() {
        Id newUser = [SELECT Id FROM User WHERE firstname ='Marketing Test'].Id;
        Id newContact = [SELECT Id FROM Contact WHERE Email='test6@dummy6.com'].Id;
        Id newUserOther = [SELECT Id FROM User WHERE firstname ='SME Test'].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].OwnerId = newUser;
        tasks[0].WhoId = newContact;
        Test.startTest();
        insert tasks;
        tasks[0].OwnerId = newUserOther;
        update tasks;
        Test.stopTest();
        Contact updatedContact = [SELECT Id, Service_Management_Activities__c FROM Contact WHERE Id = :newContact LIMIT 1];
        System.assertEquals(updatedContact.Service_Management_Activities__c, false);
    }
    @IsTest
    static void updateSalesResponseTimeOnBITest() {
        Test.startTest();
        Id newAccount = [SELECT Id FROM Account LIMIT 1].Id;
        User fiberUser = [SELECT Id FROM User WHERE profile.name = 'Fiber Base Profile' AND isActive = TRUE LIMIT 1];
        System.runAs(fiberUser){
            Lead newLead = Test_DataFactory.createLead();
            newLead.Product_Area__c='Healthcare';
            newLead.Account__c= newAccount;
            newLead.OwnerId = fiberUser.id;
            insert newLead;
            Buy_Interest__c newBuyInterest = new Buy_Interest__c();
            newBuyInterest.Lead__c=newLead.Id;
            newBuyInterest.OwnerId = fiberUser.id;
            insert newBuyInterest;
            Task newTask = Test_DataFactory.createOneTask();
            newTask.WhatId=newBuyInterest.Id;
            insert newTask;
        }
        Test.stopTest();
        Buy_Interest__c updateBuyInterest = [SELECT Id,Sales_rep_response_time__c,Customer_Contacted__c FROM Buy_Interest__c LIMIT 1];
        system.assertEquals(updateBuyInterest.Sales_rep_response_time__c, '0');
        system.assertEquals(updateBuyInterest.Customer_Contacted__c , true);
    }
    /**@Description:
         * Test updateAccountContactedDate() method when Activity 'Due Date'
         * has been set, Account 'Contacted...' fields are empty, and Activity
         * 'Quality Meeting' checkbox has been checked.
         * Modifications:
         *  04.01.2022 [TB] SALEF-7949 - Introduced.
         **/
    @IsTest
    static void updateAccountContactedDateWithActivityDateQualityMeeting() {
        User byPassUser = [SELECT Id FROM User WHERE Username = :BYPASS_USER_USERNAME];
        Id newAccount = [SELECT Id FROM Account LIMIT 1].Id;
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].Account__c = newAccount;
        tasks[0].Status = 'Stängd';
        tasks[0].Type = 'Telefon';
        tasks[0].Review_MyBusiness__c = false;
        tasks[0].Quality_Meeting__c = true;
        // Date.today() returns the date according to the User's time zone. Therefore, both
        // assertion and Task insertion/date assignments must be performed within the same
        // User context.
        System.runAs(byPassUser){
            Test.startTest();
            tasks[0].ActivityDate = Date.today();
            insert tasks;
            Test.stopTest();
            Account updatedAccount = [  SELECT Id, Contacted__c, SME_Contacted_MyBusiness__c, Contacted_Quality_Meeting__c
            FROM Account
            WHERE id = :newAccount];
            System.assertEquals(Date.today(), updatedAccount.Contacted__c);
            System.assertEquals(Date.today(), updatedAccount.Contacted_Quality_Meeting__c);
            System.assertEquals(null, updatedAccount.SME_Contacted_MyBusiness__c);
        }
    }

    /**@Description:
	 * Test updateAccountContactedDate() method when Activity 'Due Date'
     * has been set, Account 'Contacted...' fields contain a date earlier than the Activity
     * 'Due Date', and 'Quality Meeting' checkbox has been checked.
     * Modifications:
     *  04.01.2022 [TB] SALEF-7949 - Introduced.
     **/
    @IsTest
    static void updateLessRecentAccountContactedDate() {
        User byPassUser = [SELECT Id FROM User WHERE Username = :BYPASS_USER_USERNAME];
        Account newAccount = [SELECT Id FROM Account LIMIT 1];
        List<Task> tasks = Test_DataFactory.createTasks(1);
        tasks[0].Account__c = newAccount.Id;
        tasks[0].Status = 'Stängd';
        tasks[0].Type = 'Telefon';
        // Date.today() returns the date according to the User's time zone. Therefore, both
        // assertion and Date-type field value assignments must be performed within the same
        // User context.
        System.runAs(byPassUser){
            Test.startTest();
            newAccount.Contacted__c = Date.today().addDays(-1);
            update newAccount;
            tasks[0].ActivityDate = Date.today();
            insert tasks;
            Test.stopTest();
            Account updatedAccount = [SELECT Id, Contacted__c FROM Account WHERE id = :newAccount.Id];
            System.assertEquals(Date.today(), updatedAccount.Contacted__c);
        }
    }
}