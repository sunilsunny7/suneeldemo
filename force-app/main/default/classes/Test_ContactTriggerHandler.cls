/**
    About
    -----
    Description: Test Class Test_ContactTriggerHandler on Contact for ContactTriggerHandler
    Create date: 07.11-2016

    Update History
    --------------
    Created Nov 2016 - A.N - New test methods no01-no03 for createLeadAndBuyInterestOnPardotSync SAEN 1911/1952
    Updated Oct 2016 - A.N - New test method no04 for pardotSyncResetNamePhoneFields SAEN 1879/2011.
    Updated march 2017 - S.S - new test method for tupdateContactRoleOnAccountContactRelationRecords case 2568
    Updated Jun 2017 - Case # 3410 - Email field is mandatory, thus when a Contact is created we need to add email Also, Role will be mandatory for all Customer Contact.
                     - Case # 3094 - First Name is mandatory for all Customer Contact.
    Updated July 2017 - P.P - SALEF - 73 - New TestMethod for Contact Management Req 1

    Issues / TODOs
    --------------
*/

@IsTest
public with sharing class Test_ContactTriggerHandler {

    // This test verifies the basic functionality of the createLeadAndBuyInterest-method/functionality
    // - Verify one Buy Interest and Lead is created.
    // - Verify fields are correctly copied from Contact to Lead
    // - Verify fields are correctly copied from Contact to Lead to Buy Interest
    public static testmethod void no01_createLeadAndBuyInterestNoExistingBuyInt(){
        System.debug('@@Test no01_testSetContactTeliaId Starts');
        Test_DataFactory.setUpOrg();

        Contact con;
        Account acc;
        System.runAs(new User(Id = Userinfo.getUserId())){
            acc = Test_DataFactory.createOneLargeStandardAccount();
            insert acc;
            con = new Contact(LastName='TestLastName');
            con.Pardot_Sync__c = 1;
            con.AccountId = acc.Id;
            con.Product_Area__c = LeadTriggerHandler.LEAD_PRODAREA_BB;
            con.FirstName = 'TestFirstName';
            con.Phone = '+460345678';
            con.Email = 'test@dummy.com';
            con.Role__c = 'Annan';
            insert con;
        }

        Contact conAfterInsert = [SELECT Id, (SELECT Id FROM Buy_Interests__r) FROM Contact WHERE Id = :con.Id LIMIT 1];
        System.assert(conAfterInsert.Buy_Interests__r.isEmpty(), 'No Buy Interest records should be created on contact creation');

        System.runAs(new User(Id = Userinfo.getUserId())){
            test.startTest();
            // This simulates submitting a new Lead form on the existing contact
            con.Pardot_Sync__c += 1;
            con.MailingCity = 'TestCity';
            con.MailingCountry = 'Sweden';
            con.MailingStreet = 'TestStreet';
            con.MailingPostalCode = '12345';
            con.Description = 'Test Description';
            con.Email = 'testemail@test.com';
            con.HasOptedOutOfEmail = false;
            con.Fax = '12345678';
            con.LeadSource = LeadTriggerHandler.LEAD_SOURCE_OTHER;
            con.MobilePhone = '+467054321';
            con.Title = 'TestTitle';
            con.Org_nr__c = '12345678910';

            con.Description_Pardot__c = 'Test Pardot Description';
            //con.Form_Source__c = 'TBD';
            con.Form_Source_URL__c = 'formsourceurl.test.com';

            con.Lead_Submitter_email__c = 'testemail.submitter@test.com';
            con.Lead_Submitter_first_name__c = 'SubFirstName';
            con.Lead_Submitter_ID__c = 'teliaid';
            con.Lead_Submitter_Last_name__c = 'SubLastName';
            con.Lead_Submitter_No__c = '123456';
            con.Lead_Submitter_phone__c = '+467034567';

            update con;
            test.stopTest();
        }

        Contact conAfterUpdate = [SELECT Id,
        (SELECT Id, Lead__c, Status__c, Description__c, Form_Source__c, Form_Source_URL__c, Lead_Source__c, Name, Interest_Broadband__c,
                Interest_Cloud_Services__c, Interest_Company_Network__c, Interest_Contact_Center__c, Interest_Expert_and_Service_Duties__c,
                Interest_IOT__c, Interest_Meeting_Services__c, Interest_Other__c, Interest_Support_Services__c, Interest_Switches__c,
                Interest_Telephony__c FROM Buy_Interests__r)
        FROM Contact WHERE Id = :con.Id LIMIT 1];

        // Assert Buy Interest and Lead has been created OK
        System.assert(!conAfterUpdate.Buy_Interests__r.isEmpty(), 'Buy Interest records should be created on contact pardot sync update');
        System.assertEquals(conAfterUpdate.Buy_Interests__r.size(), 1, 'Exactly one Buy Interest record should be related to the contact');
        System.assertNotEquals(conAfterUpdate.Buy_Interests__r[0].Lead__c, null, 'There should be a lead related to the new Buy Interest');

        // Assert Contact -> Buy Interest fields mapping is correct
        Buy_Interest__c bi = conAfterUpdate.Buy_Interests__r[0];
        System.assertEquals(bi.Status__c, 'Nytt' ,'Incorrect Buy interest value for field Status__c');
        System.assertEquals(bi.Description__c, con.Description_Pardot__c ,'Incorrect Buy interest value for field Description__c');
        //System.assertEquals(bi.Form_Source__c, con.Form_Source__c ,'Incorrect Buy interest value for field Form_Source__c');
        System.assertEquals(bi.Form_Source_URL__c, con.Form_Source_URL__c ,'Incorrect Buy interest value for field Form_Source_URL__c');
        System.assertEquals(bi.Lead_Source__c, con.LeadSource ,'Incorrect Buy interest value for field Lead_Source__c');
        System.assertEquals(bi.Name, con.Product_Area__c ,'Incorrect Buy interest value for field Name');
        System.assertEquals(bi.Interest_Broadband__c, true ,'Incorrect Buy interest value for field Interest_Broadband__c');
        System.assertEquals(bi.Interest_Cloud_Services__c, false ,'Incorrect Buy interest value for field Interest_Cloud_Services__c');
        System.assertEquals(bi.Interest_Company_Network__c, false ,'Incorrect Buy interest value for field Interest_Company_Network__c');
        System.assertEquals(bi.Interest_Contact_Center__c, false ,'Incorrect Buy interest value for field Interest_Contact_Center__c');
        System.assertEquals(bi.Interest_Expert_and_Service_Duties__c, false ,'Incorrect Buy interest value for field Interest_Expert_and_Service_Duties__c');
        System.assertEquals(bi.Interest_IOT__c, false ,'Incorrect Buy interest value for field Interest_IOT__c');
        System.assertEquals(bi.Interest_Meeting_Services__c, false ,'Incorrect Buy interest value for field Interest_Meeting_Services__c');
        System.assertEquals(bi.Interest_Other__c, false ,'Incorrect Buy interest value for field Interest_Other__c');
        System.assertEquals(bi.Interest_Support_Services__c, false ,'Incorrect Buy interest value for field Interest_Support_Services__c');
        System.assertEquals(bi.Interest_Switches__c, false ,'Incorrect Buy interest value for field Interest_Switches__c');
        System.assertEquals(bi.Interest_Telephony__c, false ,'Incorrect Buy interest value for field Interest_Telephony__c');

        // Assert Contact -> Lead fields mapping is correct
        Lead newLead = [SELECT Id, Status, Pardot_Sync__c, Company, City, Country, Street, PostalCode, Description, Email,
                HasOptedOutOfEmail, Fax, FirstName, LastName, LeadSource, MobilePhone, Phone, Title, Contact__c,
                Description_Pardot__c, Form_Source_URL__c, Product_Area__c, Account__c, Lead_Submitter_email__c,
                Lead_Submitter_first_name__c, Lead_Submitter_ID__c, Lead_Submitter_Last_name__c, Lead_Submitter_No__c,
                Lead_Submitter_phone__c, Org_nr__c FROM Lead WHERE Id = :bi.Lead__c LIMIT 1];
        System.assertEquals(newLead.Status, 'Nytt', ' Wrong value for Lead field Status');
        System.assertEquals(newLead.Pardot_Sync__c, 1, ' Wrong value for Lead field Pardot_Sync__c');
        // Standard Fields Mapping
        System.assertEquals(newLead.Company, acc.Name, ' Wrong value for Lead field Company');
        System.assertEquals(newLead.Org_nr__c, con.Org_nr__c, ' Wrong value for Lead field Org nr');
        System.assertEquals(newLead.City, con.MailingCity, ' Wrong value for Lead field City');
        System.assertEquals(newLead.Country, con.MailingCountry, ' Wrong value for Lead field Country');
        System.assertEquals(newLead.Street, con.MailingStreet, ' Wrong value for Lead field Street');
        System.assertEquals(newLead.PostalCode, con.MailingPostalCode, ' Wrong value for Lead field PostalCode');
        System.assertEquals(newLead.Description, con.Description, ' Wrong value for Lead field Description');
        System.assertEquals(newLead.Email, con.Email, ' Wrong value for Lead field Email');
        System.assertEquals(newLead.HasOptedOutOfEmail, con.HasOptedOutOfEmail, ' Wrong value for Lead field HasOptedOutOfEmail');
        System.assertEquals(newLead.Fax, con.Fax, ' Wrong value for Lead field Fax');
        System.assertEquals(newLead.FirstName, con.FirstName, ' Wrong value for Lead field FirstName');
        System.assertEquals(newLead.LastName, con.LastName, ' Wrong value for Lead field LastName');
        System.assertEquals(newLead.LeadSource, con.LeadSource, ' Wrong value for Lead field LeadSource');
        System.assertEquals(newLead.Title, con.Title, ' Wrong value for Lead field Title');
        // Custom Fields Mapping
        System.assertEquals(newLead.Contact__c, con.Id, ' Wrong value for Lead field Contact__c');
        //System.assertEquals(newLead.Form_Source__c, con.Form_Source__c, ' Wrong value for Lead field XXXX');
        System.assertEquals(newLead.Form_Source_URL__c, con.Form_Source_URL__c, ' Wrong value for Lead field Form_Source_URL__c');
        System.assertEquals(newLead.Product_Area__c, con.Product_Area__c, ' Wrong value for Lead field Product_Area__c');
        System.assertEquals(newLead.Account__c, con.AccountId, ' Wrong value for Lead field Account__c');
        // Submitter fields mapping
        System.assertEquals(newLead.Lead_Submitter_email__c, con.Lead_Submitter_email__c, ' Wrong value for Lead field Lead_Submitter_email__c');
        System.assertEquals(newLead.Lead_Submitter_first_name__c, con.Lead_Submitter_first_name__c, ' Wrong value for Lead field Lead_Submitter_first_name__c');
        System.assertEquals(newLead.Lead_Submitter_ID__c, con.Lead_Submitter_ID__c, ' Wrong value for Lead field Lead_Submitter_ID__c');
        System.assertEquals(newLead.Lead_Submitter_Last_name__c, con.Lead_Submitter_Last_name__c, ' Wrong value for Lead field Lead_Submitter_Last_name__c');
        System.assertEquals(newLead.Lead_Submitter_No__c, con.Lead_Submitter_No__c, ' Wrong value for Lead field Lead_Submitter_No__c');
        System.assertEquals(newLead.Lead_Submitter_phone__c, con.Lead_Submitter_phone__c, ' Wrong value for Lead field Lead_Submitter_phone__c');
    }

    // This tests the functionality when a new leadform is submitted (from Pardot) and there 
    // is an existing Buy Interest related to the contact
    // - A new Lead and Buy Interest should be created
    // - The existing Buy Interest should be related to the newly created lead
    public static testmethod void no02_createLeadAndBuyInterestExistingBuyInt(){
        System.debug('@@Test no01_testSetContactTeliaId Starts');
        Test_DataFactory.setUpOrg();

        Contact con;
        Account acc;
        System.runAs(new User(Id = Userinfo.getUserId())){
            acc = Test_DataFactory.createOneLargeStandardAccount();
            insert acc;
            con = Test_DataFactory.createOneContact();
            con.Pardot_Sync__c = 1;
            con.AccountId = acc.Id;
            con.Product_Area__c = LeadTriggerHandler.LEAD_PRODAREA_BB;
            insert con;
            Buy_Interest__c existingBi = new Buy_Interest__c();
            existingBi.Contact__c = con.Id;
            existingBi.Status__c = 'Konverterat';
            existingBi.Name = con.Product_Area__c;
            insert existingBi;
        }

        Contact conAfterInsert = [SELECT Id, (SELECT Id FROM Buy_Interests__r) FROM Contact WHERE Id = :con.Id LIMIT 1];
        System.assertEquals(conAfterInsert.Buy_Interests__r.size(), 1, 'There should be one Buy Interest record related to the contact');

        System.runAs(new User(Id = Userinfo.getUserId())){
            test.startTest();
            con.Pardot_Sync__c += 1;
            update con;
            test.stopTest();
        }

        Contact conAfterUpdate = [SELECT Id, (SELECT Id, Lead__c, Status__c FROM Buy_Interests__r ORDER BY Status__c ASC) FROM Contact WHERE Id = :con.Id LIMIT 1];
        System.assertEquals(conAfterUpdate.Buy_Interests__r.size(), 2, 'There should be two Buy Interest records related to the contact');
        System.assertNotEquals(conAfterUpdate.Buy_Interests__r[0].Lead__c, null, 'There should be a lead related to the new Buy Interest');
        System.assertEquals(conAfterUpdate.Buy_Interests__r[0].Status__c, 'Nytt', 'The new Buy Interest should have status "Nytt"');
        System.assertEquals(conAfterUpdate.Buy_Interests__r[0].Lead__c, conAfterUpdate.Buy_Interests__r[1].Lead__c, 'Both Buy Interest records should relate to the same lead');
        System.assertNotEquals(conAfterUpdate.Buy_Interests__r[0].Status__c, conAfterUpdate.Buy_Interests__r[1].Status__c, 'The Buy Interest records should not have the same status');
    }

    // This tests the functionality when a new leadform is submitted (from Pardot) and there 
    // is an existing Lead and Buy Interest related to the contact
    // - A new Lead and Buy Interest should be created
    // - The existing Buy Interest should be related to the newly created lead
    // - No Buy Interest should be related to the old Lead
    public static testmethod void no03_createLeadAndBuyInterestExistingBuyIntAndLead(){
        System.debug('@@Test no01_testSetContactTeliaId Starts');
        Test_DataFactory.setUpOrg();

        Contact con;
        Account acc;
        Lead existingLead;
        System.runAs(new User(Id = Userinfo.getUserId())){
            acc = Test_DataFactory.createOneLargeStandardAccount();
            insert acc;
            con = Test_DataFactory.createOneContact();
            con.Pardot_Sync__c = 1;
            con.AccountId = acc.Id;
            con.Product_Area__c = LeadTriggerHandler.LEAD_PRODAREA_BB;
            insert con;
            existingLead = Test_DataFactory.createLead();
            insert existingLead;
            Buy_Interest__c existingBi = new Buy_Interest__c();
            existingBi.Lead__c = existingLead.Id;
            existingBi.Contact__c = con.Id;
            existingBi.Status__c = 'Kvalificera';
            existingBi.Name = con.Product_Area__c;
            insert existingBi;
        }

        Contact conAfterInsert = [SELECT Id, (SELECT Id, Lead__c FROM Buy_Interests__r) FROM Contact WHERE Id = :con.Id LIMIT 1];
        System.assertEquals(conAfterInsert.Buy_Interests__r.size(), 1, 'There should be one Buy Interest record related to the contact');
        System.assertEquals(conAfterInsert.Buy_Interests__r[0].Lead__c, existingLead.Id, 'There should be one Buy Interest record related to the contact');

        Lead oldLeadBefore = [SELECT Id, (SELECT Id FROM Buy_Interests__r) FROM Lead WHERE Id = :existingLead.Id LIMIT 1];
        System.assertEquals(oldLeadBefore.Buy_Interests__r.size(), 1, 'There should be one Buy Interest record related to the existing Lead');

        System.runAs(new User(Id = Userinfo.getUserId())){
            test.startTest();
            con.Pardot_Sync__c += 1;
            LeadTriggerHandler.pardotLeadsBuyInterestCreated = false;
            update con;
            test.stopTest();
        }

        Contact conAfterUpdate = [SELECT Id, (SELECT Id, Lead__c, Status__c FROM Buy_Interests__r ORDER BY Status__c ASC) FROM Contact WHERE Id = :con.Id LIMIT 1];
        System.assertEquals(conAfterUpdate.Buy_Interests__r.size(), 2, 'There should be two Buy Interest records related to the contact');
        System.assertNotEquals(conAfterUpdate.Buy_Interests__r[0].Lead__c, null, 'There should be a lead related to the new Buy Interest');
        System.assertEquals(conAfterUpdate.Buy_Interests__r[0].Status__c, 'Nytt', 'The new Buy Interest should have status "Nytt"');
        System.assertEquals(conAfterUpdate.Buy_Interests__r[1].Status__c, 'Kvalificera', 'The old Buy Interest should have status "Kvalificera"');
        System.assertNotEquals(conAfterUpdate.Buy_Interests__r[1].Lead__c, null, 'The old Buy Interest should be related to a Lead');
        System.assertNotEquals(conAfterUpdate.Buy_Interests__r[1].Lead__c, existingLead.Id, 'The old Buy Interest should be related to the new Lead, not the old Lead');
        System.assertEquals(conAfterUpdate.Buy_Interests__r[0].Lead__c, conAfterUpdate.Buy_Interests__r[1].Lead__c, 'Both Buy Interest records should relate to the same lead');
        System.assertNotEquals(conAfterUpdate.Buy_Interests__r[0].Status__c, conAfterUpdate.Buy_Interests__r[1].Status__c, 'The Buy Interest records should not have the same status');

        Lead newLead = [SELECT Id, (SELECT Id FROM Buy_Interests__r) FROM Lead WHERE Id != :existingLead.Id LIMIT 1];
        System.assertEquals(newLead.Buy_Interests__r.size(), 2, 'There should be two Buy Interest record related to the new Lead');

        Lead oldLeadAfter = [SELECT Id, (SELECT Id FROM Buy_Interests__r) FROM Lead WHERE Id = :existingLead.Id LIMIT 1];
        System.assertEquals(oldLeadAfter.Buy_Interests__r.size(), 0, 'There should not be any Buy Interest record related to the old Lead');
    }

    // This test verifies the functionality of the contact update + createLeadAndBuyInterest-functionality when Pardot tries to update Name/Phone fields through a new Lead form
    // - If new Lead form from Pardot, do not update the First Name, Last Name and Phone fields on the contact record
    // - However, on newly created Leads/Buy Interests the First Name, Last Name and Phone should correspond to the lead form, not the contact
    public static testmethod void no04_createPardotLeadForm_UpdatedNamePhoneFields(){
        System.debug('@@Test no01_testSetContactTeliaId Starts');
        Test_DataFactory.setUpOrg();

        Contact con;
        Account acc;
        System.runAs(new User(Id = Userinfo.getUserId())){
            acc = Test_DataFactory.createOneLargeStandardAccount();
            insert acc;
            con = new Contact(LastName='TestLastName');
            con.FirstName = 'TestFirstName';
            con.Email = 'test@dummy.com';
            con.Phone = '+12345678';
            con.Role__c = 'Annan';
            con.Pardot_Sync__c = 1;
            con.AccountId = acc.Id;
            con.Product_Area__c = LeadTriggerHandler.LEAD_PRODAREA_BB;
            insert con;
        }

        Contact conAfterInsert = [SELECT Id, FirstName, LastName, Phone, Email FROM Contact WHERE Id = :con.Id LIMIT 1];

        System.runAs(new User(Id = Userinfo.getUserId())){
            test.startTest();
            // This simulates submitting a new Lead form on the existing contact
            con.Pardot_Sync__c += 1;
            con.FirstName = 'NewTestFirstName';
            con.LastName= 'NewTestLastName';
            con.Phone = '+87654321';
            con.Email = 'newtestemail@test.com';
            con.Role__c = 'Annan';
            con.LeadSource = LeadTriggerHandler.LEAD_SOURCE_OTHER;
            con.Description_Pardot__c = 'Test Pardot Description';
            con.Form_Source_URL__c = 'formsourceurl.test.com';
            update con;
            test.stopTest();
        }

        Contact conAfterUpdate = [SELECT Id, FirstName, LastName, Phone, Email FROM Contact WHERE Id = :con.Id LIMIT 1];

        // Assert Contact fields update as expected after new Pardot form
        // FirstName, LastName, Phone should not be updated
        System.assertEquals(conAfterUpdate.FirstName ,conAfterInsert.FirstName , 'FirstName should not be changed based on Pardot update');
        System.assertEquals(conAfterUpdate.FirstName, 'TestFirstName', 'Wrong value for FirstName after Pardot update');
        System.assertNotEquals(conAfterUpdate.FirstName, 'NewTestFirstName', 'Wrong value for FirstName after Pardot update');
        System.assertEquals(conAfterUpdate.LastName ,conAfterInsert.LastName , 'LastName should not be changed based on Pardot update');
        System.assertEquals(conAfterUpdate.LastName, 'TestLastName', 'Wrong value for LastName after Pardot update');
        System.assertNotEquals(conAfterUpdate.LastName, 'NewTestLastName', 'Wrong value for LastName after Pardot update');
        System.assertEquals(conAfterUpdate.Phone ,conAfterInsert.Phone , 'Phone should not be changed based on Pardot update');
        System.assertEquals(conAfterUpdate.Phone, '+12345678', 'Wrong value for Phone after Pardot update');
        System.assertNotEquals(conAfterUpdate.Phone, '+87654321', 'Wrong value for Phone after Pardot update');
        // Email should be updated
        System.assertNotEquals(conAfterUpdate.Email ,conAfterInsert.Email , 'Email should be changed based on Pardot update');
        System.assertEquals(conAfterUpdate.Email, 'newtestemail@test.com', 'Wrong value for Email after Pardot update');

        // Assert Contact -> Lead fields mapping is correct
        Lead newLead = [SELECT Id, Email, FirstName, LastName, Phone, Contact__c FROM Lead WHERE Contact__c = :conAfterUpdate.Id LIMIT 1];

        // Assert Lead fields update as expected after new Pardot form
        // FirstName, LastName, Phone should be as in the submitted form, and will be different than on the Contact record
        System.assertNotEquals(newLead.FirstName ,conAfterUpdate.FirstName , 'FirstName should not be the same on Lead and Contact');
        System.assertEquals(newLead.FirstName, 'NewTestFirstName', 'Wrong value for FirstName on the Lead');
        System.assertNotEquals(newLead.LastName ,conAfterUpdate.LastName , 'LastName should not be the same on Lead and Contact');
        System.assertEquals(newLead.LastName, 'NewTestLastName', 'Wrong value for LastName on the Lead');
        System.assertNotEquals(newLead.Phone ,conAfterUpdate.Phone , 'Phone should not be the same on Lead and Contact');
        System.assertEquals(newLead.Phone, '+87654321', 'Wrong value for Phone on the Lead');
        // Email should be updated
        System.assertEquals(newLead.Email ,conAfterUpdate.Email , 'Email should be the same on Lead and Contact');
        System.assertEquals(newLead.Email, 'newtestemail@test.com', 'Wrong value for Email on the Lead');
    }

    static testMethod void testupdateContactRoleOnAccountContactRelationRecords(){
        User largeUser;
        Contact con;
        Account accPrimary;
        Account accSecondary;

        System.runAs(new User(Id = Userinfo.getUserId())){
            largeUser = Test_DataFactory.createLargeUser();
            insert largeUser;

            accPrimary = Test_DataFactory.createOneLargeStandardAccount();
            accPrimary.OwnerId = largeUser.Id;
            insert accPrimary;

            accSecondary = Test_DataFactory.createOneLargeStandardAccount();
            accSecondary.OwnerId = largeUser.Id;
            insert accSecondary;
        }

        System.runAs(largeUser){
            con = Test_DataFactory.createOneContact();
            con.AccountId = accPrimary.Id;
            con.Role__c = 'IT-chef/CTO';
            insert con;
        }
        System.runAs(largeUser){
            AccountContactRelation acr = new AccountContactRelation();
            acr.AccountId = accSecondary.Id;
            acr.ContactId = con.Id;
            insert acr;

            con.Role__c = 'Driftchef';
            update con;
            List<Contact> updtconList = new List<Contact>();
            List<Contact> conList= test_DataFactory.createContacts(7);
            for (contact c :conList){
                c.AccountId=accPrimary.Id;
                updtconList.add(c);
            }
            insert updtconList;
            contacttriggerhandler.updateMarketingMailsOptOutOnConInsert(updtconList);
        }
    }

    //N.G - SAEN- 1838
/*    static testMethod void testupdateMarketingMailsOptOutOnConInsert(){
        string accChildRecTypeID    =  [select id,developername from recordtype where developername = 'Large_Sales_Organisation_Account'].id;
        string accParentRecTypeID    = [select id,developername from recordtype where developername = 'Kundkonto_S_k_2'].id;
        system.debug('*****accParentRecTypeID*******'+accParentRecTypeID);
        
        ExcludedRecords__c exclRecords = new ExcludedRecords__c();
        exclRecords.Name = 'AcntRollUpExcludedRecords';
        exclRecords.Description__c = 'Test';
        insert exclRecords;
        
        BypassConValidation__c tempSkipConValidation = BypassConValidation__c.getInstance();
        if(tempSkipConValidation == null) {
          tempSkipConValidation = new BypassConValidation__c();
        }
        tempSkipConValidation.BypassValidationContact__c  = true;
        upsert tempSkipConValidation ;
        
        //Create Parent Account
        Account acc = Test_DataFactory.createOneAccount();
        acc.recordtypeID =  accParentRecTypeID;
        acc.Marketing_Mails_Opt_Out__c = 'Upon Client request';
        acc.Kundkonto_Nr__c = 'abc' + '0';
        insert acc;
        
        //Create child Account
        Account childAcc = Test_DataFactory.createOneAccount();
        childAcc.recordtypeID = accChildRecTypeID;
        childAcc.parentID = acc.ID;
        insert childAcc;
        system.debug('*****childAcc***test***'+childAcc);
        
        //Create child Contact
        Contact con = Test_DataFactory.createOneContact();
        con.AccountId  = childAcc.id;
        con.Marketing_Mails_Opt_Out_Contact__c = '';
        insert con;
        
        acc.Marketing_Mails_Opt_Out__c = 'According to agreement';
        acc.From_date__c = date.today();
        acc.To_date__c = date.today().addDays(4);
        update acc;
        
        string childAccMoof = [SELECT Marketing_Mails_Opt_Out__c from ACCOUNT where id =: childAcc.id].Marketing_Mails_Opt_Out__c;
        system.assertEquals('According to agreement',childAccMoof);
        
        //Verifying if Marketing_Mails_Opt_Out_Contact__c filed of Contact has been updated
        string childConMoof = [SELECT Marketing_Mails_Opt_Out_Contact__c from CONTACT where id =: con.id].Marketing_Mails_Opt_Out_Contact__c;
        system.assertEquals('According to agreement',childConMoof);
        
    }   */

    public static testmethod void no05_createLeadAndBuyInterestOnCygateSync(){  // V.A
        System.debug('@@Test no01_testSetContactTeliaId Starts');
        Test_DataFactory.setUpOrg();

        Contact con;
        Account acc;
        System.runAs(new User(Id = Userinfo.getUserId())){
            acc = Test_DataFactory.createOneLargeStandardAccount();
            insert acc;
            con = new Contact(LastName='TestLastName');
            con.Cygate_Sync__c = 1;
            con.AccountId = acc.Id;
            con.Product_Area__c = LeadTriggerHandler.LEAD_PRODAREA_UC;
            con.FirstName = 'TestFirstName';
            con.Phone = '+460345678';
            con.Email = 'test@dummy.com';
            con.Role__c = 'Annan';
            insert con;
        }

        Contact conAfterInsert = [SELECT Id, (SELECT Id FROM Buy_Interests__r) FROM Contact WHERE Id = :con.Id LIMIT 1];
        System.assert(conAfterInsert.Buy_Interests__r.isEmpty(), 'No Buy Interest records should be created on contact creation');

        System.runAs(new User(Id = Userinfo.getUserId())){
            test.startTest();
            // This simulates submitting a new Lead form on the existing contact
            con.Cygate_Sync__c += 1;
            con.MailingCity = 'TestCity';
            con.MailingCountry = 'Sweden';
            con.MailingStreet = 'TestStreet';
            con.MailingPostalCode = '12345';
            con.Description = 'Test Description';
            con.Email = 'testemail@test.com';
            con.HasOptedOutOfEmail = false;
            con.Fax = '12345678';
            con.LeadSource = LeadTriggerHandler.LEAD_SOURCE_OTHER;
            con.MobilePhone = '+467054321';
            con.Title = 'TestTitle';

            con.Description_Pardot__c = 'Test Pardot Description';
            //con.Form_Source__c = 'TBD';
            con.Form_Source_URL__c = 'formsourceurl.test.com';

            con.Lead_Submitter_email__c = 'testemail.submitter@test.com';
            con.Lead_Submitter_first_name__c = 'SubFirstName';
            con.Lead_Submitter_ID__c = 'teliaid';
            con.Lead_Submitter_Last_name__c = 'SubLastName';
            con.Lead_Submitter_No__c = '123456';
            con.Lead_Submitter_phone__c = '+4670345678';
            con.Org_nr__c = '12345678910';

            update con;
            test.stopTest();
        }

        Contact conAfterUpdate = [SELECT Id,
        (SELECT Id, Lead__c, Status__c, Description__c, Form_Source__c, Form_Source_URL__c, Lead_Source__c, Name, Cloud__c,
                Security__c, Server_Storage__c, Citynet__c, Network__c,DMD__c, UC__c FROM Buy_Interests__r)
        FROM Contact WHERE Id = :con.Id LIMIT 1];

        // Assert Buy Interest and Lead has been created OK
        System.assert(!conAfterUpdate.Buy_Interests__r.isEmpty(), 'Buy Interest records should be created on contact pardot sync update');
        System.assertEquals(conAfterUpdate.Buy_Interests__r.size(), 1, 'Exactly one Buy Interest record should be related to the contact');
        System.assertNotEquals(conAfterUpdate.Buy_Interests__r[0].Lead__c, null, 'There should be a lead related to the new Buy Interest');

        // Assert Contact -> Buy Interest fields mapping is correct
        Buy_Interest__c bi = conAfterUpdate.Buy_Interests__r[0];
        System.assertEquals(bi.Status__c, 'Nytt' ,'Incorrect Buy interest value for field Status__c');
        System.assertEquals(bi.Description__c, con.Description_Pardot__c ,'Incorrect Buy interest value for field Description__c');
        //System.assertEquals(bi.Form_Source__c, con.Form_Source__c ,'Incorrect Buy interest value for field Form_Source__c');
        System.assertEquals(bi.Form_Source_URL__c, con.Form_Source_URL__c ,'Incorrect Buy interest value for field Form_Source_URL__c');
        System.assertEquals(bi.Lead_Source__c, con.LeadSource ,'Incorrect Buy interest value for field Lead_Source__c');
        System.assertEquals(bi.Name, con.Product_Area__c ,'Incorrect Buy interest value for field Name');
        System.assertEquals(bi.Cloud__c, false ,'Incorrect Buy interest value for field Cloud__c');
        System.assertEquals(bi.Security__c, false ,'Incorrect Buy interest value for field Security__c');
        System.assertEquals(bi.Server_Storage__c, false ,'Incorrect Buy interest value for field Server_Storage__c');
        System.assertEquals(bi.Citynet__c, false ,'Incorrect Buy interest value for field Citynet__c');
        System.assertEquals(bi.Network__c, false ,'Incorrect Buy interest value for field Network__c');
        System.assertEquals(bi.DMD__c, false ,'Incorrect Buy interest value for field DMD__c');
        //System.assertEquals(bi.UC__c, true ,'Incorrect Buy interest value for field UC__c');

        // Assert Contact -> Lead fields mapping is correct
        Lead newLead = [SELECT Id, Status, Cygate_Sync__c, Company, City, Country, Street, PostalCode, Description, Email,
                HasOptedOutOfEmail, Fax, FirstName, LastName, LeadSource, MobilePhone, Phone, Title, Contact__c,
                Description_Pardot__c, Form_Source_URL__c, Product_Area__c, Account__c, Lead_Submitter_email__c,
                Lead_Submitter_first_name__c, Lead_Submitter_ID__c, Lead_Submitter_Last_name__c, Lead_Submitter_No__c,
                Lead_Submitter_phone__c, Org_nr__c FROM Lead WHERE Id = :bi.Lead__c LIMIT 1];
        System.assertEquals(newLead.Status, 'Nytt', ' Wrong value for Lead field Status');
        System.assertEquals(newLead.Cygate_Sync__c, 1, ' Wrong value for Lead field Cygate_Sync__c');
        // Standard Fields Mapping
        System.assertEquals(newLead.Company, acc.Name, ' Wrong value for Lead field Company');
        System.assertEquals(newLead.Org_nr__c, con.Org_nr__c, ' Wrong value for Lead field Org nr');
        System.assertEquals(newLead.City, con.MailingCity, ' Wrong value for Lead field City');
        System.assertEquals(newLead.Country, con.MailingCountry, ' Wrong value for Lead field Country');
        System.assertEquals(newLead.Street, con.MailingStreet, ' Wrong value for Lead field Street');
        System.assertEquals(newLead.PostalCode, con.MailingPostalCode, ' Wrong value for Lead field PostalCode');
        System.assertEquals(newLead.Description, con.Description, ' Wrong value for Lead field Description');
        System.assertEquals(newLead.Email, con.Email, ' Wrong value for Lead field Email');
        System.assertEquals(newLead.HasOptedOutOfEmail, con.HasOptedOutOfEmail, ' Wrong value for Lead field HasOptedOutOfEmail');
        System.assertEquals(newLead.Fax, con.Fax, ' Wrong value for Lead field Fax');
        System.assertEquals(newLead.FirstName, con.FirstName, ' Wrong value for Lead field FirstName');
        System.assertEquals(newLead.LastName, con.LastName, ' Wrong value for Lead field LastName');
        System.assertEquals(newLead.LeadSource, con.LeadSource, ' Wrong value for Lead field LeadSource');
        System.assertEquals(newLead.Title, con.Title, ' Wrong value for Lead field Title');
        // Custom Fields Mapping
        System.assertEquals(newLead.Contact__c, con.Id, ' Wrong value for Lead field Contact__c');
        //System.assertEquals(newLead.Form_Source__c, con.Form_Source__c, ' Wrong value for Lead field XXXX');
        System.assertEquals(newLead.Product_Area__c, con.Product_Area__c, ' Wrong value for Lead field Product_Area__c');
        System.assertEquals(newLead.Account__c, con.AccountId, ' Wrong value for Lead field Account__c');
        // Submitter fields mapping
        System.assertEquals(newLead.Lead_Submitter_email__c, con.Lead_Submitter_email__c, ' Wrong value for Lead field Lead_Submitter_email__c');
        System.assertEquals(newLead.Lead_Submitter_first_name__c, con.Lead_Submitter_first_name__c, ' Wrong value for Lead field Lead_Submitter_first_name__c');
        System.assertEquals(newLead.Lead_Submitter_ID__c, con.Lead_Submitter_ID__c, ' Wrong value for Lead field Lead_Submitter_ID__c');
        System.assertEquals(newLead.Lead_Submitter_Last_name__c, con.Lead_Submitter_Last_name__c, ' Wrong value for Lead field Lead_Submitter_Last_name__c');
        System.assertEquals(newLead.Lead_Submitter_No__c, con.Lead_Submitter_No__c, ' Wrong value for Lead field Lead_Submitter_No__c');
        System.assertEquals(newLead.Lead_Submitter_phone__c, con.Lead_Submitter_phone__c, ' Wrong value for Lead field Lead_Submitter_phone__c');
    }


    public static testmethod void no06_testContactManagement(){ //P.P
        User uR1 = new User();
        User uL1 = new user();
        user uC1 = new User();
        user uSM1 = new User();
        user uM1 = new User();
        string roleuR1 = '';
        string roleuL1 = '';
        string roleuC1 = '';
        string roleuSM1 = '';
        string roleuM1 = '';
        Account acc1 = new Account();
        Account acc2 = new Account();
        Account acc3 = new Account();
        Account acc4= new Account();
        Contact conL = new Contact();
        Contact conLF = new Contact();
        Contact conC = new Contact();
        Contact conCF = new Contact();
        Contact conR = new Contact();
        Contact conRF = new Contact();
        Contact conSM = new Contact();
        Contact conSMF = new Contact();
        Contact conM = new Contact();
        Contact conMF = new Contact();
        List<Id> conIdList = new List<Id>();
        Test_DataFactory.setUpOrg();

        System.runAs(Test_DataFactory.getByPassUser()){// to avoid MIXED_DML operation

            List<User> renewalUserList = Test_DataFactory.createLargeRenewalUserTeam(1);
            uR1 = renewalUserList[0];
            roleuR1 = uR1.UserRoleId;
            List<user> largeUserList = Test_DataFactory.createLargeUserTeam(2);
            uL1 = largeUserList[0];
            roleuL1 = uL1.UserRoleId;
            uC1 = Test_DataFactory.createCygateUser();
            insert uC1;
            roleuC1 = uC1.userRoleId;
            List<User> uSMList = Test_DataFactory.createSMUserTeam(1);
            uSM1 = uSMList[0];
            roleuSM1 = uSM1.userRoleId;
            List<User> uMList = Test_DataFactory.createMarketingUserTeam(1);
            uM1 = uMList[0];
            roleuM1 = uM1.userRoleId;
        }

        insert new Contact_Management_Role_Set__c(name = 'Cygate Role 01',Role_ID__c = roleuC1,Role_Name__c = 'CG:Säljare Syd',Segment__c = 'Cygate');
        insert new Contact_Management_Role_Set__c(name = 'Telia Role 01',Role_ID__c = roleuL1,Role_Name__c = 'Large Public North',Segment__c = 'Telia');
        insert new Contact_Management_Role_Set__c(name = 'Other Role 01',Role_ID__c = roleuR1,Role_Name__c = 'Renewal',Segment__c = 'Other');
        insert new Contact_Management_Role_Set__c(name = 'SM Role 01',Role_ID__c = roleuSM1,Role_Name__c = 'CSM1',Segment__c = 'Service Management');
        insert new Contact_Management_Role_Set__c(name = 'Marketing Role 1',Role_ID__c = roleuM1,Role_Name__c = 'Marketing Manager',Segment__c = 'Marketing');
        List<Contact_Management_Role_Set__c> listCMRS = [SELECT Id,Role_Name__c,Role_Id__c,Segment__c FROM Contact_Management_Role_Set__c];
        test.starttest();
        acc1 = Test_DataFactory.createOneLargeStandardAccount();
        acc1.OwnerId = uL1.Id;
        acc1.Cygate_Account_Manager__c = uC1.Id;
        insert acc1;
        acc2 = Test_DataFactory.createOneLargeStandardAccount();
        acc2.OwnerId = uR1.Id;
        insert acc2;
        acc3 = Test_DataFactory.createOneLargeStandardAccount();
        acc3.OwnerId = uSM1.Id;
        insert acc3;
        acc4 = Test_DataFactory.createOneLargeStandardAccount();
        acc4.OwnerId = uM1.Id;
        insert acc4;

        system.runAs(uL1){
            conL = new Contact(LastName='TestLastName');
            conL.AccountId = acc1.Id;
            conL.FirstName = 'TestFirstName';
            conL.Phone = '+460345678';
            conL.Email = 'testl@dummy.com';
            conL.Role__c = 'Annan';
            insert conL;

            conLF = new Contact(LastName='TestLastName');
            conLF.AccountId = acc1.Id;
            conLF.FirstName = 'TestFirstName';
            conLF.Phone = '+460345678';
            conLF.Email = 'testLF@dummy.com';
            conLF.Role__c = 'Annan';
            conLF.Marketing_Primary_Contact__c = True;
            try{
                insert conLF;
            }
            catch(exception e){
                system.debug(e.getmessage());
            }

            conL.Marketing_Primary_Contact__c = True;
            try{
                update conL;
            }
            catch(exception e){
                system.debug(e.getmessage());
            }
        }
        conIdList.add(conL.Id);

        system.runAs(uC1){
            conC = new Contact(LastName='TestLastName');
            conC.AccountId = acc1.Id;
            conC.FirstName = 'TestFirstName';
            conC.Phone = '+460345678';
            conC.Email = 'testC@dummy.com';
            conC.Role__c = 'Annan';
            insert conC;


            conCF = new Contact(LastName='TestLastName');
            conCF.AccountId = acc1.Id;
            conCF.FirstName = 'TestFirstName';
            conCF.Phone = '+460345678';
            conCF.Email = 'testCF@dummy.com';
            conCF.Role__c = 'Annan';
            conCF.Telia_Primary_Contact__c = True;
            try{
                insert conCF;
            }
            catch(exception e){
                system.debug(e.getmessage());
            }

            conC.Telia_Primary_Contact__c = True;
            try{
                update conC;
            }
            catch(exception e){
                system.debug(e.getmessage());
            }
        }
        conIdList.add(conC.Id);

        system.runAs(uR1){
            conR = new Contact(LastName='TestLastName');
            conR.AccountId = acc2.Id;
            conR.FirstName = 'TestFirstName';
            conR.Phone = '+460345678';
            conR.Email = 'testR@dummy.com';
            conR.Role__c = 'Annan';
            insert conR;

            conRF = new Contact(LastName='TestLastName');
            conRF.AccountId = acc2.Id;
            conRF.FirstName = 'TestFirstName';
            conRF.Phone = '+460345678';
            conRF.Email = 'testRF@dummy.com';
            conRF.Role__c = 'Annan';
            conRF.Cygate_Primary_Contact__c = True;
            try{
                insert conRF;
            }
            catch(exception e){
                system.debug(e.getmessage());
            }

            conR.Cygate_Primary_Contact__c = True;
            try{
                update conR;
            }
            catch(exception e){
                system.debug(e.getmessage());
            }
        }
        system.runAs(uSM1){
            conSM = new Contact(LastName='TestLastName');
            conSM.AccountId = acc3.Id;
            conSM.FirstName = 'TestFirstName';
            conSM.Phone = '+460345678';
            conSM.Email = 'testSM@dummy.com';
            conSM.Role__c = 'Annan';
            insert conSM;

            conSMF = new Contact(LastName='TestLastName');
            conSMF.AccountId = acc3.Id;
            conSMF.FirstName = 'TestFirstName';
            conSMF.Phone = '+460345678';
            conSMF.Email = 'testSMF@dummy.com';
            conSMF.Role__c = 'Annan';
            conSMF.Other_Primary_Contact__c = True;
            try{
                insert conSMF;
            }
            catch(exception e){
                system.debug(e.getmessage());
            }
            test.stoptest();
            conSM.Other_Primary_Contact__c = True;
            try{
                update conSM;
            }
            catch(exception e){
                system.debug(e.getmessage());
            }
        }
        conIdList.add(conR.Id);
        conIdList.add(conSM.Id);
        system.runAs(uM1){
            conM = new Contact(LastName='TestLastName');
            conM.AccountId = acc4.Id;
            conM.FirstName = 'TestFirstName';
            conM.Phone = '+460345678';
            conM.Email = 'testM@dummy.com';
            conM.Role__c = 'Annan';
            try{
                insert conM;
            }catch(exception ex){
                system.debug('&&&'+ex.getmessage());
            }

            conMF = new Contact(LastName='TestLastName');
            conMF.AccountId = acc4.Id;
            conMF.FirstName = 'TestFirstName';
            conMF.Phone = '+460345678';
            conMF.Email = 'testMF@dummy.com';
            conMF.Role__c = 'Annan';
            conMF.Service_Management_Primary_Contact__c = True;
            try{
                insert conMF;
            }
            catch(exception e){
                system.debug(e.getmessage());
            }

            conM.Service_Management_Primary_Contact__c = True;
            try{
                update conM;
            }
            catch(exception e){
                system.debug(e.getmessage());
            }
        }
        conIdList.add(conM.Id);
        List<Contact> conList = [SELECT id,Telia_Primary_Contact__c,Marketing_Primary_Contact__c,Cygate_Primary_Contact__c,Other_Primary_Contact__c,Service_Management_Primary_Contact__c FROM Contact WHERE Id =: conIdList];
        for(contact con:conList){
            if(con.Id == conL.Id){
                system.assertEquals(con.Telia_Primary_Contact__c,True);
                system.assertEquals(con.Marketing_Primary_Contact__c,False);
            }
            if(con.Id == conC.Id){
                system.assertEquals(con.Telia_Primary_Contact__c,False);
                system.assertEquals(con.Cygate_Primary_Contact__c,True);
            }
            if(con.Id == conR.Id){
                system.assertEquals(con.Other_Primary_Contact__c,True);
                system.assertEquals(con.Cygate_Primary_Contact__c,False);
            }
            if(con.Id == conM.Id){
                system.assertEquals(con.Marketing_Primary_Contact__c,True);
                system.assertEquals(con.Service_Management_Primary_Contact__c,False);
            }
            if(con.Id == conSM.Id){
                system.assertEquals(con.Other_Primary_Contact__c,False);
                system.assertEquals(con.Service_Management_Primary_Contact__c,True);
            }
        }

    }
    public static testmethod void no07_testdeleteCampaignMembers(){ //P.P
        System.debug('@@Test no07_testdeleteCampaignMembers Starts');
        Test_DataFactory.setUpOrg();

        Contact con;
        Account acc;
        Campaign testCamp1 = new Campaign();
        Campaign testCamp2 = new Campaign();
        CampaignMember testCampMem1 = new CampaignMember();
        CampaignMember testCampMem2  = new CampaignMember();
        System.runAs(new User(Id = Userinfo.getUserId())){
            acc = Test_DataFactory.createOneLargeStandardAccount();
            insert acc;
            con = new Contact(LastName='TestLastName');
            con.Cygate_Sync__c = 1;
            con.AccountId = acc.Id;
            con.Product_Area__c = LeadTriggerHandler.LEAD_PRODAREA_UC;
            con.FirstName = 'TestFirstName';
            con.Phone = '+460345678';
            con.Email = 'test@dummmmy.com';
            con.Role__c = 'Annan';
            insert con;
        }
        //Create Test Campaign..
        testCamp1.Name = 'Testcamp11';
        testCamp1.Type = 'Telefone';
        testCamp1.Status = 'New';
        insert testCamp1;
        //Create Test Campaign..
        testCamp2.Name = 'Testcamp12';
        testCamp2.Type = 'Telefone';
        testCamp2.Status = 'New';
        insert testCamp2;
        testCamp2.Status = 'Completed';
        update testCamp2;
        //Create Test Campaign Member..
        testCampMem1.CampaignId = testCamp1.Id;
        testCampMem1.ContactId  = con.Id;
        insert testCampMem1;
        testCampMem2.CampaignId = testCamp2.id;
        testCampMem2.ContactId = con.id;
        insert testCampMem2;
        acc.Primary_Contact__c = con.Id;
        update acc;
        con.Deactivation_Date__c = system.today();
        update con;



    }
}