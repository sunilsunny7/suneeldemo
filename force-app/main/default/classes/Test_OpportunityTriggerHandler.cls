/**
 * Update History
 * --------------
 * Updated Jun 2017 - Case # 3410 - Email field is mandatory, thus when a Contact is created we need to add email Also, Role will be mandatory for all Customer Contact.
 * Case # 3094 - First Name is mandatory for all Customer Contact.
 * 21.09.2023 [Tomass Brazovskis] LTAT-7256 - Test methods added to verify the logic ensuring Wholesales Opportunities
 *             are being exempt from the existing automations.
 **/
@isTest
public with sharing class Test_OpportunityTriggerHandler {
    public static String SELLER_TYPE_SELLER = 'Seller';
    public static String SELLER_TYPE_SALES_TEAM_LEADER = 'Sales Team Manager';
    public static String SELLER_TYPE_SALES_UNIT_LEADER = 'Sales Unit Director';
    public static String SELLER_TYPE_BUSINESS_UNIT_MGR = 'Business Unit Manager';
    public static String SELLER_TYPE_BUSINESS_AREA_MGR = 'Business Area Manager';

    public static final Id OPPORTUNITY_RECORDTYPEID_WHOLESALES_OPPORTUNITY = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(SEConstantsOpportunity.OPPORTUNITY_RECORDTYPE_WHOLESALES_OPPORTUNITY)?.getRecordTypeId();

    public static testMethod void nr01_testSellerHierarchyOppRollUp() {
        System.debug('@@Test testSellerHierarchyOppRollUp Starts');
        Test_DataFactory.setUpOrg();

        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(smeSellerTeam);

            Test_DataFactory.createPriceBooks();
        }

        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];

        Seller__c smeManagerSeller = smeSellerTeam[0];
        Seller__c salesManagerSeller = smeSellerTeam[1];
        Seller__c salesRepSeller = smeSellerTeam[2];
        test.starttest();
        System.runAs(salesRep) {
            System.assertEquals(salesRepSeller.Manager__c, salesManagerSeller.Id);
            Opportunity opp = Test_DataFactory.createOpportunity();
            insert opp;

            Opportunity oppWithFOLs = [SELECT Id, Seller__c, (SELECT Id FROM Forecast_Opportunity_Links__r) FROM Opportunity WHERE Id = :opp.Id];
            System.assertEquals(salesRepSeller.Id, oppWithFOLs.Seller__c);
            //System.assertEquals(oppWithFOLs.Forecast_Opportunity_Links__r.size(), 3);
            System.debug(
                'testSellerHierarchyOppRollUp oppWithFOLs.Forecast_Opportunity_Links__r.size() size is: ' +
                    oppWithFOLs.Forecast_Opportunity_Links__r.size() +
                    '. It should be 3'
            );
        }

        System.runAs(salesManager) {
            Opportunity opp2 = Test_DataFactory.createOpportunity();
            insert opp2;

            Opportunity opp2WithFOLs = [SELECT Id, Seller__c, (SELECT Id FROM Forecast_Opportunity_Links__r) FROM Opportunity WHERE Id = :opp2.Id];
            System.assertEquals(salesManagerSeller.Id, opp2WithFOLs.Seller__c);
            //System.assertEquals(opp2WithFOLs.Forecast_Opportunity_Links__r.size(), 2);
            System.debug(
                'testSellerHierarchyOppRollUp opp2WithFOLs.Forecast_Opportunity_Links__r.size() size is: ' +
                    opp2WithFOLs.Forecast_Opportunity_Links__r.size() +
                    '. It should be 2'
            );
        }
        test.stoptest();
    }

    public static testMethod void nr02_testChangeOpportunityOwner() {
        System.debug('@@Test testSellerHierarchyOppRollUp Starts');
        Test_DataFactory.setUpOrg();

        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}
            smeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(smeSellerTeam);

            Test_DataFactory.createPriceBooks();
        }

        User smeManager = smeUserTeam[0];
        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];

        Seller__c smeManagerSeller = smeSellerTeam[0];
        Seller__c salesManagerSeller = smeSellerTeam[1];
        Seller__c salesRepSeller = smeSellerTeam[2];

        System.runAs(smeManager) {
            Test.startTest();
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.Owner = smeManager;
            try {
                insert opp;
            } catch (Exception e) {
                system.debug(e);
            }
            Opportunity oppWithFOLs = [SELECT Id, Seller__c, (SELECT Id FROM Forecast_Opportunity_Links__r) FROM Opportunity WHERE Id = :opp.Id];
            System.assertEquals(smeManagerSeller.Id, oppWithFOLs.Seller__c);
            //System.assertEquals(oppWithFOLs.Forecast_Opportunity_Links__r.size(), 1);
            System.debug(
                'testChangeOpportunityOwner oppWithFOLs.Forecast_Opportunity_Links__r.size() size is: ' +
                    oppWithFOLs.Forecast_Opportunity_Links__r.size() +
                    '. It should be 1'
            );

            opp.Seller__c = salesManagerSeller.Id;
            try {
                update opp;
            } catch (Exception e) {
                system.debug(e);
            }

            Opportunity opp2WithFOLs = [SELECT Id, OwnerId, Seller__c, (SELECT Id FROM Forecast_Opportunity_Links__r) FROM Opportunity WHERE Id = :opp.Id];
            System.assertEquals(salesManagerSeller.Id, opp2WithFOLs.Seller__c);
            //System.assertEquals(opp2WithFOLs.Forecast_Opportunity_Links__r.size(), 2);
            System.debug(
                'testChangeOpportunityOwner opp2WithFOLs.Forecast_Opportunity_Links__r.size() size is: ' +
                    opp2WithFOLs.Forecast_Opportunity_Links__r.size() +
                    '. It should be 2'
            );

            opp.Seller__c = salesRepSeller.Id;
            try {
                update opp;
            } catch (Exception e) {
                system.debug(e);
            }

            Opportunity opp3WithFOLs = [SELECT Id, Seller__c, (SELECT Id FROM Forecast_Opportunity_Links__r) FROM Opportunity WHERE Id = :opp.Id];
            System.assertEquals(salesRepSeller.Id, opp3WithFOLs.Seller__c);
            //System.assertEquals(opp3WithFOLs.Forecast_Opportunity_Links__r.size(), 3);
            System.debug(
                'testChangeOpportunityOwner opp3WithFOLs.Forecast_Opportunity_Links__r.size() size is: ' +
                    opp3WithFOLs.Forecast_Opportunity_Links__r.size() +
                    '. It should be 3'
            );
            Test.stopTest();
        }
    }

    public static testMethod void nr03_testChangeOpportunityCloseDate() {
        System.debug('@@Test testSellerHierarchyOppRollUp Starts');
        Test_DataFactory.setUpOrg();

        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(smeSellerTeam);

            Test_DataFactory.createPriceBooks();
        }

        User salesRep = smeUserTeam[2];

        System.runAs(salesRep) {
            Test.startTest();
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.CloseDate = System.today();
            String weekNumber = SEUtility.getWeekNumberAsString(opp.CloseDate);
            insert opp;
            Opportunity oppWithFOLs = [
                SELECT Id, Seller__c, (SELECT Id, Weekly_Forecast_Item__c, Weekly_Forecast_Item__r.Name FROM Forecast_Opportunity_Links__r)
                FROM Opportunity
                WHERE Id = :opp.Id
            ];
            /*System.assertEquals(oppWithFOLs.Forecast_Opportunity_Links__r.size(), 3);
System.assertEquals(oppWithFOLs.Forecast_Opportunity_Links__r[0].Weekly_Forecast_Item__r.Name, weekNumber);
System.assertEquals(oppWithFOLs.Forecast_Opportunity_Links__r[1].Weekly_Forecast_Item__r.Name, weekNumber);
System.assertEquals(oppWithFOLs.Forecast_Opportunity_Links__r[2].Weekly_Forecast_Item__r.Name, weekNumber);*/
            System.debug(
                'testChangeOpportunityCloseDate oppWithFOLs.Forecast_Opportunity_Links__r.size() size is: ' +
                    oppWithFOLs.Forecast_Opportunity_Links__r.size() +
                    '. It should be 3'
            );

            // Set new close date to two weeks into the future
            opp.CloseDate = System.today().addDays(14);
            String weekNumber2 = SEUtility.getWeekNumberAsString(opp.CloseDate);
            update opp;

            Opportunity opp2WithFOLs = [
                SELECT Id, Seller__c, (SELECT Id, Weekly_Forecast_Item__c, Weekly_Forecast_Item__r.Name FROM Forecast_Opportunity_Links__r)
                FROM Opportunity
                WHERE Id = :opp.Id
            ];
            /*System.assertEquals(opp2WithFOLs.Forecast_Opportunity_Links__r.size(), 3);
System.assertEquals(opp2WithFOLs.Forecast_Opportunity_Links__r[0].Weekly_Forecast_Item__r.Name, weekNumber2);
System.assertEquals(opp2WithFOLs.Forecast_Opportunity_Links__r[1].Weekly_Forecast_Item__r.Name, weekNumber2);
System.assertEquals(opp2WithFOLs.Forecast_Opportunity_Links__r[2].Weekly_Forecast_Item__r.Name, weekNumber2);*/
            System.debug(
                'testChangeOpportunityCloseDate opp2WithFOLs.Forecast_Opportunity_Links__r.size() size is: ' +
                    opp2WithFOLs.Forecast_Opportunity_Links__r.size() +
                    '. It should be 3'
            );
            Test.stopTest();
        }

    }

    public static testMethod void nr04_testTriggerFOLUpdate() {
        System.debug('@@Test testSellerHierarchyOppRollUp Starts');
        Test_DataFactory.setUpOrg();

        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(smeSellerTeam);

            Test_DataFactory.createPriceBooks();
        }

        User salesRep = smeUserTeam[2];

        System.runAs(salesRep) {
            Test.startTest();
            Opportunity opp = Test_DataFactory.createOpportunity();
            insert opp;
            Opportunity oppWithFOLs = [
                SELECT Id, Seller__c, (SELECT Id, New_Sales_Amount__c FROM Forecast_Opportunity_Links__r)
                FROM Opportunity
                WHERE Id = :opp.Id
            ];
            /*System.assertEquals(oppWithFOLs.Forecast_Opportunity_Links__r.size(), 3);
System.assertEquals(oppWithFOLs.Forecast_Opportunity_Links__r[0].New_Sales_Amount__c, null);
System.assertEquals(oppWithFOLs.Forecast_Opportunity_Links__r[1].New_Sales_Amount__c, null);
System.assertEquals(oppWithFOLs.Forecast_Opportunity_Links__r[2].New_Sales_Amount__c, null);*/
            System.debug(
                'testTriggerFOLUpdate oppWithFOLs.Forecast_Opportunity_Links__r.size() size is: ' +
                    oppWithFOLs.Forecast_Opportunity_Links__r.size() +
                    '. It should be 3'
            );

            // Set new close date to two weeks into the future
            Integer newAmount = 10000;
            opp.Large_New_Sales__c = newAmount;
            update opp;

            Opportunity opp2WithFOLs = [
                SELECT Id, OwnerId, Seller__c, (SELECT Id, New_Sales_Amount__c FROM Forecast_Opportunity_Links__r)
                FROM Opportunity
                WHERE Id = :opp.Id
            ];
            /*System.assertEquals(opp2WithFOLs.Forecast_Opportunity_Links__r.size(), 3);
System.assertEquals(opp2WithFOLs.Forecast_Opportunity_Links__r[0].New_Sales_Amount__c, newAmount);
System.assertEquals(opp2WithFOLs.Forecast_Opportunity_Links__r[1].New_Sales_Amount__c, newAmount);
System.assertEquals(opp2WithFOLs.Forecast_Opportunity_Links__r[2].New_Sales_Amount__c, newAmount);*/
            System.debug(
                'testTriggerFOLUpdate opp2WithFOLs.Forecast_Opportunity_Links__r.size() size is: ' +
                    opp2WithFOLs.Forecast_Opportunity_Links__r.size() +
                    '. It should be 3'
            );
            Test.stopTest();
        }
    }

    public static testMethod void nr05_testTriggerFOLUpdate2() {
        System.debug('@@Test testSellerHierarchyOppRollUp Starts');
        Test_DataFactory.setUpOrg();

        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(smeSellerTeam);

            Test_DataFactory.createPriceBooks();
        }

        User salesRep = smeUserTeam[2];

        System.runAs(salesRep) {
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.Risk__c = false;
            insert opp;

            Test.startTest();

            Opportunity oppWithFOLs = [SELECT Id, Seller__c, (SELECT Id, Risk__c FROM Forecast_Opportunity_Links__r) FROM Opportunity WHERE Id = :opp.Id];
            /*System.assertEquals(oppWithFOLs.Forecast_Opportunity_Links__r.size(), 3);
System.assertEquals(oppWithFOLs.Forecast_Opportunity_Links__r[0].Risk__c, false);
System.assertEquals(oppWithFOLs.Forecast_Opportunity_Links__r[1].Risk__c, false);
System.assertEquals(oppWithFOLs.Forecast_Opportunity_Links__r[2].Risk__c, false);*/
            System.debug(
                'testTriggerFOLUpdate2 oppWithFOLs.Forecast_Opportunity_Links__r.size() size is: ' +
                    oppWithFOLs.Forecast_Opportunity_Links__r.size() +
                    '. It should be 3'
            );

            opp.Risk__c = true;
            update opp;

            Opportunity opp2WithFOLs = [
                SELECT Id, OwnerId, Seller__c, (SELECT Id, Risk__c FROM Forecast_Opportunity_Links__r)
                FROM Opportunity
                WHERE Id = :opp.Id
            ];
            /*System.assertEquals(opp2WithFOLs.Forecast_Opportunity_Links__r.size(), 3);
System.assertEquals(opp2WithFOLs.Forecast_Opportunity_Links__r[0].Risk__c, true);
System.assertEquals(opp2WithFOLs.Forecast_Opportunity_Links__r[1].Risk__c, true);
System.assertEquals(opp2WithFOLs.Forecast_Opportunity_Links__r[2].Risk__c, true);*/
            System.debug(
                'testTriggerFOLUpdate2 opp2WithFOLs.Forecast_Opportunity_Links__r.size() size is: ' +
                    opp2WithFOLs.Forecast_Opportunity_Links__r.size() +
                    '. It should be 3'
            );
            Test.stopTest();
        }
    }

    public static testMethod void nr06_testNoYearlyTargetOnSeller() {
        System.debug('@@Test testSellerHierarchyOppRollUp Starts');
        Test_DataFactory.setUpOrg();

        User salesRep;
        Seller__c seller;

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            salesRep = Test_DataFactory.createSMEUser();
            insert salesRep;

            seller = Test_DataFactory.createSeller(salesRep.Id, null);
            insert seller;

            Test_DataFactory.createPriceBooks();
        }

        System.runAs(salesRep) {
            Test.startTest();
            Opportunity opp = Test_DataFactory.createOpportunity();
            insert opp;
            Opportunity oppWithFOLs = [SELECT Id, Seller__c, (SELECT Id, Risk__c FROM Forecast_Opportunity_Links__r) FROM Opportunity WHERE Id = :opp.Id];
            System.assertEquals(oppWithFOLs.Forecast_Opportunity_Links__r.size(), 0);

            Yearly_Target__c yt = Test_DataFactory.createOneYearlyTarget(seller);
            insert yt;
            opp.Large_New_Sales__c = 10000;
            update opp;

            Opportunity opp2WithFOLs = [
                SELECT Id, OwnerId, Seller__c, (SELECT Id, Risk__c FROM Forecast_Opportunity_Links__r)
                FROM Opportunity
                WHERE Id = :opp.Id
            ];
            System.assertNotEquals(opp2WithFOLs.Forecast_Opportunity_Links__r.size(), 0);
            Test.stopTest();
        }
    }

    public static testMethod void nr07_testTeliaWeek() {
        System.debug('@@Test testTeliaWeek Starts');

        Test_DataFactory.setUpOrg();
        User salesRep;
        Seller__c seller;

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            salesRep = Test_DataFactory.createSMEUser();
            insert salesRep;

            seller = Test_DataFactory.createSeller(salesRep.Id, null);
            seller.Start_Date__c = date.newInstance(2015, 1, 1);
            insert seller;

            Test_DataFactory.createPriceBooks();
        }

        System.runAs(salesRep) {
            Test.startTest();
            Opportunity opp = Test_DataFactory.createOpportunity();
            insert opp;

            Opportunity insertedOpp = [SELECT Telia_Week__c, CloseDate FROM Opportunity WHERE Id = :opp.Id];
            System.assertEquals(insertedOpp.Telia_Week__c, SEUtility.getWeekNumber(insertedOpp.CloseDate));

            opp.CloseDate = date.newInstance(2015, 1, 6);
            update opp;

            Opportunity updatedOpp = [SELECT Telia_Week__c, CloseDate FROM Opportunity WHERE Id = :opp.Id];
            System.assertEquals(updatedOpp.Telia_Week__c, SEUtility.getWeekNumber(updatedOpp.CloseDate));
            Test.stopTest();
        }
    }

    //Author : N.G (March 2016)- Updated Apr 2016
    public static testMethod void nr08_testdeleteOppConRole() {
        Test_DataFactory.setUpOrg();
        User salesRep;
        Seller__c seller;
        Account acc;

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            salesRep = Test_DataFactory.createSMEUser();
            insert salesRep;

            seller = Test_DataFactory.createSeller(salesRep.Id, null);
            seller.Start_Date__c = date.newInstance(2015, 1, 1);
            insert seller;

            Test_DataFactory.createPriceBooks();

            acc = new Account();
            acc.name = 'testAccount';
            Decimal orgNr = Decimal.valueOf(label.Account_Org_N) + 1;
            //acc.Org_Nr__c = label.Account_Org_N + '1';
            acc.Org_Nr__c = string.valueOf(orgNr);
            acc.OwnerId = salesRep.Id;
            insert acc;
        }

        System.runAs(salesRep) {
            Test.startTest();
            Opportunity opp = Test_DataFactory.createOpportunity();
            insert opp;

            //Contact objContact = new Contact(lastname = 'lastname',accountID = acc.id);
            Contact objContact = Test_DataFactory.createOneContact();
            objContact.accountID = acc.id;
            insert objContact;

            OpportunityContactRole ocr = new OpportunityContactRole(contactId = objContact.Id, OpportunityId = opp.Id);
            insert ocr;
            Opportunity updateOpp = [SELECT id, stagename FROM Opportunity WHERE Id = :opp.id];
            updateOpp.stagename = label.Opp_Sluta_Avtal_stage;
            update updateOpp;
            Test.stopTest();
        }
    }

    public static testMethod void nr09_testdeleteOppConRole1() {
        Test_DataFactory.setUpOrg();
        User salesRep;
        Seller__c seller;
        Account acc;

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            salesRep = Test_DataFactory.createSMEUser();
            insert salesRep;

            seller = Test_DataFactory.createSeller(salesRep.Id, null);
            seller.Start_Date__c = date.newInstance(2015, 1, 1);
            insert seller;

            acc = new Account();
            acc.name = 'testAccount';
            acc.OwnerId = salesRep.Id;
            //acc.Org_Nr__c = label.Account_Org_N + '2';
            Decimal orgNr = Decimal.valueOf(label.Account_Org_N) + 2;
            acc.Org_Nr__c = string.valueOf(orgNr);
            insert acc;

            Test_DataFactory.createPriceBooks();
        }

        System.runAs(salesRep) {
            Test.startTest();
            Opportunity opp = Test_DataFactory.createOpportunity();
            insert opp;

            //Contact objContact = new Contact(lastname = 'lastname',accountID = acc.id);
            Contact objContact = Test_DataFactory.createOneContact();
            objContact.accountID = acc.id;
            insert objContact;

            OpportunityContactRole ocr = new OpportunityContactRole(contactId = objContact.Id, OpportunityId = opp.Id);
            insert ocr;
            Opportunity updateOpp = [SELECT id, stagename FROM Opportunity WHERE Id = :opp.id];
            updateOpp.stagename = label.Opp_Avbruten_stage;
            update updateOpp;
            Test.stopTest();
        }
    }

    public static testMethod void nr10_testdeleteOppConRole2() {
        Test_DataFactory.setUpOrg();
        User salesRep;
        Seller__c seller;
        Account acc;

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            salesRep = Test_DataFactory.createSMEUser();
            insert salesRep;

            seller = Test_DataFactory.createSeller(salesRep.Id, null);
            seller.Start_Date__c = date.newInstance(2015, 1, 1);
            insert seller;

            acc = new Account();
            acc.name = 'testAccount';
            acc.OwnerId = salesRep.Id;
            //acc.Org_Nr__c = label.Account_Org_N + '3';
            Decimal orgNr = Decimal.valueOf(label.Account_Org_N) + 3;
            acc.Org_Nr__c = string.valueOf(orgNr);
            insert acc;

            Test_DataFactory.createPriceBooks();
        }

        System.runAs(salesRep) {
            Test.startTest();
            Opportunity opp = Test_DataFactory.createOpportunity();
            insert opp;

            //Contact objContact = new Contact(lastname = 'lastname',accountID = acc.id);
            Contact objContact = Test_DataFactory.createOneContact();
            objContact.accountID = acc.id;
            insert objContact;

            OpportunityContactRole ocr = new OpportunityContactRole(contactId = objContact.Id, OpportunityId = opp.Id);
            insert ocr;
            Opportunity updateOpp = [SELECT id, stagename FROM Opportunity WHERE Id = :opp.id];
            updateOpp.stagename = label.Opp_Forlorad_stage;
            update updateOpp;
            Test.stopTest();
        }
    }

    public static testMethod void nr11_testTeliaCygateOppAsLargeUser_NewSalesProducts() {
        Test_DataFactory.setUpOrg();

        List<User> largeUserTeam;
        List<Seller__c> largeSellerTeam;
        Account acc;
        User salesRep;

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of large users {SalesUnitManager, SalesTeamManager, Seller}
            largeUserTeam = Test_DataFactory.createLargeUserTeam(3);
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            largeSellerTeam = Test_DataFactory.createSmeSellerTeam(largeUserTeam);
            salesRep = largeUserTeam[2];

            acc = Test_DataFactory.createOneAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;

            Test_DataFactory.createPriceBooks();
        }

        System.runAs(salesRep) {
            Test.startTest();
            Opportunity opp = Test_DataFactory.createTeliaCygateOpportunity();
            opp.AccountId = acc.Id;
            insert opp;

            Opportunity oppAfterInsert = [
                SELECT Large_New_Sales__c, Large_Continuation_Sales__c, New_Sales__c, Continuation_Sales__c
                FROM Opportunity
                WHERE Id = :opp.Id
            ];
            System.assertEquals(oppAfterInsert.Large_New_Sales__c, 1, 'Large New Sales should be 1');
            System.assertEquals(oppAfterInsert.Large_Continuation_Sales__c, 0, 'Large Continuation Sales should be 0');
            System.assertEquals(oppAfterInsert.New_Sales__c, 1, '(Cygate) New Sales should be 1');
            System.assertEquals(oppAfterInsert.Continuation_Sales__c, 0, '(Cygate) Continuation Sales should be 0');

            List<OpportunityLineItem> olis = createProductaAndOpportunityLineItems(opp.Id, 1, 1);
            // inserting cygate product first
            olis[0].Sales_purpose__c = Test_DataFactory.OLI_SALES_PURPOSE_NEW_SALES;
            insert (olis[0]);

            Opportunity oppAfter1 = [
                SELECT Large_New_Sales__c, Large_Continuation_Sales__c, New_Sales__c, Continuation_Sales__c
                FROM Opportunity
                WHERE Id = :opp.Id
            ];
            System.assertEquals(oppAfter1.Large_New_Sales__c, 0, 'Large New Sales should be 0');
            System.assertEquals(oppAfter1.Large_Continuation_Sales__c, 0, 'Large Continuation Sales should be 0');
            System.assertEquals(oppAfter1.New_Sales__c, 480, '(Cygate) New Sales should be 480');
            System.assertEquals(oppAfter1.Continuation_Sales__c, 0, '(Cygate) Continuation Sales should be 0');

            // inserting telia product second
            olis[1].Sales_purpose__c = Test_DataFactory.OLI_SALES_PURPOSE_NEW_SALES;
            insert (olis[1]);

            Opportunity oppAfter2 = [
                SELECT Large_New_Sales__c, Large_Continuation_Sales__c, New_Sales__c, Continuation_Sales__c
                FROM Opportunity
                WHERE Id = :opp.Id
            ];
            System.assertEquals(oppAfter2.Large_New_Sales__c, 240, 'Large New Sales should be 240');
            System.assertEquals(oppAfter2.Large_Continuation_Sales__c, 0, 'Large Continuation Sales should be 0');
            System.assertEquals(oppAfter2.New_Sales__c, 480, '(Cygate) New Sales should be 480');
            System.assertEquals(oppAfter2.Continuation_Sales__c, 0, '(Cygate) Continuation Sales should be 0');

            Test.stopTest();
        }
    }

    public static testMethod void nr12_testTeliaCygateOppAsCygateUser_NewSalesProducts() {
        Test_DataFactory.setUpOrg();

        User cygateUser = Test_DataFactory.createCygateUser();
        Account acc;
        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;

            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            acc.OwnerId = cygateUser.Id;
            insert acc;

            Test_DataFactory.createPriceBooks();
        }

        System.runAs(cygateUser) {
            Test.startTest();
            Opportunity opp = Test_DataFactory.createTeliaCygateOpportunity();
            opp.AccountId = acc.Id;
            insert opp;

            Opportunity oppAfterInsert = [
                SELECT Large_New_Sales__c, Large_Continuation_Sales__c, New_Sales__c, Continuation_Sales__c
                FROM Opportunity
                WHERE Id = :opp.Id
            ];
            System.assertEquals(oppAfterInsert.Large_New_Sales__c, 1, 'Large New Sales should be 1');
            System.assertEquals(oppAfterInsert.Large_Continuation_Sales__c, 0, 'Large Continuation Sales should be 0');
            System.assertEquals(oppAfterInsert.New_Sales__c, 1, '(Cygate) New Sales should be 1');
            System.assertEquals(oppAfterInsert.Continuation_Sales__c, 0, '(Cygate) Continuation Sales should be 0');

            List<OpportunityLineItem> olis = createProductaAndOpportunityLineItems(opp.Id, 1, 1);
            // inserting cygate product first
            olis[0].Sales_Type_Cygate__c = Test_DataFactory.OLI_SALES_TYPE_NEW_SALES;
            insert (olis[0]);

            Opportunity oppAfter1 = [
                SELECT Large_New_Sales__c, Large_Continuation_Sales__c, New_Sales__c, Continuation_Sales__c
                FROM Opportunity
                WHERE Id = :opp.Id
            ];
            System.assertEquals(oppAfter1.Large_New_Sales__c, 0, 'Large New Sales should be 0');
            System.assertEquals(oppAfter1.Large_Continuation_Sales__c, 0, 'Large Continuation Sales should be 0');
            System.assertEquals(oppAfter1.New_Sales__c, 480, '(Cygate) New Sales should be 480');
            System.assertEquals(oppAfter1.Continuation_Sales__c, 0, '(Cygate) Continuation Sales should be 0');

            // inserting telia product second
            olis[1].Sales_Type_Cygate__c = Test_DataFactory.OLI_SALES_TYPE_NEW_SALES;
            insert (olis[1]);

            Opportunity oppAfter2 = [
                SELECT Large_New_Sales__c, Large_Continuation_Sales__c, New_Sales__c, Continuation_Sales__c
                FROM Opportunity
                WHERE Id = :opp.Id
            ];
            System.assertEquals(oppAfter2.Large_New_Sales__c, 240, 'Large New Sales should be 240');
            System.assertEquals(oppAfter2.Large_Continuation_Sales__c, 0, 'Large Continuation Sales should be 0');
            System.assertEquals(oppAfter2.New_Sales__c, 480, '(Cygate) New Sales should be 480');
            System.assertEquals(oppAfter2.Continuation_Sales__c, 0, '(Cygate) Continuation Sales should be 0');

            Test.stopTest();
        }
    }

    public static testMethod void nr13_testTeliaCygateOppAsLargeUser_ContSalesProducts() {
        Test_DataFactory.setUpOrg();

        List<User> largeUserTeam;
        List<Seller__c> largeSellerTeam;
        Account acc;
        User salesRep;
        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of large users {SalesUnitManager, SalesTeamManager, Seller}
            largeUserTeam = Test_DataFactory.createLargeUserTeam(3);
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            largeSellerTeam = Test_DataFactory.createSmeSellerTeam(largeUserTeam);
            salesRep = largeUserTeam[2];

            acc = Test_DataFactory.createOneAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;

            Test_DataFactory.createPriceBooks();
        }

        System.runAs(salesRep) {
            Test.startTest();
            Opportunity opp = Test_DataFactory.createTeliaCygateOpportunity();
            opp.AccountId = acc.Id;
            opp.Large_New_Sales__c = 0;
            opp.Large_Continuation_Sales__c = 1;
            opp.New_Sales__c = 0;
            opp.Continuation_Sales__c = 1;
            insert opp;

            Opportunity oppAfterInsert = [
                SELECT Large_New_Sales__c, Large_Continuation_Sales__c, New_Sales__c, Continuation_Sales__c
                FROM Opportunity
                WHERE Id = :opp.Id
            ];
            System.assertEquals(oppAfterInsert.Large_New_Sales__c, 0, 'Large New Sales should be 0');
            System.assertEquals(oppAfterInsert.Large_Continuation_Sales__c, 1, 'Large Continuation Sales should be 1');
            System.assertEquals(oppAfterInsert.New_Sales__c, 0, '(Cygate) New Sales should be 0');
            System.assertEquals(oppAfterInsert.Continuation_Sales__c, 1, '(Cygate) Continuation Sales should be 1');

            List<OpportunityLineItem> olis = createProductaAndOpportunityLineItems(opp.Id, 1, 1);
            // inserting telia product first
            olis[1].Sales_purpose__c = Test_DataFactory.OLI_SALES_PURPOSE_CONT_SALES;
            insert (olis[1]);

            Opportunity oppAfter1 = [
                SELECT Large_New_Sales__c, Large_Continuation_Sales__c, New_Sales__c, Continuation_Sales__c
                FROM Opportunity
                WHERE Id = :opp.Id
            ];
            System.assertEquals(oppAfter1.Large_New_Sales__c, 0, 'Large New Sales should be 0');
            System.assertEquals(oppAfter1.Large_Continuation_Sales__c, 240, 'Large Continuation Sales should be 240');
            System.assertEquals(oppAfter1.New_Sales__c, 0, '(Cygate) New Sales should be 0');
            System.assertEquals(oppAfter1.Continuation_Sales__c, 1, '(Cygate) Continuation Sales should be 0');

            // inserting cygate product second
            olis[0].Sales_purpose__c = Test_DataFactory.OLI_SALES_PURPOSE_CONT_SALES;
            insert (olis[0]);

            Opportunity oppAfter2 = [
                SELECT Large_New_Sales__c, Large_Continuation_Sales__c, New_Sales__c, Continuation_Sales__c
                FROM Opportunity
                WHERE Id = :opp.Id
            ];
            System.assertEquals(oppAfter1.Large_New_Sales__c, 0, 'Large New Sales should be 0');
            System.assertEquals(oppAfter2.Large_Continuation_Sales__c, 240, 'Large Continuation Sales should be 240');
            System.assertEquals(oppAfter2.New_Sales__c, 0, '(Cygate) New Sales should be 0');
            System.assertEquals(oppAfter2.Continuation_Sales__c, 480, '(Cygate) Continuation Sales should be 480');

            Test.stopTest();
        }
    }

    public static testMethod void nr14_testTeliaCygateOppAsCygateUser_ContSalesProducts() {
        Test_DataFactory.setUpOrg();

        User cygateUser = Test_DataFactory.createCygateUser();
        Account acc;
        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            Test_DataFactory.createPriceBooks();
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            acc.OwnerId = cygateUser.Id;
            insert acc;
        }

        System.runAs(cygateUser) {
            Test.startTest();
            Opportunity opp = Test_DataFactory.createTeliaCygateOpportunity();
            opp.AccountId = acc.Id;
            opp.Large_New_Sales__c = 0;
            opp.Large_Continuation_Sales__c = 1;
            opp.New_Sales__c = 0;
            opp.Continuation_Sales__c = 1;
            insert opp;

            Opportunity oppAfterInsert = [
                SELECT Large_New_Sales__c, Large_Continuation_Sales__c, New_Sales__c, Continuation_Sales__c
                FROM Opportunity
                WHERE Id = :opp.Id
            ];
            System.assertEquals(oppAfterInsert.Large_New_Sales__c, 0, 'Large New Sales should be 0');
            System.assertEquals(oppAfterInsert.Large_Continuation_Sales__c, 1, 'Large Continuation Sales should be 1');
            System.assertEquals(oppAfterInsert.New_Sales__c, 0, '(Cygate) New Sales should be 0');
            System.assertEquals(oppAfterInsert.Continuation_Sales__c, 1, '(Cygate) Continuation Sales should be 1');

            List<OpportunityLineItem> olis = createProductaAndOpportunityLineItems(opp.Id, 1, 1);
            // inserting telia product first
            olis[1].Sales_purpose__c = Test_DataFactory.OLI_SALES_TYPE_CONT_SALES;
            insert (olis[1]);

            Opportunity oppAfter1 = [
                SELECT Large_New_Sales__c, Large_Continuation_Sales__c, New_Sales__c, Continuation_Sales__c
                FROM Opportunity
                WHERE Id = :opp.Id
            ];
            System.assertEquals(oppAfter1.Large_New_Sales__c, 0, 'Large New Sales should be 0');
            System.assertEquals(oppAfter1.Large_Continuation_Sales__c, 240, 'Large Continuation Sales should be 240');
            System.assertEquals(oppAfter1.New_Sales__c, 0, '(Cygate) New Sales should be 0');
            System.assertEquals(oppAfter1.Continuation_Sales__c, 1, '(Cygate) Continuation Sales should be 0');

            // inserting cygate product second
            olis[0].Sales_purpose__c = Test_DataFactory.OLI_SALES_TYPE_CONT_SALES;
            insert (olis[0]);

            Opportunity oppAfter2 = [
                SELECT Large_New_Sales__c, Large_Continuation_Sales__c, New_Sales__c, Continuation_Sales__c
                FROM Opportunity
                WHERE Id = :opp.Id
            ];
            System.assertEquals(oppAfter1.Large_New_Sales__c, 0, 'Large New Sales should be 0');
            System.assertEquals(oppAfter2.Large_Continuation_Sales__c, 240, 'Large Continuation Sales should be 240');
            System.assertEquals(oppAfter2.New_Sales__c, 0, '(Cygate) New Sales should be 0');
            System.assertEquals(oppAfter2.Continuation_Sales__c, 480, '(Cygate) Continuation Sales should be 480');

            Test.stopTest();
        }
    }

    private static List<OpportunityLineItem> createProductaAndOpportunityLineItems(Id oppId, Integer noOfCygateProducts, Integer noOfNonCygateProducts) {
        List<Product2> prodList = Test_DataFactory.createProducts(noOfCygateProducts + noOfNonCygateProducts);

        Integer count = 0;
        for (Product2 p : prodList) {
            if (count < noOfCygateProducts) {
                p.Family = 'Cygate Product Family';
                p.ProductCode = 'CG';
            }
            count++;
        }
        insert prodList;

        Id pbStandardId = Test.getStandardPricebookId();
        List<PriceBookEntry> pbeStandardList = new List<PriceBookEntry>();
        for (Product2 p : prodList) {
            pbeStandardList.add(Test_DataFactory.createPricebookEntry(pbStandardId, p));
        }
        insert pbeStandardList;

        List<PriceBookEntry> pbeStandardList1 = new List<PriceBookEntry>();
        for (Product2 p : prodList) {
            pbeStandardList.add(Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, p));
        }
        insert pbeStandardList1;

        Id pbId = [SELECT Pricebook2Id FROM Opportunity WHERE Id = :oppId].Pricebook2Id;
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        for (Product2 p : prodList) {
            pbeList.add(Test_DataFactory.createPricebookEntry(pbId, p));
        }
        insert pbeList;

        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        for (PriceBookEntry pbe : pbeList) {
            olis.add(Test_DataFactory.createOpportunityLineItem(oppId, pbe.Id));
        }
        return olis;
    }
    public static testMethod void nr15_testSMEAccOnlySMERecTypNegative() {
        Test.startTest();
        User cygateUser = Test_DataFactory.createCygateUser();
        Account acc;
        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            string accRecTypeID = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc = Test_DataFactory.createOneAccount();
            acc.recordtypeID = accRecTypeID;
            acc.OwnerId = cygateUser.Id;

            Test_DataFactory.createPriceBooks();
        }

        System.runAs(cygateUser) {
            Opportunity opp = Test_DataFactory.createProspect();
            opp.accountID = acc.id;
            opp.new_sales__c = 56;
            opp.Kammarkollegiet__c = 'Kammarkollegiet';
            insert opp;
        }
        Test.stopTest();
    }
    public static testMethod void nr16_testSMEAccOnlySMERecTypPositive() {
        Test.startTest();
        Test_DataFactory.setUpOrg();
        User salesRep;
        Seller__c seller;
        Account acc;
        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            salesRep = Test_DataFactory.createSMEUser();
            insert salesRep;

            seller = Test_DataFactory.createSeller(salesRep.Id, null);
            seller.Start_Date__c = date.newInstance(2015, 1, 1);
            insert seller;

            string accRecTypeID = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc = Test_DataFactory.createOneAccount();
            acc.OwnerId = salesRep.Id;
            acc.recordtypeID = accRecTypeID;
            insert acc;

            Test_DataFactory.createPriceBooks();
        }

        System.runAs(salesRep) {
            Opportunity opp = Test_DataFactory.createLargeOpportunity();
            opp.large_new_sales__c = 56;
            opp.accountID = acc.id;
            try {
                insert opp;
            } catch (exception e) {
                system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, På ett SME-konto kan man inta skapa Large affärsmöjligheter.'));
            }
        }
        Test.stopTest();
    }

    public static testMethod void nr17_testPricebookSMEopp() {
        Test_DataFactory.setUpOrg();
        Opportunity opp;
        User salesRep;
        Seller__c seller;
        Account acc;
        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            salesRep = Test_DataFactory.createSMEUser();
            insert salesRep;

            seller = Test_DataFactory.createSeller(salesRep.Id, null);
            seller.Start_Date__c = date.newInstance(2015, 1, 1);
            insert seller;
            string accRecTypeID = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc = Test_DataFactory.createOneAccount();
            acc.OwnerId = salesRep.Id;
            acc.recordtypeID = accRecTypeID;
            insert acc;

            Test_DataFactory.createPriceBooks();
        }

        Test.startTest();
        System.runAs(salesRep) {
            opp = Test_DataFactory.createOpportunity();
            opp.Large_New_Sales__c = 100;
            opp.AccountID = acc.id;
            insert opp;
        }
        Test.stopTest();

        Opportunity oppAfterInsert = [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertNotEquals(oppAfterInsert.Pricebook2Id, null);
        System.assertEquals(oppAfterInsert.Pricebook2Id, SEUtility.getPriceBookId(SEUtility.PRICEBOOK_TELIA_NEW), 'Telia PB should be set for SME opps');
    }

    public static testMethod void nr18_testPricebookLargeOpp() {
        Test_DataFactory.setUpOrg();
        Opportunity opp;
        User salesRep;
        Seller__c seller;
        Account acc;

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            salesRep = Test_DataFactory.createLargeUser();
            insert salesRep;

            seller = Test_DataFactory.createSeller(salesRep.Id, null);
            seller.Start_Date__c = date.newInstance(2015, 1, 1);
            insert seller;

            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;

            Test_DataFactory.createPriceBooks();
        }

        Test.startTest();
        System.runAs(salesRep) {
            opp = Test_DataFactory.createLargeOpportunity();
            opp.Large_New_Sales__c = 100;
            opp.AccountID = acc.id;
            insert opp;
        }
        Test.stopTest();

        Opportunity oppAfterInsert = [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertNotEquals(oppAfterInsert.Pricebook2Id, null);
        System.assertEquals(oppAfterInsert.Pricebook2Id, SEUtility.getPriceBookId(SEUtility.PRICEBOOK_TELIA_NEW), 'Telia PB should be set for Large opps');
    }

    public static testMethod void nr19_testPricebookCygateOpp() {
        Test_DataFactory.setUpOrg();
        User cygateUser = Test_DataFactory.createCygateUser();
        Opportunity opp;
        Account acc;

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            acc.OwnerId = cygateUser.Id;
            insert acc;

            Test_DataFactory.createPriceBooks();
        }

        System.runAs(cygateUser) {
            Test.startTest();
            opp = Test_DataFactory.createCygateOpportunity();
            opp.AccountId = acc.Id;
            opp.Large_New_Sales__c = 0;
            opp.Large_Continuation_Sales__c = 1;
            opp.New_Sales__c = 0;
            opp.Continuation_Sales__c = 1;
            opp.Kammarkollegiet__c = 'Kammarkollegiet';
            insert opp;
            Test.stopTest();
        }
        Opportunity oppAfterInsert = [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertNotEquals(oppAfterInsert.Pricebook2Id, null);
        System.assertEquals(oppAfterInsert.Pricebook2Id, SEUtility.getPriceBookId(SEUtility.PRICEBOOK_CYGATE), 'Cygate PB should be set for Cygate opps');
    }

    public static testMethod void nr20_testPricebookTeliaCygateOpp_AsCygateUser() {
        Test_DataFactory.setUpOrg();
        Opportunity opp;
        Account acc;
        User cygateUser = Test_DataFactory.createCygateUser();

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            acc.OwnerId = cygateUser.Id;
            insert acc;

            Test_DataFactory.createPriceBooks();
        }

        System.runAs(cygateUser) {
            Test.startTest();
            opp = Test_DataFactory.createTeliaCygateOpportunity();
            opp.AccountId = acc.Id;
            opp.Large_New_Sales__c = 0;
            opp.Large_Continuation_Sales__c = 1;
            opp.New_Sales__c = 0;
            opp.Continuation_Sales__c = 1;
            insert opp;
            Test.stopTest();
        }

        Opportunity oppAfterInsert = [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertNotEquals(oppAfterInsert.Pricebook2Id, null);
        System.assertEquals(
            oppAfterInsert.Pricebook2Id,
            SEUtility.getPriceBookId(SEUtility.PRICEBOOK_JOINT),
            'Telia Cygate PB should be set for Telia-Cygate opps'
        );
    }

    public static testMethod void nr21_testPricebookTeliaCygateOpp_AsLargeUser() {
        Test_DataFactory.setUpOrg();
        List<User> largeUserTeam;
        List<Seller__c> largeSellerTeam;
        Opportunity opp;
        Account acc;
        User salesRep;
        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of large users {SalesUnitManager, SalesTeamManager, Seller}
            largeUserTeam = Test_DataFactory.createLargeUserTeam(3);
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            largeSellerTeam = Test_DataFactory.createSmeSellerTeam(largeUserTeam);
            salesRep = largeUserTeam[2];
            acc = Test_DataFactory.createOneAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;

            Test_DataFactory.createPriceBooks();
        }

        System.runAs(salesRep) {
            Test.startTest();
            opp = Test_DataFactory.createTeliaCygateOpportunity();
            opp.AccountId = acc.Id;
            opp.Large_New_Sales__c = 0;
            opp.Large_Continuation_Sales__c = 1;
            opp.New_Sales__c = 0;
            opp.Continuation_Sales__c = 1;
            insert opp;
            Test.stopTest();
        }

        Opportunity oppAfterInsert = [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertNotEquals(oppAfterInsert.Pricebook2Id, null);
        System.assertEquals(
            oppAfterInsert.Pricebook2Id,
            SEUtility.getPriceBookId(SEUtility.PRICEBOOK_JOINT),
            'Telia Cygate PB should be set for Telia-Cygate opps'
        );
    }

    public static testMethod void nr22_testPricebookProspectOpp_AsCygateUser() {
        Test_DataFactory.setUpOrg();
        Opportunity opp;
        Account acc;
        User cygateUser = Test_DataFactory.createCygateUser();

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            acc.OwnerId = cygateUser.Id;
            insert acc;
            Test_DataFactory.createPriceBooks();
        }

        System.runAs(cygateUser) {
            Test.startTest();
            opp = Test_DataFactory.createProspect();
            opp.AccountId = acc.Id;
            opp.Large_New_Sales__c = 0;
            opp.Large_Continuation_Sales__c = 1;
            opp.New_Sales__c = 0;
            opp.Continuation_Sales__c = 1;
            opp.Kammarkollegiet__c = 'Kammarkollegiet';
            insert opp;
            Test.stopTest();
        }

        Opportunity oppAfterInsert = [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertNotEquals(oppAfterInsert.Pricebook2Id, null);
        System.assertEquals(
            oppAfterInsert.Pricebook2Id,
            SEUtility.getPriceBookId(SEUtility.PRICEBOOK_CYGATE),
            'Cygate PB should be set for Prospect opps created by Cygate users'
        );
    }

    public static testMethod void nr23_testPricebookProspectOpp_AsLargeUser() {
        Test_DataFactory.setUpOrg();
        List<User> largeUserTeam;
        List<Seller__c> largeSellerTeam;
        Opportunity opp;
        Account acc;
        User salesRep;
        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of large users {SalesUnitManager, SalesTeamManager, Seller}
            largeUserTeam = Test_DataFactory.createLargeUserTeam(3);
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            largeSellerTeam = Test_DataFactory.createSmeSellerTeam(largeUserTeam);
            salesRep = largeUserTeam[2];
            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
            Test_DataFactory.createPriceBooks();
        }

        System.runAs(salesRep) {
            Test.startTest();
            opp = Test_DataFactory.createProspect();
            opp.AccountId = acc.Id;
            opp.Large_New_Sales__c = 0;
            opp.Large_Continuation_Sales__c = 1;
            opp.New_Sales__c = 0;
            opp.Continuation_Sales__c = 1;
            insert opp;
            Test.stopTest();
        }

        Opportunity oppAfterInsert = [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertNotEquals(oppAfterInsert.Pricebook2Id, null);
        System.assertEquals(
            oppAfterInsert.Pricebook2Id,
            SEUtility.getPriceBookId(SEUtility.PRICEBOOK_TELIA_NEW),
            'Telia PB should be set for Prospect opps created by Large users'
        );
    }

    //    public static testmethod void nr26_testCygateOwner(){
    //        System.debug('@@Test testCygateOwner Starts');
    //
    //        Test_DataFactory.setUpOrg();
    //        User salesRep;
    //        User cygateUser;
    //        Seller__c seller;
    //
    //        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
    //            salesRep = Test_DataFactory.createAdminUser();
    //            insert salesRep;
    //            seller = Test_DataFactory.createSeller(salesRep.Id, null);
    //            seller.Start_Date__c = date.newInstance(2015, 1, 1);
    //            insert seller;
    //            Test_DataFactory.createPriceBooks();
    //        }
    //
    //        System.runAs(salesRep){
    //            Test.startTest();
    //            cygateUser = Test_DataFactory.createCygateChefUser();
    //            insert cygateUser;
    //
    //            Opportunity opp = Test_DataFactory.createCygateOpportunity();
    //            opp.New_Sales__c = 0;
    //            opp.Continuation_Sales__c = 1;
    //            insert opp;
    //
    //            //opp.Cygate_Owner__c=cygateUser.Id;
    //            //update opp;
    //
    //            Opportunity updatedOpp = [SELECT OwnerId FROM Opportunity WHERE Id =: opp.Id];
    //
    //            System.assertEquals(updatedOpp.OwnerId, cygateUser.Id);
    //
    //            //System.assertEquals(updatedOpp.Cygate_Owner__c, null);
    //            Test.stopTest();
    //
    //        }
    //    }

    public static testMethod void nr27_renewalOwnerChangeAccess() {
        //To avoid MIXED_DML issue
        User uR1 = new User();
        User uR2 = new User();
        User uL1 = new User();
        User uC1 = new User();
        User uC2 = new User();
        string roleuC2 = '';
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp1 = new Opportunity();
        Opportunity opp2 = new Opportunity();
        Opportunity oppCy = new Opportunity();

        Account acc = new Account();

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).

            List<User> renewalUserList = Test_DataFactory.createLargeRenewalUserTeam(2);
            uR1 = renewalUserList[0];
            uR2 = renewalUserList[1];
            List<user> largeUserList = Test_DataFactory.createLargeUserTeam(1);
            uL1 = largeUserList[0];
            uC1 = Test_DataFactory.createCygateUser();
            uC2 = Test_DataFactory.createCygateSalesSupportChef();
            insert uC1;
            insert uC2;
            roleuC2 = uC2.UserRoleId;

            insert new Cygate_Manager_Roles__c(name = 'Cygate Manager Role', Role_ID__c = roleuC2, Role_Name__c = 'CG_Sales_Support_Norr');

            User salesRep;
            Seller__c seller;
            salesRep = Test_DataFactory.createLargeUser();
            insert salesRep;
            seller = Test_DataFactory.createSeller(salesRep.Id, null);
            seller.Start_Date__c = date.newInstance(2015, 1, 1);
            insert seller;

            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
            acc.Org_Nr__c = '1234567890';
            acc.Cygate_Account_Manager__c = uC1.Id;
            update acc;
        }
        test.starttest();

        opp1 = Test_DataFactory.createLargeOpportunity();
        opp1.large_new_sales__c = 56;
        opp1.accountID = acc.id;
        opp1.OwnerId = uR1.Id;
        opp1.Change_Owner_To__c = null;
        insert opp1;
        oppCy = Test_DataFactory.createCygateOpportunity();
        oppCy.OwnerId = uC2.Id;
        oppCy.AccountId = acc.Id;
        oppCy.Large_New_Sales__c = 0;
        oppCy.Large_Continuation_Sales__c = 1;
        oppCy.New_Sales__c = 0;
        oppCy.Continuation_Sales__c = 1;
        oppCy.Kammarkollegiet__c = 'Kammarkollegiet';
        insert oppCy;

        opp1.Change_Owner_To__c = uR2.id;
        try {
            update opp1;
        } catch (exception e) {
            system.debug(e);
        }

        opp1.Change_Owner_To__c = uL1.Id;
        try {
            update opp1;
        } catch (exception e) {
            system.debug(e);
        }

        test.stoptest();
        opp1.Change_Owner_To__c = uR2.id;
        try {
            update opp1;
        } catch (exception e) {
            system.debug(e);
        }

        opp1.Change_Owner_To__c = uL1.Id;
        try {
            update opp1;
        } catch (exception e) {
            system.debug(e);
        }

        //for cygate part of owner change
        oppCy.Change_Owner_To__c = uC1.Id;
    }

    public static testMethod void nr28_renewalOwnerChangeAccess() {
        //To avoid MIXED_DML issue
        User uR1 = new User();
        User uR2 = new User();
        User uL1 = new User();
        User uC1 = new User();
        User uC2 = new User();
        string roleuC2 = '';

        Opportunity opp1 = new Opportunity();
        Opportunity opp2 = new Opportunity();
        Opportunity oppCy = new Opportunity();
        Account acc = new Account();

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            List<User> renewalUserList = Test_DataFactory.createLargeRenewalUserTeam(2);
            uR1 = renewalUserList[0];
            uR2 = renewalUserList[1];
            List<user> largeUserList = Test_DataFactory.createLargeUserTeam(1);
            uL1 = largeUserList[0];
            uC1 = Test_DataFactory.createCygateUser();
            uC2 = Test_DataFactory.createCygateSalesSupportChef();
            insert uC1;
            insert uC2;
            roleuC2 = uC2.UserRoleId;

            insert new Cygate_Manager_Roles__c(name = 'Cygate Manager Role', Role_ID__c = roleuC2, Role_Name__c = 'CG_Sales_Support_Norr');

            List<Opportunity> oppList = new List<Opportunity>();

            User salesRep;
            Seller__c seller;
            salesRep = Test_DataFactory.createLargeUser();
            insert salesRep;
            seller = Test_DataFactory.createSeller(salesRep.Id, null);
            seller.Start_Date__c = date.newInstance(2015, 1, 1);
            insert seller;

            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
            acc.Org_Nr__c = '1234567890';
            acc.Cygate_Account_Manager__c = uC1.Id;
            update acc;

            opp2 = Test_DataFactory.createLargeOpportunity();
            opp2.large_new_sales__c = 56;
            opp2.accountID = acc.id;
            opp2.OwnerId = uL1.Id;
            opp2.Change_Owner_To__c = null;
        }

        test.starttest();
        insert opp2;

        opp2.Change_Owner_To__c = uR1.Id;
        try {
            update opp2;
        } catch (exception e) {
            system.debug(e);
        }

        opp2.Change_Owner_To__c = uR1.Id;
        try {
            update opp2;
        } catch (exception e) {
            system.debug(e);
        }

        //for cygate part of owner change
        //oppCy.Change_Owner_To__c = uC1.Id;
        test.stoptest();
    }
    public static testMethod void RecursionHandlertestMethod() {
        boolean firstAfterRun = RecursionHandler.firstAfterRun();
        system.assertEquals(false, firstAfterRun);
        RecursionHandler.finishFirstAfterRun();
        boolean secondBeforeRun = RecursionHandler.secondBeforeRun();
        system.assertEquals(true, secondBeforeRun);
        RecursionHandler.finishSecondBeforeRun();
    }
    public static testMethod void OpportunityValidationtestmethod() {
        /*   Account Acc = new Account();
// Acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
Acc.RecordTypeId  = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
Acc.Name = 'AccTest';
insert acc;

Opportunity opp = Test_DataFactory.createOpportunity();
opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
opp.accountid = acc.id;
insert opp;

Contact objContact = new Contact(lastname = 'lastname',accountID = acc.id);
insert objContact;

OpportunityContactRole ocr = new OpportunityContactRole(contactId = objContact.Id, OpportunityId = opp.Id,role='test');
insert ocr;
OpportunityValidationHandler.validateInsert(new List<Opportunity>{opp});
Opportunity opp1 = Test_DataFactory.createOpportunity();
opp1.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
opp1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PROSPECT);
opp1.accountid = acc.id;
OpportunityValidationHandler.validateNoLargeOppsOnSmeAccs(new List<Opportunity>{opp1});
// OpportunityValidationHandler.checkBestellareCriteria(opp);
// OpportunityValidationHandler.checkContactRolesSME(opp);
OpportunityValidationHandler.checkContactRolesLarge(opp,true,true,true);
OpportunityValidationHandler.hasContactRole(opp,'test');  */

        Test.startTest();
        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            Account acc = new Account();
            acc.Name = 'testAccount';
            //acc.OwnerId = salesRep.Id;
            //acc.Org_Nr__c = label.Account_Org_N + '2';
            Decimal orgNr = Decimal.valueOf(label.Account_Org_N) + 2;
            acc.Org_Nr__c = string.valueOf(orgNr);
            insert acc;

            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.stagename = 'Utveckla';
            opp.accountid = acc.id;
            insert opp;
            List<Opportunity> newList = new List<Opportunity>{ opp };
            OpportunityValidationHandler.validateInsert(newList);
            Opportunity updateOpp = [SELECT id, stagename FROM Opportunity WHERE Id = :opp.id];
            updateOpp.stagename = label.Opp_Sluta_Avtal_stage;
            update updateOpp;

            //Contact objContact = new Contact(lastname = 'lastname',accountID = acc.id);
            Contact objContact = Test_DataFactory.createOneContact();
            objContact.accountID = acc.id;
            insert objContact;

            OpportunityContactRole ocr = new OpportunityContactRole(contactId = objContact.Id, OpportunityId = opp.Id);
            insert ocr;

            // List<Opportunity> newList = new List<Opportunity>{opp};
            Map<ID, Opportunity> oldMap = new Map<ID, Opportunity>();
            oldMap.put(updateOpp.id, updateOpp);
            OpportunityValidationHandler.validateInsert(new List<Opportunity>{ opp });
            // OpportunityValidationHandler.checkContactRolesSME(opp);
            OpportunityValidationHandler.filterOppsWithNewStage(newList, oldMap);
            OpportunityValidationHandler.checkBestellareCriteria(opp);
            OpportunityValidationHandler.checkContactRolesLarge(opp, true, true, true);
            Test.stopTest();
        }
    }

    /*@istest public  static void AaparentopptestMethod(){

        //test.starttest();
        User salesRep ;
        Seller__c seller;*/
    /*system.runas(new user(id=userinfo.getuserid())){
        salesRep = Test_DataFactory.createLargeUser();
        insert salesRep;
    }*/
    /*Account Acc = new Account();
    Acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
    Acc.Name = 'AccTest';
    acc.OwnerId = salesRep.Id;
    //insert acc;
    Seller__c saleslist = new Seller__c();
    saleslist.User__c = salesRep.Id;
    saleslist.Start_Date__c = system.today() ;
    saleslist.End_Date__c = system.today() + 30;
    //insert saleslist;*/
    /*Opportunity opp = Test_DataFactory.createOpportunity();
    opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
    opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
    opp.accountid = acc.id;
 //   opp.Kammarkollegiet__c = 'Kammarkollegiet';
    insert opp;
    Opportunity ProsOpp = Test_DataFactory.createOpportunity();
    ProsOpp.StageName = OpportunityValidationHandler.OPP_STAGE_ACTIVE_PROSPECT;
    ProsOpp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PROSPECT);
    ProsOpp.Parent_Frame_Opportunity__c = opp.id;
    ProsOpp.accountid = acc.id;
    ProsOpp.Large_New_Sales__c =1;
    ProsOpp.Large_Continuation_Sales__c=1;
    insert ProsOpp;
    Delete ProsOpp;*/
    //test.stoptest();

    /* /**/

    //User salesRep ;
    //Seller__c seller;
    /*
system.runas(new user(id=userinfo.getuserid())){
salesRep = Test_DataFactory.createLargeUser();
insert salesRep;
}
seller = Test_DataFactory.createSeller(salesRep.Id, null);
seller.Start_Date__c = date.newInstance(2015, 1, 1);
insert seller;

Account Acc1 = new Account();
Acc1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
Acc1.Name = 'AccTest';
acc1.OwnerId = salesRep.Id;
insert acc1;

Opportunity opp1 = Test_DataFactory.createOpportunity();
opp1.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
opp1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
opp1.accountid = acc1.id;


insert opp1;

test.starttest();// group 2
Opportunity MfOpp = new Opportunity();
MfOpp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_MERFORSALJNINGSMOJLIGHET);
MfOpp.Accountid = Acc1.Id;
MfOpp.Name ='MFOpp';
MfOpp.Large_New_Sales__c = 3;
MfOpp.Large_Continuation_Sales__c = 3;
MfOpp.CloseDate = System.Today();
MfOpp.StageName = 'Open';
MfOpp.Send_to_Volume_Sales__c = false;
MfOpp.Frame_Opportunity__c = opp1.id;
insert MfOpp;
//test.starttest(); commented on 29th aug group 1
Upsell_Target_Account__c UTA = new Upsell_Target_Account__c();
UTA.Account__c = Acc1.Id;
UTA.Opportunity__c = MfOpp.Id;
UTA.Exclude_Account__c=false;
insert UTA;

Contact objContact = Test_DataFactory.createOneContact();
objContact.accountID = acc1.id;
insert objContact;
test.stoptest(); // group 2

OpportunityContactRole ocr = new OpportunityContactRole(contactId = objContact.Id, OpportunityId = opp1.Id,Role=OpportunityValidationHandler.OPP_CR_AVTALSTECKNARE);
insert ocr;

system.runas(Test_DataFactory.getByPassUser()){
opportunity opp2 = [select id,name from opportunity where id=:opp1.id];
Opp2.StageName = OpportunityValidationHandler.OPP_STAGE_WON;

update Opp2;*/
    //test.stoptest(); commented on 29th aug group 1
    //test.starttest();
    /*
Opportunity ProsOpp1 = Test_DataFactory.createOpportunity();
ProsOpp1.StageName = OpportunityValidationHandler.OPP_STAGE_ACTIVE_PROSPECT;
ProsOpp1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PROSPECT);
ProsOpp1.Parent_Frame_Opportunity__c = opp2.id;
ProsOpp1.accountid = acc1.id;
ProsOpp1.Large_New_Sales__c =1;
ProsOpp1.Large_Continuation_Sales__c=1;
insert ProsOpp1;


opportunity opp22 = [select id,name,Sum_of_Prospect_NS__c,Sum_of_Prospect_CS__c from opportunity where id=:opp2.id];
system.assertequals(1,opp22.Sum_of_Prospect_NS__c);
system.assertequals(1,opp22.Sum_of_Prospect_CS__c);
//test.stoptest();
/*
Delete ProsOpp1;
opportunity opp3 = [select id,name,Sum_of_Prospect_NS__c,Sum_of_Prospect_CS__c from opportunity where id=:opp22.id];
system.assertequals(0,opp3.Sum_of_Prospect_NS__c);
system.assertequals(0,opp3.Sum_of_Prospect_CS__c);
*/
    //}

    //}
    @isTest
    public static void POLCygateMethods() {
        //Test_DataFactory.setUpOrg();
        account acc;
        List<User> userList = new List<User>();
        user cygateUser1 = Test_DataFactory.createCygateUser();
        user cygateUser2 = Test_DataFactory.createCygateUser();
        user businessAdmin = Test_DataFactory.createCygateEnterpriseBusinessAdminUser();
        user cygateUser3 = Test_DataFactory.createCygateChefUser();
        userList.add(cygateUser3);
        userList.add(cygateUser1);
        userList.add(cygateUser2);
        userList.add(businessAdmin);
        insert userList;

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).

            acc = Test_DataFactory.createOneCygateAccount(cygateUser1.Id);
            acc.OwnerId = cygateUser1.Id;
            insert acc;

            Test_DataFactory.createPriceBooks();
        }

        Yearly_Performance_Score__c yp = new Yearly_Performance_Score__c();
        Yearly_Performance_Score__c yp1 = new Yearly_Performance_Score__c();
        list<Yearly_Performance_Score__c> ypList = new List<Yearly_Performance_Score__c>();
        User_Performance__c up = new User_Performance__c();
        User_Performance__c up1 = new User_Performance__c();
        User_Performance__c upA = new User_Performance__c();
        User_Performance__c upB = new User_Performance__c();
        List<User_Performance__c> upList = new List<User_Performance__c>();
        Decimal monthlySalesRevenueTarget;

        System.runAs(businessAdmin) {
            up = Test_DataFactory.createUserPerformance(cygateUser1);
            up1 = Test_DataFactory.createUserPerformance(cygateUser2);
            up.User__c = cygateUser1.Id;
            up1.User__c = cygateUser2.Id;
            upList.add(up);
            upList.add(up1);
            insert upList;
            upA = upList[0];
            upB = upList[1];

            yp = Test_DataFactory.createYearlyPerformanceScore(up.Id);
            yp1 = Test_DataFactory.createYearlyPerformanceScore(up1.Id);
            ypList.add(yp1);

            ypList.add(yp);
            insert ypList;
            /*monthlySalesRevenueTarget = (yp.Product_Sales_Revenue_Target__c+yp.Services_Sales_Revenue_Target__c)/12;

            Yearly_Performance_Score__c ypAfterInsert = [SELECT Id, (SELECT Id, Sales_Revenue_Target__c, Client_Meetings_Target__c FROM Monthly_Performance_Scores__r ORDER BY Name ASC)
                                                    FROM Yearly_Performance_Score__c WHERE Id = :yp.Id];
            System.assertEquals(ypAfterInsert.Monthly_Performance_Scores__r.size(), 12,'Exactly 12 Monthly Performance Scores should be created on Yearly Performance Score');
            Monthly_Performance_Score__c mp = ypAfterInsert.Monthly_Performance_Scores__r[0];
            mp.Sales_Revenue_Target__c = 50000;
            update mp;*/

            Opportunity opp = Test_DataFactory.createCygateOpportunity();
            opp.New_Sales__c = 0;
            opp.Continuation_Sales__c = 1;
            opp.CloseDate = System.today();
            opp.OwnerId = cygateUser1.Id;
            test.starttest();
            insert opp;

            //opp.Cygate_Owner__c=cygateUser1.Id;
            //opp.OwnerId = cygateUser1.Id;
            //update opp;

            //test.starttest(); edited on 22nd aug
            List<OpportunityLineItem> olis = createProductaAndOpportunityLineItems(opp.Id, 1, 0);
            OpportunityLineItem oli = olis[0];

            insert oli;
            //test.stoptest();
            opp.CloseDate = System.today().addDays(31);
            update opp;

            opp.OwnerId = cygateUSer2.Id;
            update Opp;
            opp.OwnerId = cygateUser3.Id;
            //update opp;
            test.stoptest();

            //delete olis;
        }
    }

    @isTest
    public static void CaseAccessOppOwnerMethod() {
        account acc;
        List<User> largeUserTeam = new List<User>();
        Opportunity opp;
        case c = new case();
        c.recordTypeId = '01224000000LSYE';
        seller__c seller = new Seller__c();
        seller__c seller1 = new Seller__c();
        List<Seller__c> sellerList = new List<Seller__c>();
        largeUserTeam = Test_DataFactory.createLargeUserTeam(3);
        user largeUser = largeUserteam[0];
        user largeuser1 = largeuserteam[1];
        user largeuser2 = largeUserteam[2];

        test.starttest();
        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).

            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = largeUser.Id;
            insert acc;
            seller = Test_DataFactory.createSeller(largeuser.Id, null);
            seller1 = Test_DataFactory.createSeller(largeuser2.Id, null);
            sellerList.add(seller);
            sellerList.add(seller1);
            insert sellerList;

            Test_DataFactory.createPriceBooks();
        }

        System.runAs(largeuser) {
            opp = Test_DataFactory.createLargeOpportunity();
            opp.accountid = acc.Id;
            insert opp;

            //system.runAs(largeuser1){
            //c.recordTypeId = SEUtility.getRecordTypeId('Enterprise');
            c.subject = 'test subject case';
            c.Opportunity__c = opp.id;
            //c.Accountid = acc.id;
            insert c;

            // system.runAs(largeuser){
            opp.ownerId = largeUser2.Id;
            update opp;
            test.stoptest();
        }
    }
    @istest
    public static void AbparentoppClosetestMethod() {
        User salesRep;
        Seller__c seller;

        System.runAs(new user(id = userinfo.getuserid())) {
            salesRep = Test_DataFactory.createLargeUser();
            insert salesRep;
        }
        seller = Test_DataFactory.createSeller(salesRep.Id, null);
        seller.Start_Date__c = date.newInstance(2015, 1, 1);
        insert seller;

        Account Acc1 = new Account();
        Acc1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
        Acc1.Name = 'AccTest';
        acc1.OwnerId = salesRep.Id;
        insert acc1;

        Opportunity opp1 = Test_DataFactory.createOpportunity();
        opp1.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
        opp1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
        opp1.accountid = acc1.id;

        insert opp1;

        Opportunity MfOpp = new Opportunity();
        MfOpp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_MERFORSALJNINGSMOJLIGHET);
        MfOpp.Accountid = Acc1.Id;
        MfOpp.Name = 'MFOpp';
        MfOpp.Large_New_Sales__c = 3;
        MfOpp.Large_Continuation_Sales__c = 3;
        MfOpp.CloseDate = System.Today();
        MfOpp.StageName = 'Open';
        //MfOpp.Send_to_Volume_Sales__c = false;
        MfOpp.Frame_Opportunity__c = opp1.id;
        test.starttest();
        insert MfOpp;

        /*Upsell_Target_Account__c UTA = new Upsell_Target_Account__c();
UTA.Account__c = Acc1.Id;
UTA.Opportunity__c = MfOpp.Id;
UTA.Exclude_Account__c=false;
insert UTA;
*/

        System.runAs(Test_DataFactory.getByPassUser()) {
            //test.starttest();
            delete MfOpp;
            test.stoptest();
            /*
opportunity opp2 = [select id,name from opportunity where id=:opp1.id];
Opp2.StageName = OpportunityValidationHandler.OPP_STAGE_WON;

update Opp2;
/*
Opportunity ProsOpp1 = Test_DataFactory.createOpportunity();
ProsOpp1.StageName = OpportunityValidationHandler.OPP_STAGE_ACTIVE_PROSPECT;
ProsOpp1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PROSPECT);
ProsOpp1.Parent_Frame_Opportunity__c = opp2.id;
ProsOpp1.accountid = acc1.id;
ProsOpp1.Large_New_Sales__c =1;
ProsOpp1.Large_Continuation_Sales__c=1;
insert ProsOpp1;
test.stoptest();
delete Prosopp1;
*/
        }
    }
    public static testMethod void testAddFormarOppsOwner() {
        Test_DataFactory.setUpOrg();

        System.runAs(Test_DataFactory.getByPassUser()) {
            // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).

            Test.startTest();
            Account acc = Test_DataFactory.createOneAccount();
            acc.Security_Category__c = 'Klass 2B';
            insert acc;
            User u = Test_DataFactory.createCygateSalesSupportUser();
            //u.UserRoleId = '00E24000000vm1s';
            User u2 = Test_DataFactory.createCygateSalesSupportChef();
            insert u;
            insert u2;

            Opportunity opp = Test_DataFactory.createTeliaCygateOpportunity();
            opp.accountId = acc.Id;
            opp.OwnerId = u.Id;
            //opp.Account_Security_Category__c = 'Klass 2B';
            insert opp;

            //Updating the same opportunity to get the Owner into OldMap
            Opportunity oppToUpdate2 = [SELECT Id, ownerId, Account_Security_Category__c FROM Opportunity WHERE Id = :opp.Id];
            oppToUpdate2.OwnerId = u2.Id;
            //oppToUpdate2.Account_Security_Category__c = 'Klass 2B';
            update oppToUpdate2;

            Test.stopTest();
        }
    }
    public static testMethod void Test_addSMESalesKAMITasOTM() {
        Test_DataFactory.setUpOrg();

        Seller__c seller;
        Account acc = Test_DataFactory.createOneAccount();
        Contact c;
        Opportunity opp;
        User salesRep;

        System.runAs(Test_DataFactory.getByPassUser()) {
            salesRep = Test_DataFactory.createSMEUser();
            salesRep.Bypass_VR__c = true;
            insert salesRep;

            seller = Test_DataFactory.createSeller(salesRep.Id, null);
            seller.Start_Date__c = date.newInstance(2015, 1, 1);
            insert seller;

            acc = Test_DataFactory.createOneAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
        }
        System.runAs(salesRep) {
            //opp = Test_DataFactory.createSmeWonOpportunityNewSales(acc);
            opp = Test_DataFactory.createSmeOpportunity();
            opp.AccountId = acc.Id;
            opp.SME_Sales_KAM_IT__c = userinfo.getuserid();
            Test.startTest();
            insert opp;

            opp.SME_Sales_KAM_IT__c = salesRep.id;
            update opp;

            opp.SME_Sales_KAM_IT__c = null;
            update opp;

            opp.SME_Sales_KAM_IT__c = userinfo.getuserid();
            update opp;

            opp.SME_Sales_KAM_IT__c = salesRep.id;
            update opp;

            test.stopTest();
        }
    }

    @IsTest
    public static void Test_checkFantasticFour() {
        Test_DataFactory.setUpOrg();
        Account acc;
        List<Opportunity> opps;
        User salesRep;

        System.runAs(Test_DataFactory.getByPassUser()) {
            salesRep = Test_DataFactory.createSMEUser();
            salesRep.Bypass_VR__c = true;
            insert salesRep;
            acc = Test_DataFactory.createOneAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
            opps = Test_DataFactory.createOpportunitiesFromAccount(5, acc.Id);
            opps[0].Fantastic_4__c = true;
            opps[0].OwnerId = salesRep.Id;
            opps[1].Fantastic_4__c = true;
            opps[1].OwnerId = salesRep.Id;
            opps[2].Fantastic_4__c = true;
            opps[2].OwnerId = salesRep.Id;
            opps[3].Fantastic_4__c = true;
            opps[3].OwnerId = salesRep.Id;
            insert opps;
        }
        System.runAs(salesRep) {
            Test.startTest();
            List<Opportunity> fanOpportunities2 = [SELECT Id FROM Opportunity WHERE Fantastic_4__c = TRUE];
            System.debug(fanOpportunities2.size());
            opps[4].Fantastic_4__c = true;
            opps[4].OwnerId = salesRep.Id;
            try {
                update opps[4];
            } catch (DmlException ex) {
                System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
            }

            Test.stopTest();
            List<Opportunity> fanOpportunities = [SELECT Id FROM Opportunity WHERE Fantastic_4__c = TRUE];
            System.assertEquals(4, fanOpportunities.size());
        }
    }

    @IsTest
    public static void Test_fiberFlowDataToChilds() {
        FiberDiscountMandate__c fb = new FiberDiscountMandate__c();
        fb.Role__c = 'Manager';
        fb.Name = 'Manager';
        fb.EBIT_Max_Mandate__c = 12;
        fb.EBIT_Min_Mandate__c = 1;
        fb.ProductDiscountMaxMandate__c = 12;
        fb.ProductDiscountMinMandate__c = 12;
        insert fb;
        FiberDiscountMandate__c fb1 = new FiberDiscountMandate__c();
        fb1.Role__c = 'Director';
        fb1.Name = 'Director';
        fb1.EBIT_Max_Mandate__c = 12;
        fb1.EBIT_Min_Mandate__c = 1;
        fb1.ProductDiscountMaxMandate__c = 12;
        fb1.ProductDiscountMinMandate__c = 12;
        insert fb1;
        Test_DataFactory.setUpOrg();
        Account acc;
        List<Opportunity> opps;
        User salesRep;
        Id stdPriceBookRecId = Test.getStandardPricebookId();

        System.runAs(Test_DataFactory.getByPassUser()) {
            salesRep = Test_DataFactory.createFiberUser();
            salesRep.Bypass_VR__c = true;
            insert salesRep;
            acc = Test_DataFactory.createOneAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
            Opportunity opp = new Opportunity();
            opp = Test_DataFactory.createOpportunity();
            opp.RecordtypeId = '0121p000000wsYc';
            opp.OwnerId = salesRep.Id;
            opp.StageName = '01 Prospect';
            opp.Revenue_NS__c = 0;
            opp.Revenue_CS__c = 0;
            opp.Number_of_Households__c = 1;
            opp.Number_of_other_Ports__c = 1;
            opp.Number_of_Ports__c = 1;
            opp.Number_of_Premises__c = 1;
            insert opp;

            Quote qut = new Quote();
            qut.Name = 'Test Quote';
            qut.status = 'Draft';
            qut.Recordtypeid = SEUTility.getRecordTypeId('Individual_Quote');
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = false;
            qut.TeliaSE_Fiber_EBIT_Percentage__c = 26;
            insert qut;

            Contract conObj = new Contract();
            conObj.recordtypeId = '0121p000000wsYb';
            conObj.vlocity_cmt__QuoteId__c = qut.id;
            conobj.vlocity_cmt__OpportunityId__c = opp.Id;
            conObj.StartDate = system.today();
            conObj.enddate = system.today() + 50;
            conObj.TeliaSE_Fiber_Installation_Date__c = system.today() + 5;
            conObj.status = 'Draft';
            conObj.accountId = acc.Id;
            insert conObj;
        }
        System.runAs(salesRep) {
            Test.startTest();
            Opportunity fiberOpp = [SELECT Id, Number_of_Households__c FROM Opportunity WHERE RecordtypeId = '0121p000000wsYc'];
            fiberOpp.StageName = '05 Avbruten';
            fiberOpp.Comment_to_Reason__c = 'test cancel opp';
            fiberOpp.Type_of_Address__c = 'FTG';
            fiberOpp.Number_of_Households__c = 2;
            fiberOpp.Number_of_other_Ports__c = 2;
            fiberOpp.Number_of_Ports__c = 2;
            fiberOpp.Number_of_Premises__c = 2;
            fiberOpp.Number_of_Facilities__c = 2;
            fiberOpp.Municipality__c = 'Ale';
            fiberOpp.Brand__c = 'Halebop';
            fiberOpp.Amount_of_ports_Smart_Home__c = 2;

            fiberOpp.Wished_delivery_date_not_guaranteed__c = Date.Today();

            update fiberOpp;
            test.stoptest();
        }
        Contract updatedContract = [
            SELECT
                Number_of_Households__c,
                Number_of_other_Ports__c,
                Number_of_Ports__c,
                Number_of_Premises__c,
                Wished_delivery_date_not_guaranteed__c,
                Number_of_Facilities__c
            FROM Contract
        ];
        Quote updatedQuote = [
            SELECT
                TeliaSE_Fiber_Number_of_Households__c,
                Number_of_other_Ports__c,
                TeliaSE_Fiber_Number_of_Ports__c,
                TeliaSE_Fiber_Number_of_Premises__c,
                Wished_delivery_date_not_guaranteed__c,
                TeliaSE_Fiber_Number_of_Facilities__c
            FROM Quote
        ];

        System.assertEquals(2, updatedQuote.TeliaSE_Fiber_Number_of_Households__c, 'Quote wasn\'t updated number of households');
        System.assertEquals(2, updatedQuote.Number_of_other_Ports__c, 'Quote wasn\'t updated number of other ports');
        System.assertEquals(2, updatedQuote.TeliaSE_Fiber_Number_of_Ports__c, 'Quote wasn\'t updated number of ports');
        System.assertEquals(2, updatedQuote.TeliaSE_Fiber_Number_of_Premises__c, 'Quote wasn\'t updated number of premises');

        System.assertEquals(2, updatedQuote.TeliaSE_Fiber_Number_of_Facilities__c, 'Quote wasn\'t updated number of Facilities');

        System.assertEquals(Date.Today(), updatedQuote.Wished_delivery_date_not_guaranteed__c, 'Quote wasn\'t updated wished delivery date not guaranteed');
        System.assertEquals(2, updatedContract.Number_of_Households__c, 'Contract wasn\'t updated number of households');
        System.assertEquals(2, updatedContract.Number_of_other_Ports__c, 'Contract wasn\'t updated number of other ports');
        System.assertEquals(2, updatedContract.Number_of_Ports__c, 'Contract wasn\'t updated number of ports');
        System.assertEquals(2, updatedContract.Number_of_Premises__c, 'Contact wasn\'t updated number of premises');

        System.assertEquals(2, updatedContract.Number_of_Facilities__c, 'Contact wasn\'t updated number of Facilities');
        System.assertEquals(
            Date.Today(),
            updatedContract.Wished_delivery_date_not_guaranteed__c,
            'Contact wasn\'t updated wished delivery date not guaranteed'
        );
    }

    @IsTest
    public static void calculateTotalAmountCygateOnStatusChangeTest() {
        Test_DataFactory.createPriceBooks();

        Opportunity oppFrameAgreement = Test_DataFactory.createTeliaCygateOpportunity();
        oppFrameAgreement.Agreement_Type_Cygate__c = 'Frame Agreement Cygate';
        insert oppFrameAgreement;

        Opportunity oppCallOffAgreementCygate = Test_DataFactory.createTeliaCygateOpportunity();
        oppCallOffAgreementCygate.Agreement_Type_Cygate__c = 'Call off Agreement Cygate';
        oppCallOffAgreementCygate.Frame_Agreement_Cygate__c = oppFrameAgreement.Id;
        insert oppCallOffAgreementCygate;

        List<OpportunityLineItem> olis = createProductaAndOpportunityLineItems(oppCallOffAgreementCygate.Id, 1, 0);
        OpportunityLineItem oli = olis[0];
        oli.Temp_Total_Amount__c = 1250;
        insert oli;

        Test.startTest();
        oppCallOffAgreementCygate.StageName = 'Vunnen';
        update oppCallOffAgreementCygate;
        test.stoptest();

        Opportunity opportunityChild = [SELECT Id, Total_Amount_Cygate__c FROM Opportunity WHERE Id = :oppCallOffAgreementCygate.Id];
        Opportunity opportunityParent = [SELECT Id, Call_offs_total_amount_Cygate__c FROM Opportunity WHERE Id = :oppFrameAgreement.Id];
        System.assertEquals(opportunityChild.Total_Amount_Cygate__c, opportunityParent.Call_offs_total_amount_Cygate__c, 'Parent have bad Total Amount Value');
    }

    @IsTest
    public static void calculateTotalAmountCygateOnStatusUnchangeTest() {
        Test_DataFactory.createPriceBooks();

        Opportunity oppFrameAgreement = Test_DataFactory.createTeliaCygateOpportunity();
        oppFrameAgreement.Agreement_Type_Cygate__c = 'Frame Agreement Cygate';
        insert oppFrameAgreement;

        Opportunity oppCallOffAgreementCygate = Test_DataFactory.createTeliaCygateOpportunity();
        oppCallOffAgreementCygate.Agreement_Type_Cygate__c = 'Call off Agreement Cygate';
        oppCallOffAgreementCygate.Frame_Agreement_Cygate__c = oppFrameAgreement.Id;
        insert oppCallOffAgreementCygate;

        List<OpportunityLineItem> olis = createProductaAndOpportunityLineItems(oppCallOffAgreementCygate.Id, 1, 0);
        OpportunityLineItem oli = olis[0];
        oli.Temp_Total_Amount__c = 1250;
        insert oli;

        Test.startTest();
        oppCallOffAgreementCygate.StageName = 'Vunnen';
        update oppCallOffAgreementCygate;
        oppCallOffAgreementCygate.StageName = 'Draft';
        update oppCallOffAgreementCygate;
        test.stoptest();

        Opportunity opportunityParent = [SELECT Id, Call_offs_total_amount_Cygate__c FROM Opportunity WHERE Id = :oppFrameAgreement.Id];
        System.assertEquals(0, opportunityParent.Call_offs_total_amount_Cygate__c, 'Parent have bad Total Amount Value');
    }

    @IsTest
    public static void calculateTotalAmountCygateOnParentChangeTest() {
        Test_DataFactory.createPriceBooks();

        Opportunity oppFrameAgreement = Test_DataFactory.createTeliaCygateOpportunity();
        oppFrameAgreement.Agreement_Type_Cygate__c = 'Frame Agreement Cygate';
        insert oppFrameAgreement;

        Opportunity oppFrameAgreement1 = Test_DataFactory.createTeliaCygateOpportunity();
        oppFrameAgreement1.Agreement_Type_Cygate__c = 'Frame Agreement Cygate';
        insert oppFrameAgreement1;

        Opportunity oppCallOffAgreementCygate = Test_DataFactory.createTeliaCygateOpportunity();
        oppCallOffAgreementCygate.Agreement_Type_Cygate__c = 'Call off Agreement Cygate';
        oppCallOffAgreementCygate.Frame_Agreement_Cygate__c = oppFrameAgreement.Id;
        insert oppCallOffAgreementCygate;

        List<OpportunityLineItem> olis = createProductaAndOpportunityLineItems(oppCallOffAgreementCygate.Id, 1, 0);
        OpportunityLineItem oli = olis[0];
        oli.Temp_Total_Amount__c = 1250;
        insert oli;

        Test.startTest();
        oppCallOffAgreementCygate.StageName = 'Vunnen';
        update oppCallOffAgreementCygate;
        oppCallOffAgreementCygate.Frame_Agreement_Cygate__c = oppFrameAgreement1.Id;
        update oppCallOffAgreementCygate;
        test.stoptest();

        Opportunity opportunityChild = [SELECT Id, Total_Amount_Cygate__c FROM Opportunity WHERE Id = :oppCallOffAgreementCygate.Id];
        Opportunity opportunityParent = [SELECT Id, Call_offs_total_amount_Cygate__c FROM Opportunity WHERE Id = :oppFrameAgreement.Id];
        Opportunity opportunityParent1 = [SELECT Id, Call_offs_total_amount_Cygate__c FROM Opportunity WHERE Id = :oppFrameAgreement1.Id];
        System.assertEquals(0, opportunityParent.Call_offs_total_amount_Cygate__c, 'Parent have bad Total Amount Value');
        System.assertEquals(opportunityChild.Total_Amount_Cygate__c, opportunityParent1.Call_offs_total_amount_Cygate__c, 'Parent have bad Total Amount Value');
    }

    @IsTest
    public static void calculateTotalAmountCygateOnDeleteTest() {
        Test_DataFactory.createPriceBooks();

        Opportunity oppFrameAgreement = Test_DataFactory.createTeliaCygateOpportunity();
        oppFrameAgreement.Agreement_Type_Cygate__c = 'Frame Agreement Cygate';
        insert oppFrameAgreement;

        Opportunity oppCallOffAgreementCygate = Test_DataFactory.createTeliaCygateOpportunity();
        oppCallOffAgreementCygate.Agreement_Type_Cygate__c = 'Call off Agreement Cygate';
        oppCallOffAgreementCygate.Frame_Agreement_Cygate__c = oppFrameAgreement.Id;
        insert oppCallOffAgreementCygate;

        List<OpportunityLineItem> olis = createProductaAndOpportunityLineItems(oppCallOffAgreementCygate.Id, 1, 0);
        OpportunityLineItem oli = olis[0];
        oli.Temp_Total_Amount__c = 1250;
        insert oli;

        Test.startTest();
        oppCallOffAgreementCygate.StageName = 'Vunnen';
        update oppCallOffAgreementCygate;
        delete oppCallOffAgreementCygate;
        test.stoptest();

        Opportunity opportunityParent = [SELECT Id, Call_offs_total_amount_Cygate__c FROM Opportunity WHERE Id = :oppFrameAgreement.Id];
        System.assertEquals(0, opportunityParent.Call_offs_total_amount_Cygate__c, 'Parent have bad Total Amount Value');
    }

    /**
     * @Description:
     * Verify that Opportunities exempt from existing automations are being
     * filtered out correctly.
     * Modifications:
     * 21.09.2023 [TB] LTAT-7256 - Introduced.
     **/ 
    @isTest
    public static void testSetListNonExemptOpportunities(){
        User userBypass = Test_DataFactory.getByPassUser();
        System.runAs(userBypass){
            // Create a List of Large Opportunities that are not exempt from existing automations
            Account largeAccount = Test_DataFactory.createOneLargeStandardAccount();
            largeAccount.Name = 'largeTestAccount';
            insert largeAccount;
            List<Opportunity> lstLargeOpps = new List<Opportunity>();
            for(Integer Idx = 0; idx < 2; idx++){
                Opportunity curOpportunity = Test_DataFactory.createLargeOpportunity();
                curOpportunity.AccountId = largeAccount.Id;
                lstLargeOpps.add(curOpportunity);
            }
            // Create a List of Wholesales Opportunities that are exempt from existing automations
            List<Opportunity> lstWholesalesOpps = new List<Opportunity>();
            Integer numWholesaleOpps = 2;
            for(Integer Idx = 0; idx < numWholesaleOpps; idx++){
                Opportunity curWholesalesOpportunity = createWholesalesOpportunity();
                curWholesalesOpportunity.Name += String.valueOf(Idx);
                lstWholesalesOpps.add(curWholesalesOpportunity);
            }

            Test.startTest();
            // Test for null Trigger context variable
            List<Opportunity> lstNonExemptOpportunities;
            List<Opportunity> lstTestTriggerContext = null;
            lstNonExemptOpportunities = OpportunityTriggerHandler.setListNonExemptOpportunities(lstTestTriggerContext);
            System.assertEquals(null, lstNonExemptOpportunities,
                'setListNonExemptOpportunities() should return null when the passed Trigger context variable is null.');

            // Test for Trigger context variable containing only non-exempt Opportunities
            lstTestTriggerContext = lstLargeOpps;
            lstNonExemptOpportunities = OpportunityTriggerHandler.setListNonExemptOpportunities(lstTestTriggerContext);
            System.assertEquals(lstTestTriggerContext.size(), lstNonExemptOpportunities.size(),
                'setListNonExemptOpportunities() should not have filtered out any Opportunities from a Trigger context'
                + ' variable containing only Large Opportunites.');

            // Test for Trigger context variable containing only exempt Opportunities
            lstTestTriggerContext = lstWholesalesOpps;
            lstNonExemptOpportunities = OpportunityTriggerHandler.setListNonExemptOpportunities(lstTestTriggerContext);
            System.assert(lstNonExemptOpportunities.isEmpty(),
                'setListNonExemptOpportunities() should return an empty list when the passed Trigger context'
                + ' variable contains only Wholesales Opportunites.');
                
            // Test for Trigger context variable containing only exempt Opportunities
            lstTestTriggerContext = lstWholesalesOpps.clone();
            lstTestTriggerContext.addAll(lstLargeOpps);
            lstNonExemptOpportunities = OpportunityTriggerHandler.setListNonExemptOpportunities(lstTestTriggerContext);
            System.assertEquals(lstTestTriggerContext.size() - numWholesaleOpps, lstNonExemptOpportunities.size(),
                'setListNonExemptOpportunities() should have filtered out ' + String.valueOf(numWholesaleOpps)
                + ' Wholesales Opportunites from the passed Trigger context variable.');
            Test.stopTest();
        }
    }

    /**
     * @Description:
     * Verify that Opportunities exempt from existing automations are being
     * filtered out correctly.
     * Modifications:
     * 21.09.2023 [TB] LTAT-7256 - Introduced.
     **/ 
    @isTest
    public static void testSetMapNonExemptOpportunities(){
        User userBypass = Test_DataFactory.getByPassUser();
        System.runAs(userBypass){
            // Create a List of Large Opportunities that are not exempt from existing automations
            // and retrieve a corresponding Id to sObject map
            Account largeAccount = Test_DataFactory.createOneLargeStandardAccount();
            largeAccount.Name = 'largeTestAccount';
            insert largeAccount;
            List<Opportunity> lstLargeOpps = new List<Opportunity>();
            for(Integer Idx = 0; idx < 2; idx++){
                Opportunity curOpportunity = Test_DataFactory.createLargeOpportunity();
                curOpportunity.AccountId = largeAccount.Id;
                lstLargeOpps.add(curOpportunity);
            }
            insert lstLargeOpps;
            Map<Id,Opportunity> mapIdsToLargeOpps = new Map<Id,Opportunity>(
                [   SELECT Id, Name, RecordTypeId
                    FROM Opportunity 
                    WHERE ID IN :lstLargeOpps]);

            // Create a List of Wholesales Opportunities that are exempt from existing automations
            // and retrieve a corresponding Id to sObject map
            List<Opportunity> lstWholesalesOpps = new List<Opportunity>();
            Integer numWholesaleOpps = 2;
            for(Integer Idx = 0; idx < numWholesaleOpps; idx++){
                Opportunity curWholesalesOpportunity = createWholesalesOpportunity();
                curWholesalesOpportunity.Name += String.valueOf(Idx);
                lstWholesalesOpps.add(curWholesalesOpportunity);
            }
            insert lstWholesalesOpps;
            Map<Id,Opportunity> mapIdsToWholesalesOpps = new Map<Id,Opportunity>(
                [   SELECT Id, Name, RecordTypeId
                    FROM Opportunity
                    WHERE ID IN :lstWholesalesOpps]);

            Test.startTest();
            // Test for null Trigger context variable
            Map<Id,Opportunity> mapIdsToNonExemptOpportunities;
            Map<Id,Opportunity> mapTestTriggerContext = null;
            mapIdsToNonExemptOpportunities = OpportunityTriggerHandler.setMapNonExemptOpportunities(mapTestTriggerContext);
            System.assertEquals(null, mapIdsToNonExemptOpportunities,
                'setMapNonExemptOpportunities() should return null when the passed Trigger context variable is null.');

            // Test for Trigger context variable containing only non-exempt Opportunities
            mapTestTriggerContext = mapIdsToLargeOpps;
            mapIdsToNonExemptOpportunities = OpportunityTriggerHandler.setMapNonExemptOpportunities(mapTestTriggerContext);
            System.assertEquals(mapTestTriggerContext.size(), mapIdsToNonExemptOpportunities.size(),
                'setMapNonExemptOpportunities() should not have filtered out any Opportunities from a Trigger context'
                + ' variable containing only Large Opportunites.');

            // Test for Trigger context variable containing only exempt Opportunities
            mapTestTriggerContext = mapIdsToWholesalesOpps;
            mapIdsToNonExemptOpportunities = OpportunityTriggerHandler.setMapNonExemptOpportunities(mapTestTriggerContext);
            System.assert(mapIdsToNonExemptOpportunities.isEmpty(),
                'setMapNonExemptOpportunities() should return an empty list when the passed Trigger context'
                + ' variable contains only Wholesales Opportunites.');
                
            // Test for Trigger context variable containing only exempt Opportunities
            mapTestTriggerContext = mapIdsToWholesalesOpps.clone();
            mapTestTriggerContext.putAll(mapIdsToLargeOpps);
            mapIdsToNonExemptOpportunities = OpportunityTriggerHandler.setMapNonExemptOpportunities(mapTestTriggerContext);
            System.assertEquals(mapTestTriggerContext.size() - numWholesaleOpps, mapIdsToNonExemptOpportunities.size(),
                'setMapNonExemptOpportunities() should have filtered out ' + String.valueOf(numWholesaleOpps)
                + ' Wholesales Opportunites from the passed Trigger context variable.');
            Test.stopTest();
        }
    }

    /**
     * @Description:
     * Ensure DML operations work correctly when transaction involves
     * only Opportunities exempt from existing automations.
     * Modifications:
     * 21.09.2023 [TB] LTAT-7256 - Introduced.
     **/ 
    @isTest
    public static void testDMLOperationsWithWholesalesOpportunitiesOnly(){
        User userBypass = Test_DataFactory.getByPassUser();
        Integer NUMBER_OF_WHOLESALES_OPPS = 5;
        System.runAs(userBypass){
            // Create a List of Wholesales Opportunities that are exempt from existing automations
            List<Opportunity> lstWholesaleOpps = new List<Opportunity>();
            for(Integer Idx = 0; idx < NUMBER_OF_WHOLESALES_OPPS; idx++){
                Opportunity curWholesalesOpportunity = createWholesalesOpportunity();
                curWholesalesOpportunity.Name += String.valueOf(Idx);
                lstWholesaleOpps.add(curWholesalesOpportunity);
            }
            // Test DML operations involving exempt Opportunities only
            Test.startTest();
            try{
                insert lstWholesaleOpps;
                for(Opportunity curWholesaleOpportunity : lstWholesaleOpps){
                    curWholesaleOpportunity.Name += 'Update';
                }
                update lstWholesaleOpps;
                delete lstWholesaleOpps;
            } catch(Exception exceptionDML){
                System.assert(  false,
                    'A DML operation containing only Wholesales Opportunities failed with the following'
                    + ' error message: ' + exceptionDML.getMessage());
            }
            Test.stopTest();
        }
    }

    /**
     * @Description:
     * Helper method returning a Wholesales Opportunity.
     * @return Wholesales Opportunity test record.
     * Modifications:
     * 21.09.2023 [TB] LTAT-7256 - Introduced.
     **/
    public static Opportunity createWholesalesOpportunity(){
        return new Opportunity(
                    RecordTypeId = OPPORTUNITY_RECORDTYPEID_WHOLESALES_OPPORTUNITY,
                    Name = 'TestOpportunity_Wholesales',
                    StageName = SEConstantsOpportunity.OPPORTUNITY_STAGE_API_NAME_KVALIFICERA,
                    CloseDate = Date.today());
    }
}