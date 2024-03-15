/**
About
-----
Description: Test Class Test_LeadTriggerHandler on Lead for LeadTriggerHandler
Create date: 26.10-2016

Update History
--------------
Created Oct 2016 - A.N - New test methods no01-no03 for setContactTeliaResellerId SAEN 1909/1923
Updated Oct 2016 - A.N - New test methods no04-no11 for createBuyInterestOnPardotSync and updateBuyInterestsOnLeadChange SAEN 1909/1926.
Updated Oct 2016 - N.G - New test methods no14-no18 for populateAccLookup SAEN 1898.
Updated Oct 2016 - A.N - New test method no09 for issue if Telia Id is provided in different case (lower/upper case) than stored in DB SAEN 1909/1926.
Updated Oct 2016 - A.N - New test methods no12 for updateBuyInterestsOnLeadChange, copy queue owner SAEN 1982.
Updated Oct 2016 - A.N - New test methods no13 for updateBuyInterestsOnLeadChange, copy Status/Lead Close reason to But Interest SAEN 1982.
Updated Dec 2016 - A.N - SAEN-2103 New test methods no22-24 for setResellerAccountName 
Created Oct 2019 - S.K - New test method for no37_testaddCampaignMemberLead() SALEF-2429
Created May 2022 - L.S - New test method for createTaskInBuyIntUnitTest() SALEF-6683


Issues / TODOs
--------------    
*/
@isTest
public with sharing class Test_LeadTriggerHandler {
    
    public static testmethod void no01_testSetContactTeliaId() {
        System.debug('@@Test no01_testSetContactTeliaId Starts');
        Test_DataFactory.setUpOrg();
        
        Lead lead;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            lead = Test_DataFactory.createLead();
            lead.Lead_Submitter_ID__c = 'TELIAID';
            lead.LeadSource = LeadTriggerHandler.LEAD_SOURCE_TELIA_INTRANET;
            insert lead;
        }
        
        Lead leadAfterInsert = [SELECT Id, Lead_Submitter_ID__c, Telia_Employee_Telia_Id__c, Reseller_Tholbox_ID__c FROM Lead LIMIT 1];
        
        System.assertEquals(leadAfterInsert.Lead_Submitter_ID__c, 'TELIAID', 'Incorrect Lead_Submitter_ID__c');
        System.assertEquals(leadAfterInsert.Telia_Employee_Telia_Id__c, 'TELIAID', 'Incorrect Telia_Employee_Telia_Id__c');
        System.assertEquals(leadAfterInsert.Reseller_Tholbox_ID__c, null, 'Reseller_Tholbox_ID__c should not be set');
    }
    
    public static testmethod void no02_testSetContactResellerId() {
        System.debug('@@Test no02_testSetContactResellerId Starts');
        Test_DataFactory.setUpOrg();
        
        Lead lead;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            lead = Test_DataFactory.createLead();
            lead.Lead_Submitter_ID__c = 'RESELLERID';
            lead.LeadSource = LeadTriggerHandler.LEAD_SOURCE_RESELLER;
            insert lead;
        }
        
        Lead leadAfterInsert = [SELECT Id, Lead_Submitter_ID__c, Telia_Employee_Telia_Id__c, Reseller_Tholbox_ID__c FROM Lead LIMIT 1];
        
        System.assertEquals(leadAfterInsert.Lead_Submitter_ID__c, 'RESELLERID', 'Incorrect Lead_Submitter_ID__c');
        System.assertEquals(leadAfterInsert.Telia_Employee_Telia_Id__c, null, 'Telia_Employee_Telia_Id__c should not be set');
        System.assertEquals(leadAfterInsert.Reseller_Tholbox_ID__c, 'RESELLERID', 'Incorrect Reseller_Tholbox_ID__c');
    }
    
    public static testmethod void no03_testSetContactteliaResellerId_invalidSource() {
        System.debug('@@Test no03_testSetContactteliaResellerId_invalidSource Starts');
        Test_DataFactory.setUpOrg();
        
        Lead lead;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            lead = Test_DataFactory.createLead();
            lead.Lead_Submitter_ID__c = 'RANDOM_ID';
            // This is a SF standard Lead Source that should not map to Telia/Reseller contacts.
            lead.LeadSource = 'Advertisement';
            insert lead;
        }
        
        Lead leadAfterInsert = [SELECT Id, Lead_Submitter_ID__c, Telia_Employee_Telia_Id__c, Reseller_Tholbox_ID__c FROM Lead LIMIT 1];
        
        System.assertEquals(leadAfterInsert.Lead_Submitter_ID__c, 'RANDOM_ID', 'Incorrect Lead_Submitter_ID__c');
        System.assertEquals(leadAfterInsert.Telia_Employee_Telia_Id__c, null, 'Telia_Employee_Telia_Id__c should not be set');
        System.assertEquals(leadAfterInsert.Reseller_Tholbox_ID__c, null, 'Reseller_Tholbox_ID__c should not be set');
    }
    
    public static testmethod void no04_testCreateBuyInterestOnPardotSyncNewLead() {
        System.debug('@@Test no04_testCreateBuyInterestOnPardotSync Starts');
        Test_DataFactory.setUpOrg();
        
        Lead lead;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            lead = Test_DataFactory.createPardotLead();
            lead.Product_Area__c = LeadTriggerHandler.LEAD_PRODAREA_BB;
            lead.Description_Pardot__c = 'TEST DESCRIPTION INSERT';
            insert lead;
        }
        
        Lead leadAfterInsert = [SELECT Id,
                                (SELECT Status__c, Description__c, Form_Source__c, Form_Source_URL__c, Lead_Source__c, Name, Interest_Broadband__c,
                                 Interest_Cloud_Services__c, Interest_Company_Network__c, Interest_Contact_Center__c, Interest_Expert_and_Service_Duties__c,
                                 Interest_IOT__c, Interest_Meeting_Services__c, Interest_Other__c, Interest_Support_Services__c, Interest_Switches__c,
                                 Interest_Telephony__c FROM Buy_Interests__r)
                                FROM Lead LIMIT 1
                               ];
        
        System.assertEquals(leadAfterInsert.Buy_Interests__r.size(), 1, 'There should be exactly one Buy Interest created for the Lead');
        
        Buy_Interest__c bi = leadAfterInsert.Buy_Interests__r[0];
        System.assertEquals(bi.Status__c, 'Nytt', 'Incorrect Buy interest value for field Status__c');
        System.assertEquals(lead.Description_Pardot__c, 'TEST DESCRIPTION INSERT', 'Incorrect Description_Pardot__c on Lead');
        System.assertEquals(bi.Description__c, 'TEST DESCRIPTION INSERT', 'Incorrect Buy interest value for field Description__c');
        System.assertEquals(bi.Form_Source__c, lead.Form_Source__c, 'Incorrect Buy interest value for field Form_Source__c');
        System.assertEquals(bi.Form_Source_URL__c, lead.Form_Source_URL__c, 'Incorrect Buy interest value for field Form_Source_URL__c');
        System.assertEquals(bi.Lead_Source__c, lead.LeadSource, 'Incorrect Buy interest value for field Lead_Source__c');
        System.assertEquals(bi.Name, lead.Product_Area__c, 'Incorrect Buy interest value for field Name');
        System.assertEquals(bi.Interest_Broadband__c, true, 'Incorrect Buy interest value for field Interest_Broadband__c');
        System.assertEquals(bi.Interest_Cloud_Services__c, false, 'Incorrect Buy interest value for field Interest_Cloud_Services__c');
        System.assertEquals(bi.Interest_Company_Network__c, false, 'Incorrect Buy interest value for field Interest_Company_Network__c');
        System.assertEquals(bi.Interest_Contact_Center__c, false, 'Incorrect Buy interest value for field Interest_Contact_Center__c');
        System.assertEquals(bi.Interest_Expert_and_Service_Duties__c, false, 'Incorrect Buy interest value for field Interest_Expert_and_Service_Duties__c');
        System.assertEquals(bi.Interest_IOT__c, false, 'Incorrect Buy interest value for field Interest_IOT__c');
        System.assertEquals(bi.Interest_Meeting_Services__c, false, 'Incorrect Buy interest value for field Interest_Meeting_Services__c');
        System.assertEquals(bi.Interest_Other__c, false, 'Incorrect Buy interest value for field Interest_Other__c');
        System.assertEquals(bi.Interest_Support_Services__c, false, 'Incorrect Buy interest value for field Interest_Support_Services__c');
        System.assertEquals(bi.Interest_Switches__c, false, 'Incorrect Buy interest value for field Interest_Switches__c');
        System.assertEquals(bi.Interest_Telephony__c, false, 'Incorrect Buy interest value for field Interest_Telephony__c');
    }
    
    public static testmethod void no05_testCreateBuyInterestOnPardotSyncUpdatedLead() {
        System.debug('@@Test no05_testCreateBuyInterestOnPardotSyncUpdatedLead Starts');
        Test_DataFactory.setUpOrg();
        
        Lead lead;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            lead = Test_DataFactory.createPardotLead();
            lead.Product_Area__c = LeadTriggerHandler.LEAD_PRODAREA_BB;
            insert lead;
        }
        
        Lead leadAfterInsert = [SELECT Id, Pardot_Sync__c, Description_Pardot__c,
                                (SELECT Status__c, Description__c, Form_Source__c, Form_Source_URL__c, Lead_Source__c, Name, Interest_Broadband__c,
                                 Interest_Cloud_Services__c, Interest_Company_Network__c, Interest_Contact_Center__c, Interest_Expert_and_Service_Duties__c,
                                 Interest_IOT__c, Interest_Meeting_Services__c, Interest_Other__c, Interest_Support_Services__c, Interest_Switches__c,
                                 Interest_Telephony__c FROM Buy_Interests__r)
                                FROM Lead LIMIT 1
                               ];
        
        System.assertEquals(leadAfterInsert.Buy_Interests__r.size(), 1, 'There should be exactly one Buy Interest created for the Lead');
        Buy_Interest__c biInsert = leadAfterInsert.Buy_Interests__r[0];
        
        System.runAs(new User(Id = Userinfo.getUserId())) {
            lead.Pardot_Sync__c += 1;
            lead.Product_Area__c = LeadTriggerHandler.LEAD_PRODAREA_CS;
            lead.Description_Pardot__c = 'TEST UPDATED DESC';
            LeadTriggerHandler.pardotLeadsBuyInterestCreated = false;
            update lead;
        }
        
        Lead leadAfterUpdate = [SELECT Id, Pardot_Sync__c, Description_Pardot__c,
                                (SELECT Id, Status__c, Description__c, Form_Source__c, Form_Source_URL__c, Lead_Source__c, Name, Interest_Broadband__c,
                                 Interest_Cloud_Services__c, Interest_Company_Network__c, Interest_Contact_Center__c, Interest_Expert_and_Service_Duties__c,
                                 Interest_IOT__c, Interest_Meeting_Services__c, Interest_Other__c, Interest_Support_Services__c, Interest_Switches__c,
                                 Interest_Telephony__c FROM Buy_Interests__r WHERE Id !=: biInsert.Id)
                                FROM Lead LIMIT 1
                               ];
        
        System.assertEquals(leadAfterUpdate.Buy_Interests__r.size(), 1, 'There should be a new Buy Interests created for the Lead');
        System.assertEquals(leadAfterUpdate.Pardot_Sync__c, leadAfterInsert.Pardot_Sync__c + 1, 'The Pardot_Sync__c value on Lead should have been incremented by one');
        
        Buy_Interest__c biUpdate = leadAfterUpdate.Buy_Interests__r[0];
        
        System.assertEquals(biUpdate.Status__c, 'Nytt', 'Incorrect Buy interest value for field Status__c');
        
        System.assertEquals(leadAfterUpdate.Description_Pardot__c, '-', 'Incorrect Description_Pardot__c on Lead');
        System.assertEquals(biUpdate.Description__c, 'TEST UPDATED DESC', 'Incorrect Buy interest value for field Description__c');
        System.assertNotEquals(biUpdate.Description__c, biInsert.Description__c, 'Buy interest value for field Description__c should not be the same for both Buy interests');
        
        System.assertEquals(biUpdate.Name, lead.Product_Area__c, 'Incorrect Buy interest value for field Name');
        System.assertNotEquals(biUpdate.Name, biInsert.Name, 'Buy interest value for field Name should not be the same for both Buy interests');
        
        System.assertEquals(biUpdate.Form_Source__c, lead.Form_Source__c, 'Incorrect Buy interest value for field Form_Source__c');
        System.assertEquals(biUpdate.Form_Source__c, biInsert.Form_Source__c, 'Buy interest value for field Form_Source__c should be the same for both Buy interests');
        
        System.assertEquals(biUpdate.Interest_Broadband__c, false, 'Incorrect Buy interest value for field Interest_Broadband__c');
        System.assertEquals(biUpdate.Interest_Cloud_Services__c, true, 'Incorrect Buy interest value for field Interest_Cloud_Services__c');
        System.assertEquals(biUpdate.Interest_Company_Network__c, false, 'Incorrect Buy interest value for field Interest_Company_Network__c');
        System.assertEquals(biUpdate.Interest_Contact_Center__c, false, 'Incorrect Buy interest value for field Interest_Contact_Center__c');
        System.assertEquals(biUpdate.Interest_Expert_and_Service_Duties__c, false, 'Incorrect Buy interest value for field Interest_Expert_and_Service_Duties__c');
        System.assertEquals(biUpdate.Interest_IOT__c, false, 'Incorrect Buy interest value for field Interest_IOT__c');
        System.assertEquals(biUpdate.Interest_Meeting_Services__c, false, 'Incorrect Buy interest value for field Interest_Meeting_Services__c');
        System.assertEquals(biUpdate.Interest_Other__c, false, 'Incorrect Buy interest value for field Interest_Other__c');
        System.assertEquals(biUpdate.Interest_Support_Services__c, false, 'Incorrect Buy interest value for field Interest_Support_Services__c');
        System.assertEquals(biUpdate.Interest_Switches__c, false, 'Incorrect Buy interest value for field Interest_Switches__c');
        System.assertEquals(biUpdate.Interest_Telephony__c, false, 'Incorrect Buy interest value for field Interest_Telephony__c');
    }
    
    public static testmethod void no06_testNoBuyInterestIfPardotSyncFalse() {
        System.debug('@@Test no06_testNoBuyInterestIfPardotSyncFalse Starts');
        Test_DataFactory.setUpOrg();
        
        Lead lead;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            lead = Test_DataFactory.createPardotLead();
            // Setting Pardot_Sync to null. No Buy Interests should be created
            lead.Pardot_Sync__c = null;
            insert lead;
        }
        
        Lead leadAfterInsert = [SELECT Id,
                                (SELECT Status__c, Description__c, Form_Source__c, Form_Source_URL__c, Lead_Source__c, Name, Interest_Broadband__c,
                                 Interest_Cloud_Services__c, Interest_Company_Network__c, Interest_Contact_Center__c, Interest_Expert_and_Service_Duties__c,
                                 Interest_IOT__c, Interest_Meeting_Services__c, Interest_Other__c, Interest_Support_Services__c, Interest_Switches__c,
                                 Interest_Telephony__c FROM Buy_Interests__r)
                                FROM Lead LIMIT 1
                               ];
        
        System.assertEquals(leadAfterInsert.Buy_Interests__r.size(), 0, 'There should not be any Buy Interests created for the Lead');
    }
    
    public static testmethod void no07_testNewTeliaEmployeeLeadSubmitter() {
        System.debug('@@Test no07_testNewTeliaEmployeeLeadSubmitter Starts');
        Test_DataFactory.setUpOrg();
        
        Lead lead;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            lead = Test_DataFactory.createPardotLead();
            lead.Lead_Submitter_ID__c = 'TELIAID';
            lead.Lead_Submitter_first_name__c = 'FirstName';
            lead.Lead_Submitter_Last_name__c = 'LastName';
            lead.Lead_Submitter_email__c = 'testemail@test.test';
            lead.Lead_Submitter_phone__c = '12345678';
            lead.LeadSource = LeadTriggerHandler.LEAD_SOURCE_TELIA_INTRANET;
            insert lead;
        }
        // Contact newCon = new Contact(FirstName = lead.Lead_Submitter_first_name__c, Email = lead.Lead_Submitter_email__c,
        // Phone = lead.Lead_Submitter_phone__c, Telia_Id__c = lead.Telia_Employee_Telia_Id__c);
        Lead leadAfterInsert = [SELECT Id, Telia_Employee_Telia_Id__c,
                                (SELECT Buy_Interest_Submitter__c, Buy_Interest_Submitter__r.FirstName,
                                 Buy_Interest_Submitter__r.LastName, Buy_Interest_Submitter__r.Email, Buy_Interest_Submitter__r.Phone,
                                 Buy_Interest_Submitter__r.Telia_Id__c, Buy_Interest_Submitter__r.RecordTypeId FROM Buy_Interests__r)
                                FROM Lead LIMIT 1
                               ];
        System.assertEquals(leadAfterInsert.Buy_Interests__r.size(), 1, 'There should be exactly one Buy Interest created for the Lead');
        
        Buy_Interest__c bi = leadAfterInsert.Buy_Interests__r[0];
        System.assertNotEquals(bi.Buy_Interest_Submitter__c, null, 'The Buy_Interest_Submitter__c lookup should be populated');
        
        System.assertEquals(bi.Buy_Interest_Submitter__r.RecordTypeId, SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_TELIA_INTERNAL), 'The Record Type of the new contact is incorrect');
        System.assertEquals(bi.Buy_Interest_Submitter__r.FirstName, lead.Lead_Submitter_first_name__c, 'The value for FirstName does not match between the lead and the new contact');
        System.assertEquals(bi.Buy_Interest_Submitter__r.LastName, lead.Lead_Submitter_Last_name__c, 'The value for LastName does not match between the lead and the new contact');
        System.assertEquals(bi.Buy_Interest_Submitter__r.Email, lead.Lead_Submitter_email__c, 'The value for Email does not match between the lead and the new contact');
        System.assertEquals(bi.Buy_Interest_Submitter__r.Phone, lead.Lead_Submitter_phone__c, 'The value for Phone does not match between the lead and the new contact');
        System.assertEquals(bi.Buy_Interest_Submitter__r.Telia_Id__c.toLowerCase(), lead.Lead_Submitter_ID__c.toLowerCase(), 'The value for Telia_Id__c does not match between the lead and the new contact');
    }
    
    public static testmethod void no08_testExistingTeliaEmployeeLeadSubmitter() {
        System.debug('@@Test no08_testExistingTeliaEmployeeLeadSubmitter Starts');
        Test_DataFactory.setUpOrg();
        
        Contact existingTeliaContact;
        Lead lead;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            existingTeliaContact = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'testemail@test.test', Phone = '12345678', Telia_Id__c = 'TELIAID');
            existingTeliaContact.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_TELIA_INTERNAL);
            existingTeliaContact.AccountId = UserTriggerHandler.getTeliaAccountId();
            insert existingTeliaContact;
            lead = Test_DataFactory.createPardotLead();
            lead.Lead_Submitter_ID__c = existingTeliaContact.Telia_Id__c;
            lead.Lead_Submitter_first_name__c = 'FirstName Updated';
            lead.Lead_Submitter_Last_name__c = existingTeliaContact.LastName;
            lead.Lead_Submitter_email__c = 'newtestemail@test.test';
            lead.LeadSource = LeadTriggerHandler.LEAD_SOURCE_TELIA_INTRANET;
            insert lead;
        }
        
        Lead leadAfterInsert = [SELECT Id, (SELECT Buy_Interest_Submitter__c FROM Buy_Interests__r) FROM Lead LIMIT 1];
        
        System.assertEquals(leadAfterInsert.Buy_Interests__r.size(), 1, 'There should be exactly one Buy Interest created for the Lead');
        Buy_Interest__c bi = leadAfterInsert.Buy_Interests__r[0];
        
        Contact existingTeliaContactAfterNewLead = [SELECT FirstName, LastName, Email, Phone, Telia_Id__c, RecordTypeId FROM Contact WHERE ID =: existingTeliaContact.Id];
        
        System.assertEquals(bi.Buy_Interest_Submitter__c, existingTeliaContact.Id, 'The Buy_Interest_Submitter__c lookup should be updated with the existing contact');
        
        // LastName, Telia Id and Phone should be unchanged on the contact (and also record type)
        System.assertEquals(existingTeliaContactAfterNewLead.RecordTypeId, SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_TELIA_INTERNAL), 'The Record Type of the contact is incorrect');
        System.assertEquals(existingTeliaContactAfterNewLead.LastName, existingTeliaContact.LastName, 'The value for LastName should not have been changed');
        System.assertEquals(existingTeliaContactAfterNewLead.Phone, existingTeliaContact.Phone, 'The value for Phone should not have been changed');
        System.assertEquals(existingTeliaContactAfterNewLead.Telia_Id__c, existingTeliaContact.Telia_Id__c, 'The value for Telia_Id__c should not have been changed');
        // FirstName and Email should be updated on the contact
        System.assertEquals(existingTeliaContactAfterNewLead.FirstName, lead.Lead_Submitter_first_name__c, 'The value for FirstName does not match between the lead and the new contact');
        System.assertNotEquals(existingTeliaContactAfterNewLead.FirstName, existingTeliaContact.FirstName, 'The value for FirstName should have been updated when new Lead was submitted');
        System.assertEquals(existingTeliaContactAfterNewLead.Email, lead.Lead_Submitter_email__c, 'The value for Email does not match between the lead and the new contact');
        System.assertNotEquals(existingTeliaContactAfterNewLead.Email, existingTeliaContact.Email, 'The value for Email should have been updated when new Lead was submitted');
    }
    
    public static testmethod void no09_testExistingTeliaEmployeeLeadSubmitterTestIgnoreCase() {
        System.debug('@@Test no09_testExistingTeliaEmployeeLeadSubmitterTestIgnoreCase Starts');
        Test_DataFactory.setUpOrg();
        
        Contact existingTeliaContact;
        Lead lead;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            existingTeliaContact = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'testemail@test.test', Phone = '12345678', Telia_Id__c = 'TELIAID');
            existingTeliaContact.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_TELIA_INTERNAL);
            existingTeliaContact.AccountId = UserTriggerHandler.getTeliaAccountId();
            insert existingTeliaContact;
            lead = Test_DataFactory.createPardotLead();
            // Adding a new contact where the Telia_ID already is existing, but is provided in lowercase, whereas existing contact has Telia_Id in uppercase
            lead.Lead_Submitter_ID__c = existingTeliaContact.Telia_Id__c.toLowerCase(); // Telia_ID__c = 'teliaid'
            lead.Lead_Submitter_first_name__c = 'FirstName Updated';
            lead.LeadSource = LeadTriggerHandler.LEAD_SOURCE_TELIA_INTRANET;
            insert lead;
        }
        
        Lead leadAfterInsert = [SELECT Id, (SELECT Buy_Interest_Submitter__c FROM Buy_Interests__r) FROM Lead LIMIT 1];
        
        System.assertEquals(leadAfterInsert.Buy_Interests__r.size(), 1, 'There should be exactly one Buy Interest created for the Lead');
        Buy_Interest__c bi = leadAfterInsert.Buy_Interests__r[0];
        
        Contact existingTeliaContactAfterNewLead = [SELECT FirstName, LastName, Email, Phone, Telia_Id__c, RecordTypeId FROM Contact WHERE ID =: existingTeliaContact.Id];
        
        System.assertEquals(bi.Buy_Interest_Submitter__c, existingTeliaContact.Id, 'The Buy_Interest_Submitter__c lookup should be updated with the existing contact');
        
        System.assertEquals(existingTeliaContactAfterNewLead.RecordTypeId, SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_TELIA_INTERNAL), 'The Record Type of the contact is incorrect');
        System.assertEquals(existingTeliaContactAfterNewLead.Telia_Id__c, existingTeliaContact.Telia_Id__c, 'The value for Telia_Id__c should not have been changed');
        System.assertEquals(existingTeliaContactAfterNewLead.FirstName, lead.Lead_Submitter_first_name__c, 'The value for FirstName does not match between the lead and the new contact');
        System.assertNotEquals(existingTeliaContactAfterNewLead.FirstName, existingTeliaContact.FirstName, 'The value for FirstName should have been updated when new Lead was submitted');
    }
    
    public static testmethod void no10_testExistingResellerContactLeadSubmitter() {
        System.debug('@@Test no10_testExistingResellerContactLeadSubmitter Starts');
        Test_DataFactory.setUpOrg();
        
        Contact existingResellerContact;
        Lead lead;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            Account resellerAccount = Test_DataFactory.createResellerAccount();
            insert resellerAccount;
            existingResellerContact = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'testemail@test.test', Phone = '12345678', Reseller_Tholbox_ID__c = 'RESELLERID');
            existingResellerContact.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_RESELLER);
            existingResellerContact.AccountId = resellerAccount.Id;
            insert existingResellerContact;
            lead = Test_DataFactory.createPardotLead();
            lead.Lead_Submitter_ID__c = existingResellerContact.Reseller_Tholbox_ID__c;
            lead.Lead_Submitter_first_name__c = 'FirstName Updated';
            lead.Lead_Submitter_Last_name__c = existingResellerContact.LastName;
            lead.Lead_Submitter_email__c = 'newtestemail@test.test';
            lead.LeadSource = LeadTriggerHandler.LEAD_SOURCE_RESELLER;
            insert lead;
        }
        
        Lead leadAfterInsert = [SELECT Id, (SELECT Buy_Interest_Submitter__c FROM Buy_Interests__r) FROM Lead LIMIT 1];
        
        System.assertEquals(leadAfterInsert.Buy_Interests__r.size(), 1, 'There should be exactly one Buy Interest created for the Lead');
        Buy_Interest__c bi = leadAfterInsert.Buy_Interests__r[0];
        
        Contact existingResellerContactAfterNewLead = [SELECT FirstName, LastName, Email, Phone, Reseller_Tholbox_ID__c, RecordTypeId FROM Contact WHERE ID =: existingResellerContact.Id];
        
        System.assertEquals(bi.Buy_Interest_Submitter__c, existingResellerContact.Id, 'The Buy_Interest_Submitter__c lookup should be updated with the existing contact');
        
        // LastName, Telia Id and Phone should be unchanged on the contact (and also record type)
        System.assertEquals(existingResellerContactAfterNewLead.RecordTypeId, SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_RESELLER), 'The Record Type of the contact is incorrect');
        System.assertEquals(existingResellerContactAfterNewLead.LastName, existingResellerContact.LastName, 'The value for LastName should not have been changed');
        System.assertEquals(existingResellerContactAfterNewLead.Phone, existingResellerContact.Phone, 'The value for Phone should not have been changed');
        System.assertEquals(existingResellerContactAfterNewLead.Reseller_Tholbox_ID__c, existingResellerContact.Reseller_Tholbox_ID__c, 'The value for Reseller_Tholbox_ID__c should not have been changed');
        // FirstName and Email should be updated on the contact
        System.assertEquals(existingResellerContactAfterNewLead.FirstName, lead.Lead_Submitter_first_name__c, 'The value for FirstName does not match between the lead and the new contact');
        System.assertNotEquals(existingResellerContactAfterNewLead.FirstName, existingResellerContact.FirstName, 'The value for FirstName should have been updated when new Lead was submitted');
        System.assertEquals(existingResellerContactAfterNewLead.Email, lead.Lead_Submitter_email__c, 'The value for Email does not match between the lead and the new contact');
        System.assertNotEquals(existingResellerContactAfterNewLead.Email, existingResellerContact.Email, 'The value for Email should have been updated when new Lead was submitted');
    }
    
    public static testmethod void no11_testExistingTeliaUserLeadSubmitter() {
        System.debug('@@Test no11_testExistingTeliaUserLeadSubmitter Starts');
        Test_DataFactory.setUpOrg();
        UserTriggerHandler.testCreateContacts = true;
        Lead lead;
        User smeUser;
        System.runAs(new User(Id = Userinfo.getUserId())) { // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            Test.startTest();
            Telia_SF_User_Contact_Roles__c cs = new Telia_SF_User_Contact_Roles__c();
            cs.Name = 'SME Sales Manager';
            insert cs;
            smeUser = Test_DataFactory.createSMEUser();
            insert smeUser;
            Test.stopTest();
            
            lead = Test_DataFactory.createPardotLead();
            lead.Lead_Submitter_ID__c = smeUser.Telia_Id__c;
            lead.Lead_Submitter_first_name__c = 'FirstName Updated';
            lead.Lead_Submitter_Last_name__c = smeUser.LastName;
            lead.Lead_Submitter_email__c = 'newtestemail@test.test';
            lead.LeadSource = LeadTriggerHandler.LEAD_SOURCE_TELIA_INTRANET;
            insert lead;
        }
        
        Contact existingTeliaUserContact = [SELECT FirstName, LastName, Email, Phone, Telia_Id__c, RecordTypeId FROM Contact WHERE Is_Telia_User_Contact__c = true LIMIT 1];
        System.assertNotEquals(existingTeliaUserContact, null, 'A Telia Contact should have been created for a Telia User');
        
        Lead leadAfterInsert = [SELECT Id, (SELECT Buy_Interest_Submitter__c FROM Buy_Interests__r) FROM Lead LIMIT 1];
        
        System.assertEquals(leadAfterInsert.Buy_Interests__r.size(), 1, 'There should be exactly one Buy Interest created for the Lead');
        Buy_Interest__c bi = leadAfterInsert.Buy_Interests__r[0];
        
        Contact existingTeliaContactAfterNewLead = [SELECT FirstName, LastName, Email, Phone, Telia_Id__c, RecordTypeId FROM Contact WHERE Is_Telia_User_Contact__c = true LIMIT 1];
        
        System.assertEquals(bi.Buy_Interest_Submitter__c, existingTeliaUserContact.Id, 'The Buy_Interest_Submitter__c lookup should be updated with the existing contact');
        
        // LastName, Telia Id and Phone should be unchanged on the contact (and also record type)
        System.assertEquals(existingTeliaContactAfterNewLead.RecordTypeId, SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_TELIA_USER), 'The Record Type of the contact is incorrect');
        System.assertEquals(existingTeliaContactAfterNewLead.LastName, existingTeliaUserContact.LastName, 'The value for LastName should not have been changed');
        System.assertEquals(existingTeliaContactAfterNewLead.Phone, existingTeliaUserContact.Phone, 'The value for Phone should not have been changed');
        System.assertEquals(existingTeliaContactAfterNewLead.Telia_Id__c, existingTeliaUserContact.Telia_Id__c, 'The value for Telia_Id__c should not have been changed');
        // FirstName and Email: These fields differ from the Contact record and the submitted lead, but since the lead is created from a SF User we should not update as SF is the master.
        System.assertNotEquals(existingTeliaContactAfterNewLead.FirstName, lead.Lead_Submitter_first_name__c, 'The value for FirstName should not be updated from Lead since this is a Telia SF User contact');
        System.assertEquals(existingTeliaContactAfterNewLead.FirstName, existingTeliaUserContact.FirstName, 'The value for FirstName should not have been updated when new Lead was submitted');
        System.assertNotEquals(existingTeliaContactAfterNewLead.Email, lead.Lead_Submitter_email__c, 'The value for Email should not be updated from Lead since this is a Telia SF User contact');
        System.assertEquals(existingTeliaContactAfterNewLead.Email, existingTeliaUserContact.Email, 'The value for Email should not have been updated when new Lead was submitted');
        
    }
    
    public static testmethod void no12_testSetQueueOwnerOnBuyInterestOnLeadUpdate() {
        System.debug('@@Test no12_testSetQueueOwnerOnBuyInterestOnLeadUpdate Starts');
        Test_DataFactory.setUpOrg();
        
        Lead lead;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            lead = Test_DataFactory.createPardotLead();
            lead.Product_Area__c = LeadTriggerHandler.LEAD_PRODAREA_BB;
            insert lead;
        }
        
        Lead leadAfterInsert = [SELECT Id,
                                (SELECT Id, Lead_Queue__c FROM Buy_Interests__r)
                                FROM Lead LIMIT 1
                               ];
        
        System.assertEquals(leadAfterInsert.Buy_Interests__r.size(), 1, 'There should be exactly one Buy Interest created for the Lead');
        Buy_Interest__c biAfterInsert = leadAfterInsert.Buy_Interests__r[0];
        System.assertEquals(biAfterInsert.Lead_Queue__c, null, 'the Lead Queue should not have been set on the Buy interest');
        
        System.runAs(new User(Id = Userinfo.getUserId())) {
            Group queue = Test_DataFactory.getTestQueue();
            lead.OwnerId = queue.Id;
            update lead;
        }
        
        Lead leadAfterUpdate = [SELECT Id, OwnerId, Owner.Name,
                                (SELECT Id, Lead_Queue__c FROM Buy_Interests__r)
                                FROM Lead LIMIT 1
                               ];
        
        System.assertEquals(leadAfterUpdate.Buy_Interests__r.size(), 1, 'There should be exactly one Buy Interest created for the Lead');
        Buy_Interest__c biAfterUpdate = leadAfterUpdate.Buy_Interests__r[0];
        System.assertEquals(biAfterUpdate.Lead_Queue__c, leadAfterUpdate.Owner.Name, 'The Lead Queue should have been set on the Buy interest');
    }
    
    public static testmethod void no13_testUpdateBuyInterestStatus() {
        System.debug('@@Test no12_testSetQueueOwnerOnBuyInterestOnLeadUpdate Starts');
        Test_DataFactory.setUpOrg();
        
        Lead lead;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            lead = Test_DataFactory.createPardotLead();
            lead.Product_Area__c = LeadTriggerHandler.LEAD_PRODAREA_BB;
            insert lead;
        }
        
        Lead leadAfterInsert = [SELECT Id, Status, Lead_Close_Reason__c,
                                (SELECT Id, Status__c, Lead_Close_Reason__c FROM Buy_Interests__r)
                                FROM Lead LIMIT 1
                               ];
        
        System.assertEquals(leadAfterInsert.Buy_Interests__r.size(), 1, 'There should be exactly one Buy Interest created for the Lead');
        Buy_Interest__c biAfterInsert = leadAfterInsert.Buy_Interests__r[0];
        System.assertEquals(biAfterInsert.Status__c, 'Nytt', 'The status on Buy Interest should be Nytt');
        
        System.runAs(new User(Id = Userinfo.getUserId())) {
            lead.Status = LeadTriggerHandler.LEAD_STATUS_DISMISSED;
            lead.Lead_Close_Reason__c = LeadTriggerHandler.LEAD_CLOSE_REASON_DUPLICATE;
            update lead;
        }
        
        Lead leadAfterUpdate = [SELECT Id, Status, Lead_Close_Reason__c,
                                (SELECT Id, Status__c, Lead_Close_Reason__c FROM Buy_Interests__r)
                                FROM Lead LIMIT 1
                               ];
        
        System.assertEquals(leadAfterUpdate.Buy_Interests__r.size(), 1, 'There should be exactly one Buy Interest created for the Lead');
        Buy_Interest__c biAfterUpdate = leadAfterUpdate.Buy_Interests__r[0];
        System.assertEquals(biAfterUpdate.Status__c, LeadTriggerHandler.LEAD_STATUS_DISMISSED, 'The status on Buy Interest should be dismissed pickval');
        System.assertEquals(biAfterUpdate.Status__c, leadAfterUpdate.Status, 'The status on Buy Interest should be same as lead');
        System.assertEquals(biAfterUpdate.Lead_Close_Reason__c, leadAfterUpdate.Lead_Close_Reason__c, 'The status on Buy Interest should be same as lead');
        
        System.runAs(new User(Id = Userinfo.getUserId())) {
            lead.Status = LeadTriggerHandler.LEAD_STATUS_QUALIFY;
            lead.Lead_Close_Reason__c = null;
            update lead;
        }
        
        Lead leadAfterUpdate2 = [SELECT Id, Status, Lead_Close_Reason__c,
                                 (SELECT Id, Status__c, Lead_Close_Reason__c FROM Buy_Interests__r)
                                 FROM Lead LIMIT 1
                                ];
        
        System.assertEquals(leadAfterUpdate2.Buy_Interests__r.size(), 1, 'There should be exactly one Buy Interest created for the Lead');
        Buy_Interest__c biAfterUpdate2 = leadAfterUpdate2.Buy_Interests__r[0];
        System.assertEquals(biAfterUpdate2.Status__c, LeadTriggerHandler.LEAD_STATUS_DISMISSED, 'The status on Buy Interest should be dismissed pickval');
        System.assertNotEquals(biAfterUpdate2.Status__c, leadAfterUpdate2.Status, 'The status on Buy Interest should not be the same as lead');
        System.assertNotEquals(biAfterUpdate2.Lead_Close_Reason__c, leadAfterUpdate2.Lead_Close_Reason__c, 'The status on Buy Interest should be unchanged and not the same as one Lead');
    }
    
    public static testmethod void no14_testPopulateAccMachingOrgnr() {
        Test_DataFactory.setUpOrg();
        System.runAs(Test_DataFactory.getByPassUser()) { // V.A  Bypassing User
            Account acc;
            acc = Test_DataFactory.createOneAccount();
            acc.Org_Nr__c = '0123456789';
            acc.Name = 'xyz';
            insert acc;
            
            Lead lead;
            lead = Test_DataFactory.createLead();
            lead.Org_nr__c = '0123456789';
            lead.Company = 'abc';
            insert lead;
            
            Lead newLead = [SELECT Id, Account__c, Org_nr__c FROM Lead LIMIT 1];
            
            System.assertEquals(newLead.Account__c, acc.id);
        }
    }
    
    public static testmethod void no15_testPopulateAccMachingCompany() {
        Test_DataFactory.setUpOrg();
        System.runAs(Test_DataFactory.getByPassUser()) { // V.A  Bypassing User
            Account acc;
            acc = Test_DataFactory.createOneAccount();
            acc.Org_Nr__c = '0123456789';
            acc.Name = 'xyz';
            insert acc;
            
            Lead lead;
            lead = Test_DataFactory.createLead();
            lead.Org_nr__c = '9999999999';
            lead.Company = 'xyz';
            insert lead;
            
            Lead newLead = [SELECT Id, Account__c, Company, Org_nr__c FROM Lead LIMIT 1];
            
            System.assertEquals(newLead.Account__c, acc.id);
        }
    }
    public static testmethod void no18_testPopulateAccNoMatchFound() {
        Test_DataFactory.setUpOrg();
        System.runAs(Test_DataFactory.getByPassUser()) { // V.A  Bypassing User
            Account acc;
            acc = Test_DataFactory.createOneAccount();
            acc.Org_Nr__c = '0123456789';
            acc.Name = 'xyz';
            insert acc;
            
            Lead lead;
            lead = Test_DataFactory.createLead();
            lead.Org_nr__c = '9999999999';
            lead.Company = 'abc';
            insert lead;
            
            Lead newLead = [SELECT Id, Account__c, Company, Org_nr__c FROM Lead LIMIT 1];
            
            System.assertEquals(newLead.Account__c, null);
        }
    }
    
    public static testmethod void no19_testSetBuyInterestOwnerOnLeadUpdate() {
        Test_DataFactory.setUpOrg();
        
        Lead lead;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            lead = Test_DataFactory.createPardotLead();
            lead.Product_Area__c = LeadTriggerHandler.LEAD_PRODAREA_BB;
            insert lead;
        }
        
        Lead leadAfterInsert = [SELECT Id, OwnerId,
                                (SELECT Id, OwnerId FROM Buy_Interests__r)
                                FROM Lead LIMIT 1
                               ];
        
        System.assertEquals(leadAfterInsert.Buy_Interests__r.size(), 1, 'There should be exactly one Buy Interest created for the Lead');
        Buy_Interest__c biAfterInsert = leadAfterInsert.Buy_Interests__r[0];
        System.assertEquals(biAfterInsert.OwnerId, leadAfterInsert.OwnerId, 'The Lead Owner and the Buy interest Owner should be the same');
        
        User prUser;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            prUser = Test_DataFactory.createPRUser();
            insert prUser;
            lead.OwnerId = prUser.Id;
            update lead;
        }
        
        Lead leadAfterUpdate = [SELECT Id, OwnerId,
                                (SELECT Id, OwnerId FROM Buy_Interests__r)
                                FROM Lead LIMIT 1
                               ];
        
        System.assertEquals(leadAfterUpdate.Buy_Interests__r.size(), 1, 'There should be exactly one Buy Interest created for the Lead');
        Buy_Interest__c biAfterUpdate = leadAfterUpdate.Buy_Interests__r[0];
        System.assertNotEquals(biAfterUpdate.OwnerId, biAfterInsert.OwnerId, 'The new Buy interest Owner should not be the same as before');
        System.assertEquals(biAfterUpdate.OwnerId, leadAfterUpdate.OwnerId, 'The Lead Owner and the Buy interest Owner should still be the same');
    }
    
    public static testmethod void no20_testSetBuyInterestQueueOwnerOnLeadUpdate() {
        Test_DataFactory.setUpOrg();
        
        Lead lead;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            lead = Test_DataFactory.createPardotLead();
            lead.Product_Area__c = LeadTriggerHandler.LEAD_PRODAREA_BB;
            insert lead;
        }
        
        Lead leadAfterInsert = [SELECT Id, OwnerId,
                                (SELECT Id, OwnerId FROM Buy_Interests__r)
                                FROM Lead LIMIT 1
                               ];
        
        System.assertEquals(leadAfterInsert.Buy_Interests__r.size(), 1, 'There should be exactly one Buy Interest created for the Lead');
        Buy_Interest__c biAfterInsert = leadAfterInsert.Buy_Interests__r[0];
        System.assertEquals(biAfterInsert.OwnerId, leadAfterInsert.OwnerId, 'The Lead Owner and the Buy interest Owner should be the same');
        
        Group queue;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            queue = Test_DataFactory.getTestQueue();
            lead.OwnerId = queue.Id;
            update lead;
        }
        
        Lead leadAfterUpdate = [SELECT Id, OwnerId,
                                (SELECT Id, OwnerId FROM Buy_Interests__r)
                                FROM Lead LIMIT 1
                               ];
        
        System.assertEquals(leadAfterUpdate.Buy_Interests__r.size(), 1, 'There should be exactly one Buy Interest created for the Lead');
        Buy_Interest__c biAfterUpdate = leadAfterUpdate.Buy_Interests__r[0];
        System.assertNotEquals(biAfterUpdate.OwnerId, biAfterInsert.OwnerId, 'The new Buy interest Owner should not be the same as before');
        System.assertEquals(biAfterUpdate.OwnerId, queue.Id, 'The Buy interest Owner should be the queue');
        System.assertEquals(biAfterUpdate.OwnerId, leadAfterUpdate.OwnerId, 'The Lead Owner and the Buy interest Owner should still be the same');
    }
    
    /*
public static testmethod void no21_testTholboxSubmitterValidation(){
System.debug('@@Test no21_testTholboxSubmitterValidation Starts');
Test_DataFactory.setUpOrg();

Lead lead;
System.runAs(new User(Id = Userinfo.getUserId())){
lead = Test_DataFactory.createLead();
lead.RecordTypeId = SEUtility.getRecordTypeId('Standard_Telia_Lead');
insert lead;

Buy_Interest__c bi = new Buy_Interest__c();
bi.Lead_Source__c = LeadTriggerHandler.LEAD_SOURCE_RESELLER;
bi.Lead__c = lead.Id;

insert bi;

lead.Status = LeadTriggerHandler.LEAD_STATUS_PREQUALIFY;

Contact con = Test_DataFactory.createOneContact();
con.RecordTypeId = SEUtility.getRecordTypeId('Reseller_Contact');
insert con;

try{
update lead;
System.assert(False, 'Validation error should fire because the Buy Interest is from Reseller and has no Submitter set');
}catch(DmlException ex){
System.assert(True, 'Validation error should fire because the Buy Interest is from Reseller and has no Submitter set');
}

bi.Buy_Interest_Submitter__c = con.Id;
update bi;

Database.SaveResult ur1 = Database.update(lead);
system.assertEquals(ur1.isSuccess(), true);
}
}
*/
    
    public static testmethod void no22_testSetResellerAccountNameMatchFound() {
        Test_DataFactory.setUpOrg();
        
        Account acc = Test_DataFactory.createResellerAccount();
        acc.Telia_Reseller_Id__c = '000001';
        acc.Name = 'Test Account';
        insert acc;
        
        Lead lead = Test_DataFactory.createLead();
        lead.Lead_Submitter_No__c = acc.Telia_Reseller_Id__c;
        lead.LeadSource = LeadTriggerHandler.LEAD_SOURCE_RESELLER;
        insert lead;
        
        Lead newLead = [SELECT Id, Reseller_Account_Name__c FROM Lead LIMIT 1];
        
        System.assertEquals(newLead.Reseller_Account_Name__c, acc.Name, 'Account Reseller name is incorrect');
    }
    
    public static testmethod void no23_testSetResellerAccountNameNoMatchFound() {
        Test_DataFactory.setUpOrg();
        
        Account acc = Test_DataFactory.createResellerAccount();
        acc.Telia_Reseller_Id__c = '000001';
        acc.Name = 'Test Account';
        insert acc;
        
        Lead lead = Test_DataFactory.createLead();
        lead.Lead_Submitter_No__c = '000002';
        lead.LeadSource = LeadTriggerHandler.LEAD_SOURCE_RESELLER;
        insert lead;
        
        Lead newLead = [SELECT Id, Reseller_Account_Name__c FROM Lead LIMIT 1];
        
        System.assertEquals(newLead.Reseller_Account_Name__c, null, 'Account Reseller name should be null');
    }
    
    public static testmethod void no24_testSetResellerAccountNameMultipleLeads() {
        Test_DataFactory.setUpOrg();
        List < Account > accList = new List < Account > ();
        Map < String, String > accMap = new Map < String, String > ();
        
        for (Integer i = 1; i < 10; i++) {
            Account acc = Test_DataFactory.createResellerAccount();
            acc.Telia_Reseller_Id__c = '00000' + String.valueOf(i);
            acc.Name = 'Test Account ' + String.valueOf(i);
            accList.add(acc);
            accMap.put(acc.Telia_Reseller_Id__c, acc.Name);
        }
        insert accList;
        
        List < Lead > leadList = new List < Lead > ();
        
        for (Account acc: accList) {
            Lead lead = Test_DataFactory.createLead();
            lead.Lead_Submitter_No__c = acc.Telia_Reseller_Id__c;
            lead.LeadSource = LeadTriggerHandler.LEAD_SOURCE_RESELLER;
            leadList.add(lead);
        }
        insert leadList;
        
        List < Lead > newLeads = [SELECT Id, Reseller_Account_Name__c, Lead_Submitter_No__c FROM Lead LIMIT 10];
        
        for (Lead newLead: newLeads) {
            String accResellerName = accMap.get(newLead.Lead_Submitter_No__c);
            System.assertNotEquals(accResellerName, null, 'An account should have been found for the Lead_Submitter_No__c');
            System.assertEquals(newLead.Reseller_Account_Name__c, accResellerName, 'Account Reseller name is incorrect');
        }
    }
    
    public static testmethod void no25_testSetContactResellerId() {
        Test_DataFactory.setUpOrg();
        
        Lead lead;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            lead = Test_DataFactory.createLead();
            lead.Lead_Submitter_ID__c = 'RESELLERID';
            lead.LeadSource = LeadTriggerHandler.LEAD_SOURCE_LEADAGENT;
            insert lead;
        }
        
        Lead leadAfterInsert = [SELECT Id, Lead_Submitter_ID__c, Telia_Employee_Telia_Id__c, Reseller_Tholbox_ID__c FROM Lead LIMIT 1];
        
        System.assertEquals(leadAfterInsert.Lead_Submitter_ID__c, 'RESELLERID', 'Incorrect Lead_Submitter_ID__c');
        System.assertEquals(leadAfterInsert.Telia_Employee_Telia_Id__c, null, 'Telia_Employee_Telia_Id__c should not be set');
        System.assertEquals(leadAfterInsert.Reseller_Tholbox_ID__c, 'RESELLERID', 'Incorrect Reseller_Tholbox_ID__c');
    }
    
    public static testmethod void no26_testExistingResellerContactLeadSubmitterLeadAgent() {
        Test_DataFactory.setUpOrg();
        
        Contact existingResellerContact;
        Lead lead;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            Account resellerAccount = Test_DataFactory.createResellerAccount();
            insert resellerAccount;
            existingResellerContact = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'testemail@test.test', Phone = '12345678', Reseller_Tholbox_ID__c = 'RESELLERID');
            existingResellerContact.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_RESELLER);
            existingResellerContact.AccountId = resellerAccount.Id;
            insert existingResellerContact;
            lead = Test_DataFactory.createPardotLead();
            lead.Lead_Submitter_ID__c = existingResellerContact.Reseller_Tholbox_ID__c;
            lead.Lead_Submitter_first_name__c = 'FirstName Updated';
            lead.Lead_Submitter_Last_name__c = existingResellerContact.LastName;
            lead.Lead_Submitter_email__c = 'newtestemail@test.test';
            lead.LeadSource = LeadTriggerHandler.LEAD_SOURCE_LEADAGENT;
            insert lead;
        }
        
        Lead leadAfterInsert = [SELECT Id, (SELECT Buy_Interest_Submitter__c FROM Buy_Interests__r) FROM Lead LIMIT 1];
        
        System.assertEquals(leadAfterInsert.Buy_Interests__r.size(), 1, 'There should be exactly one Buy Interest created for the Lead');
        Buy_Interest__c bi = leadAfterInsert.Buy_Interests__r[0];
        
        Contact existingResellerContactAfterNewLead = [SELECT FirstName, LastName, Email, Phone, Reseller_Tholbox_ID__c, RecordTypeId FROM Contact WHERE ID =: existingResellerContact.Id];
        
        System.assertEquals(bi.Buy_Interest_Submitter__c, existingResellerContact.Id, 'The Buy_Interest_Submitter__c lookup should be updated with the existing contact');
        
        // LastName, Telia Id and Phone should be unchanged on the contact (and also record type)
        System.assertEquals(existingResellerContactAfterNewLead.RecordTypeId, SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_RESELLER), 'The Record Type of the contact is incorrect');
        System.assertEquals(existingResellerContactAfterNewLead.LastName, existingResellerContact.LastName, 'The value for LastName should not have been changed');
        System.assertEquals(existingResellerContactAfterNewLead.Phone, existingResellerContact.Phone, 'The value for Phone should not have been changed');
        System.assertEquals(existingResellerContactAfterNewLead.Reseller_Tholbox_ID__c, existingResellerContact.Reseller_Tholbox_ID__c, 'The value for Reseller_Tholbox_ID__c should not have been changed');
        // FirstName and Email should be updated on the contact
        System.assertEquals(existingResellerContactAfterNewLead.FirstName, lead.Lead_Submitter_first_name__c, 'The value for FirstName does not match between the lead and the new contact');
        System.assertNotEquals(existingResellerContactAfterNewLead.FirstName, existingResellerContact.FirstName, 'The value for FirstName should have been updated when new Lead was submitted');
        System.assertEquals(existingResellerContactAfterNewLead.Email, lead.Lead_Submitter_email__c, 'The value for Email does not match between the lead and the new contact');
        System.assertNotEquals(existingResellerContactAfterNewLead.Email, existingResellerContact.Email, 'The value for Email should have been updated when new Lead was submitted');
    }
    public testMethod static void no29_testConvertToCygateLead() {
        Test_DataFactory.setUpOrg();
        Test.starttest();
        Lead cygatelead = new lead();
        System.runAs(new User(Id = Userinfo.getUserId())) {
            cygatelead = Test_DataFactory.createCygateLead();
            cygatelead.Description_Pardot__c = 'TEST DESCRIPTION INSERT';
            insert cygatelead;
        }
        Test.Stoptest();
        Lead leadAfterInsert = [SELECT Id, Recordtypeid from lead where id =: cygatelead.id];
        system.assertequals(SEUtility.getRecordTypeId(SEUtility.LEAD_RECTYPE_CYGATE), leadAfterInsert.Recordtypeid);
    }
    public testMethod static void no30_testupdateLeadStatusOnCygateSync() {
        Test_DataFactory.setUpOrg();
        Test.starttest();
        Lead cygatelead = new lead();
        System.runAs(new User(Id = Userinfo.getUserId())) {
            cygatelead = Test_DataFactory.createCygateLead();
            cygatelead.Description_Pardot__c = 'TEST DESCRIPTION INSERT';
            insert cygatelead;
        }
        Lead leadAfterInsert = [SELECT Id, status, Cygate_Sync__c from lead where id =: cygatelead.id];
        leadAfterInsert.status = LeadTriggerHandler.LEAD_STATUS_DISMISSED;
        leadAfterInsert.Cygate_Sync__c = 2;
        update leadAfterInsert;
        Test.Stoptest();
        Lead leadAfterUpdate = [SELECT Id, status, Lead_Close_Reason__c from lead where id =: cygatelead.id];
        system.assertequals(LeadTriggerHandler.LEAD_STATUS_NEW, leadAfterUpdate.status);
        system.assertequals(null, leadAfterUpdate.Lead_Close_Reason__c);
    }
    public testMethod static void no31_testcreateBuyInterestOnCygateSync() {
        Test_DataFactory.setUpOrg();
        Test.starttest();
        Lead cygatelead = new lead();
        System.runAs(new User(Id = Userinfo.getUserId())) {
            cygatelead = Test_DataFactory.createCygateLead();
            cygatelead.Description_Pardot__c = 'TEST DESCRIPTION INSERT';
            insert cygatelead;
        }
        Test.Stoptest();
        Lead leadAfterInsert = [SELECT Id,
                                (SELECT Status__c, Description__c, Form_Source__c, Form_Source_URL__c, Lead_Source__c, Name, Cloud__c,
                                 Security__c, Server_Storage__c, Citynet__c, Network__c, DMD__c, UC__c FROM Buy_Interests__r)
                                FROM Lead LIMIT 1
                               ];
        
        System.assertEquals(leadAfterInsert.Buy_Interests__r.size(), 1, 'There should be exactly one Buy Interest created for the Lead');
        
        Buy_Interest__c bi = leadAfterInsert.Buy_Interests__r[0];
        System.assertEquals(bi.Status__c, 'Nytt', 'Incorrect Buy interest value for field Status__c');
        System.assertEquals(bi.Description__c, 'TEST DESCRIPTION INSERT', 'Incorrect Buy interest value for field Description__c');
        System.assertEquals(bi.Form_Source__c, cygatelead.Form_Source__c, 'Incorrect Buy interest value for field Form_Source__c');
        System.assertEquals(bi.Form_Source_URL__c, cygatelead.Form_Source_URL__c, 'Incorrect Buy interest value for field Form_Source_URL__c');
        System.assertEquals(bi.Lead_Source__c, cygatelead.LeadSource, 'Incorrect Buy interest value for field Lead_Source__c');
        System.assertEquals(bi.Name, cygatelead.Product_Area__c, 'Incorrect Buy interest value for field Name');
        System.assertEquals(bi.Cloud__c, false, 'Incorrect Buy interest value for field Cloud__c');
        System.assertEquals(bi.Security__c, false, 'Incorrect Buy interest value for field Security__c');
        System.assertEquals(bi.Server_Storage__c, false, 'Incorrect Buy interest value for field Server_Storage__c');
        System.assertEquals(bi.Citynet__c, false, 'Incorrect Buy interest value for field Citynet__c');
        System.assertEquals(bi.Network__c, false, 'Incorrect Buy interest value for field Network__c');
        System.assertEquals(bi.DMD__c, false, 'Incorrect Buy interest value for field DMD__c');
        System.assertEquals(bi.UC__c, false, 'Incorrect Buy interest value for field UC__c');
    }
    
    public testMethod static void no32_testupdateBuyInterestsOnLeadChangeCygate() {
        try {
            Test_DataFactory.setUpOrg();
            Test.starttest();
            Lead cygatelead = new lead();
            System.runAs(new User(Id = Userinfo.getUserId())) {
                cygatelead = Test_DataFactory.createCygateLead();
                cygatelead.Description_Pardot__c = 'TEST DESCRIPTION INSERT';
                cygatelead.OwnerId = Userinfo.getUserId();
                insert cygatelead;
            }
            Lead leadAfterInsert = [SELECT Id, status, Cygate_Sync__c from lead where id =: cygatelead.id];
            leadAfterInsert.status = LeadTriggerHandler.LEAD_STATUS_CONVERTED;
            leadAfterInsert.Converts_to_opportunity_type_Cygate__c = 'Cygate affärsmöjlighet';
            leadAfterInsert.Cygate_Sync__c = 2;
            system.runas(Test_DataFactory.getByPassUser()) { //
                Database.LeadConvert[] leadsToConvert = new Database.LeadConvert[0];
                Database.LeadConvert converter = new Database.LeadConvert();
                converter.setLeadId(leadAfterInsert.id); //converter.setLeadId(l.id);                System.debug(1);
                account account = new account(name = 'test');
                insert account;
                converter.setAccountId(account.id);
                contact contact = new contact(firstname = 'test', lastname = 'test', accountid = account.id);
                insert contact;
                converter.setContactId(contact.id); // converter.setConvertedStatus('Closed - Converted');
                converter.setDoNotCreateOpportunity(true);
                converter.setConvertedStatus('Konverterat');
                leadsToConvert.add(converter);
                Database.ConvertLead(leadsToConvert, true);
            }
            
            Test.Stoptest();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }
    
    public testMethod static void no33_testconvertToCygateLead() {
        Test_DataFactory.setUpOrg();
        Test.starttest();
        Lead cygatelead = new lead();
        System.runAs(new User(Id = Userinfo.getUserId())) {
            cygatelead = Test_DataFactory.createCygateLead();
            cygatelead.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.LEAD_RECTYPE_TELIA);
            cygatelead.Description_Pardot__c = 'TEST DESCRIPTION INSERT';
            cygatelead.OwnerId = Userinfo.getUserId();
            insert cygatelead;
        }
    }
    public testMethod static void no34_testupdateBuyInterestsOnLeadChangeCygate() {
        Test_DataFactory.setUpOrg();
        Test.starttest();
        Lead cygatelead = new lead();
        System.runAs(new User(Id = Userinfo.getUserId())) {
            cygatelead = Test_DataFactory.createCygateLead();
            cygatelead.Description_Pardot__c = 'TEST DESCRIPTION INSERT';
            cygatelead.OwnerId = Userinfo.getUserId();
            insert cygatelead;
        }
        Lead leadAfterInsert = [SELECT Id, status, Cygate_Sync__c from lead where id =: cygatelead.id];
        leadAfterInsert.status = LeadTriggerHandler.LEAD_STATUS_CONVERTED;
        leadAfterInsert.Cygate_Sync__c = 2;
        leadAfterInsert.OwnerId = Test_DataFactory.getByPassUser().id;
        if (leadAfterInsert.isconverted == true) {
            update leadAfterInsert;
        }
        Test.stoptest();
    }
    
    public static testmethod void no35_testSetCygateManager() {
        System.debug('@@Test no35_testSetCygateManager Starts');
        Test_DataFactory.setUpOrg();
        
        Lead lead1;
        Lead lead2;
        User cygateUser;
        
        Group csQueue = new Group(Type = 'Queue', Name = 'Leadcentralen');
        insert csQueue;
        
        General_Lead_Settings__c gls = new General_Lead_Settings__c(Name = 'General Settings', Retur_LC_OwnerId__c = csQueue.Id);
        insert gls;
        
        //System.runAs(new User(Id = Userinfo.getUserId())){
        System.runAs(Test_DataFactory.getByPassUser()) { //P.P
            cygateUser = Test_DataFactory.createCygateUser();
            insert cygateUser;
            
            Account cygateManagerAcc = new Account(Name = 'Cygate Manager Acc', Cygate_Account_Manager__c = cygateUser.Id);
            insert cygateManagerAcc;
            
            QueueSobject mappingObject = new QueueSobject(QueueId = csQueue.Id, SobjectType = 'Lead');
            insert mappingObject;
            Id queueId = [SELECT Id FROM Group WHERE  Type = 'Queue' AND NAME = 'Cygate Auto Rules'].Id;
            lead1 = new Lead(LastName = 'Lead 1', Status = 'Nytt', Company = 'Cygate Manager Acc', LeadSource = 'Externt Event', RecordTypeId = SEUtility.getRecordTypeId('Cygate_Lead'), Account__c = cygateManagerAcc.Id,OwnerId = queueId);
            insert lead1;
            lead2 = new Lead(LastName = 'Lead 2', Status = 'Nytt', Company = 'Dont Have Cygate Acc', LeadSource = 'Externt Event', RecordTypeId = SEUtility.getRecordTypeId('Cygate_Lead'), OwnerId = queueId);
            insert lead2;
        }
        
        Lead lead1After = [SELECT OwnerId, Status FROM Lead WHERE Id =: lead1.Id LIMIT 1];
        Lead lead2After = [SELECT OwnerId, Status FROM Lead WHERE Id =: lead2.Id LIMIT 1];
        
        //System.assertEquals(lead1After.OwnerId, cygateUser.Id, 'Owner should be set to Cygate Account Manager, since it has a Account with Cygate Manager');
        System.assertNotEquals(lead2After.OwnerId, cygateUser.Id, 'Owner should not be set to Cygate Account Manager, since it dont have a Account');
        System.assertEquals(lead2After.OwnerId, csQueue.Id, 'Owner should be assigned to Cygate Sales Queue');
        
        //following commentted by P.P for error correction on Prod
        /*
System.assertEquals(lead1After.Status, LeadTriggerHandler.LEAD_STATUS_QUALIFY);
System.assertEquals(lead2After.Status, LeadTriggerHandler.LEAD_STATUS_ROUTE);
*/
        
    }
    public testMethod static void no37_testaddCampaignMemberLead() {
        Test_DataFactory.setUpOrg();
        Test.starttest();
        Lead newLead1 = new lead();
        Lead newLead2 = new lead();
        System.runAs(new User(Id = Userinfo.getUserId())) {
            newLead1 = Test_DataFactory.createLead();
            newLead1.OwnerId = Userinfo.getUserId();
            newLead1.recordtypeId = SEUtility.getRecordTypeId(SEUtility.LEAD_RECTYPE_TELIA);
            newLead1.LeadSource = LeadTriggerHandler.LEAD_SOURCE_SALESREP;
            insert newLead1;
        }
        Lead leadAfterupdate = [SELECT Id, Pardot_bearbetning_beh_vs__c from lead where id =: newLead1.id];
        leadAfterupdate.Pardot_bearbetning_beh_vs__c = True;
        update leadAfterupdate;
        
        System.runAs(new User(Id = Userinfo.getUserId())) {
            
            newLead2.Firstname = 'test';
            newLead2.LastName = 'Test Lead';
            newLead2.Company = 'Test Company';
            newLead2.Pardot_bearbetning_beh_vs__c = true;
            newLead2.OwnerId = Userinfo.getUserId();
            newLead2.recordtypeId = SEUtility.getRecordTypeId(SEUtility.LEAD_RECTYPE_TELIA);
            newLead2.LeadSource = LeadTriggerHandler.LEAD_SOURCE_SALESREP;
            insert newLead2;
        }
        
        Lead leadToDelete = [SELECT Id, Pardot_bearbetning_beh_vs__c from lead where id =: newLead2.id];
        leadToDelete.Pardot_bearbetning_beh_vs__c = false;
        update leadToDelete;
        
        Test.stoptest();
    }
    
    public testMethod static void createTaskInBuyIntUnitTest() {
        Test.starttest();
        Lead newLead = new lead();
        System.runAs(new User(Id = Userinfo.getUserId())) {  
            newLead.Firstname = 'test first';
            newLead.LastName = 'Test Lead';
            newLead.Company = 'Test Company';
            newLead.Pardot_bearbetning_beh_vs__c = true;
            newLead.OwnerId = Userinfo.getUserId();
            newLead.recordtypeId = SEUtility.getRecordTypeId(SEUtility.LEAD_RECTYPE_TELIA); 
            newLead.Status ='Nytt';
            insert newLead;
            Buy_Interest__c objBI = new Buy_Interest__c();
            objBI.Lead__c= newLead.id;
            objBI.name= 'Test BI';
            objBI.Status__c ='Nytt';
            objBI.Lead_Source__c= 'Cygate Event'; 
            insert objBI;
            
            newLead.Lead_Close_Reason__c ='Fakturafråga';
            newLead.Status ='Returnerad';           
            update newLead;
            Lead ledClsReason =[select id, firstname, lastname ,Lead_Close_Reason__c from lead where id =:newLead.id]; 
            Buy_Interest__c BIntrest =[select id,lead__r.Status, name, Lead__c,Status__c,lead__r.Lead_Close_Reason__c, Lead_Source__c, lead__r.Other_reason__c from Buy_Interest__c where Lead__c =: newLead.id];
            Task objTsk=[select id , Type, Subject,Status, Description from Task where whatid=:BIntrest.id];
            string strTaskDesc=  'lead status:' + BIntrest.lead__r.Status+ '\n Lead Close Reason: '+BIntrest.lead__r.Lead_Close_Reason__c+'\n Other Reason: '+BIntrest.lead__r.Other_reason__c;
            System.assertEquals(ledClsReason.Lead_Close_Reason__c,'Fakturafråga','Lead closure reason should be same Provided by Return LC');
            System.assertEquals(objTsk.Type, SEConstants.TASK_TYPE_TELEPHONE, 'Type should be ' + SEConstants.TASK_TYPE_TELEPHONE);
            System.assertEquals(objTsk.Subject, System.Label.Return_LC, 'Subject should be ' + System.Label.Return_LC);
            System.assertEquals(objTsk.Status, SEConstants.TASK_STATUS_CLOSED, 'Status should be ' + SEConstants.TASK_STATUS_CLOSED);
            System.assertEquals(objTsk.Description,strTaskDesc,'Lead Description should be same in Task description');
            Test.stoptest();
        }
    }
    
}